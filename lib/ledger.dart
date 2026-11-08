import 'dart:math';
part 'membership.dart';
part 'workflow.dart';

const fundId = '_fund';
const maxAmount = 1000000000;
String newId() =>
    '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(0x100000000)}';

class RuleError implements Exception {
  final String message;
  RuleError(this.message);
  @override
  String toString() => message;
}

void require(bool condition, String message) {
  if (!condition) throw RuleError(message);
}

enum EntryKind { expense, deposit, payment, refund, reversal }

enum EntryStatus { pending, confirmed, rejected }

class Member {
  final String id;
  final String name;
  final String? accountId;
  const Member(this.id, this.name, {this.accountId});
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'accountId': accountId,
  };
  factory Member.fromJson(Map<String, dynamic> json) => Member(
    json['id'] as String,
    json['name'] as String,
    accountId: json['accountId'] as String?,
  );
}

class Entry {
  final String id, title, actor, payer, receiver, createdAt;
  final int amount;
  final EntryKind kind;
  final EntryStatus status;
  final List<String> participants;
  final bool fundExpense;
  final String? evidence, reviewedBy, reviewedAt, reason, reverses;

  Entry({
    required this.id,
    required this.kind,
    required this.title,
    required this.actor,
    required this.payer,
    required this.receiver,
    required this.amount,
    required this.createdAt,
    this.status = EntryStatus.pending,
    this.participants = const [],
    this.fundExpense = false,
    this.evidence,
    this.reviewedBy,
    this.reviewedAt,
    this.reason,
    this.reverses,
  });

  Entry reviewed(EntryStatus status, String actor, String? reason) => Entry(
    id: id,
    kind: kind,
    title: title,
    actor: this.actor,
    payer: payer,
    receiver: receiver,
    amount: amount,
    createdAt: createdAt,
    status: status,
    participants: participants,
    fundExpense: fundExpense,
    evidence: evidence,
    reviewedBy: actor,
    reviewedAt: DateTime.now().toIso8601String(),
    reason: reason,
    reverses: reverses,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'actor': actor,
    'payer': payer,
    'receiver': receiver,
    'amount': amount,
    'createdAt': createdAt,
    'status': status.name,
    'participants': participants,
    'fundExpense': fundExpense,
    'evidence': evidence,
    'reviewedBy': reviewedBy,
    'reviewedAt': reviewedAt,
    'reason': reason,
    'reverses': reverses,
  };
  factory Entry.fromJson(Map<String, dynamic> j) => Entry(
    id: j['id'] as String,
    kind: EntryKind.values.byName(j['kind'] as String),
    title: j['title'] as String,
    actor: j['actor'] as String,
    payer: j['payer'] as String,
    receiver: j['receiver'] as String,
    amount: j['amount'] as int,
    createdAt: j['createdAt'] as String,
    status: EntryStatus.values.byName(j['status'] as String),
    participants: List<String>.from(j['participants'] as List),
    fundExpense: j['fundExpense'] as bool,
    evidence: j['evidence'] as String?,
    reviewedBy: j['reviewedBy'] as String?,
    reviewedAt: j['reviewedAt'] as String?,
    reason: j['reason'] as String?,
    reverses: j['reverses'] as String?,
  );
}

Map<String, int> splitEqually(int amount, List<String> ids) {
  require(
    amount > 0 && amount <= maxAmount,
    'Số tiền phải từ 1đ đến 1 tỷ đồng.',
  );
  require(
    ids.isNotEmpty && ids.toSet().length == ids.length,
    'Chọn ít nhất một người, không trùng lặp.',
  );
  return {
    for (var i = 0; i < ids.length; i++)
      ids[i]: amount ~/ ids.length + (i < amount % ids.length ? 1 : 0),
  };
}

class Transfer {
  final String from, to;
  final int amount;
  const Transfer(this.from, this.to, this.amount);
}

class Balances {
  int cash = 0;
  final Map<String, int> personal, owedByFund, contributions;
  Balances(List<Member> members)
    : personal = {for (final m in members) m.id: 0},
      owedByFund = {for (final m in members) m.id: 0},
      contributions = {for (final m in members) m.id: 0};
  int get liability => owedByFund.values.fold(0, (a, b) => a + b);
  int get available => cash - liability;

  List<Transfer> get transfers {
    final remaining = Map<String, int>.from(personal);
    final result = <Transfer>[];
    for (final debtor in remaining.keys) {
      if (remaining[debtor]! >= 0) continue;
      for (final creditor in remaining.keys) {
        if (remaining[creditor]! <= 0) continue;
        final amount = min(-remaining[debtor]!, remaining[creditor]!);
        if (amount == 0) break;
        result.add(Transfer(debtor, creditor, amount));
        remaining[debtor] = remaining[debtor]! + amount;
        remaining[creditor] = remaining[creditor]! - amount;
      }
    }
    return result;
  }
}

class BillGroup {
  final String id, name, treasurer;
  final List<Member> members;
  final List<Entry> entries;
  final Map<String, dynamic> workflow;
  final List<Map<String, dynamic>> invitations, joinRequests, membershipAudit;
  BillGroup({
    required this.id,
    required this.name,
    required this.treasurer,
    required List<Member> members,
    List<Entry> entries = const [],
    List<Map<String, dynamic>> invitations = const [],
    List<Map<String, dynamic>> joinRequests = const [],
    List<Map<String, dynamic>> membershipAudit = const [],
    Map<String, dynamic>? workflow,
  }) : members = List.of(members),
       entries = List.of(entries),
       invitations = List.of(invitations),
       joinRequests = List.of(joinRequests),
       membershipAudit = List.of(membershipAudit),
       workflow =
           workflow ??
           {
             'period': 1,
             'frequency': 'weekly',
             'policyVersion': 1,
             'history': <dynamic>[],
             'feedback': <dynamic>[],
             'notifications': <dynamic>[],
             'reminders': true,
           } {
    require(
      name.trim().isNotEmpty && name.length <= 80,
      'Tên nhóm cần từ 1 đến 80 ký tự.',
    );
    require(
      members.length >= 2 && members.length <= 30,
      'Nhóm thử nghiệm cần 2–30 người.',
    );
    require(
      members.map((m) => m.id).toSet().length == members.length,
      'Thành viên bị trùng.',
    );
    require(
      members.every(
        (m) =>
            m.id.isNotEmpty &&
            m.id != fundId &&
            m.name.trim().isNotEmpty &&
            m.name.length <= 50,
      ),
      'Tên thành viên cần từ 1 đến 50 ký tự.',
    );
    final accounts = members
        .where((m) => m.accountId != null)
        .map((m) => m.accountId)
        .toList();
    require(
      accounts.toSet().length == accounts.length,
      'Một tài khoản chỉ có một hồ sơ trong nhóm.',
    );
    require(members.any((m) => m.id == treasurer), 'Thủ quỹ phải thuộc nhóm.');
  }
  String memberName(String id) =>
      id == fundId ? 'Quỹ chung' : members.firstWhere((m) => m.id == id).name;
  bool hasMember(String id) => members.any((m) => m.id == id);
  bool isReversed(Entry e) => entries.any((r) => r.reverses == e.id);
  Iterable<Entry> get active => entries.where(
    (e) =>
        e.status == EntryStatus.confirmed &&
        e.kind != EntryKind.reversal &&
        !isReversed(e),
  );

  Balances get balances {
    final b = Balances(members);
    for (final e in active) {
      switch (e.kind) {
        case EntryKind.expense:
          if (e.fundExpense) {
            if (e.payer == fundId) {
              b.cash -= e.amount;
            } else {
              b.owedByFund[e.payer] = b.owedByFund[e.payer]! + e.amount;
            }
          } else {
            b.personal[e.payer] = b.personal[e.payer]! + e.amount;
            for (final share in splitEqually(
              e.amount,
              e.participants,
            ).entries) {
              b.personal[share.key] = b.personal[share.key]! - share.value;
            }
          }
        case EntryKind.deposit:
          b.cash += e.amount;
          b.contributions[e.payer] = b.contributions[e.payer]! + e.amount;
        case EntryKind.payment:
          b.personal[e.payer] = b.personal[e.payer]! + e.amount;
          b.personal[e.receiver] = b.personal[e.receiver]! - e.amount;
        case EntryKind.refund:
          b.cash -= e.amount;
          b.owedByFund[e.receiver] = b.owedByFund[e.receiver]! - e.amount;
        case EntryKind.reversal:
          break;
      }
    }
    return b;
  }

  List<Transfer> get directTransfers {
    final pairs = <String, Map<String, int>>{};
    void add(String from, String to, int amount) {
      if (from == to) return;
      pairs.putIfAbsent(from, () => {})[to] = (pairs[from]?[to] ?? 0) + amount;
      pairs.putIfAbsent(to, () => {})[from] = (pairs[to]?[from] ?? 0) - amount;
    }

    for (final e in active) {
      if (e.kind == EntryKind.expense && !e.fundExpense) {
        for (final share in splitEqually(e.amount, e.participants).entries) {
          add(share.key, e.payer, share.value);
        }
      } else if (e.kind == EntryKind.payment) {
        add(e.payer, e.receiver, -e.amount);
      }
    }
    return [
      for (final row in pairs.entries)
        for (final col in row.value.entries)
          if (col.value > 0) Transfer(row.key, col.key, col.value),
    ];
  }

  String reviewer(Entry e) => switch (e.kind) {
    EntryKind.deposit => treasurer,
    EntryKind.expense => treasurer,
    EntryKind.payment || EntryKind.refund => e.receiver,
    EntryKind.reversal => treasurer,
  };

  void _checkAmount(Entry e) {
    require(
      e.amount > 0 && e.amount <= maxAmount,
      'Số tiền phải từ 1đ đến 1 tỷ đồng.',
    );
    require(
      e.title.trim().isNotEmpty && e.title.length <= 120,
      'Nội dung cần từ 1 đến 120 ký tự.',
    );
    require(hasMember(e.actor), 'Người thao tác không thuộc nhóm.');
    require(
      e.evidence == null || e.evidence!.length <= 2800000,
      'Ảnh quá lớn, vui lòng chọn ảnh dưới 2 MB.',
    );
  }

  void _checkBalance(Entry e) {
    final b = balances;
    if (e.kind == EntryKind.expense && e.fundExpense) {
      require(
        b.available >= e.amount,
        'Quỹ khả dụng không đủ. Hãy nộp thêm quỹ rồi thử lại.',
      );
    }
    if (e.kind == EntryKind.payment) {
      final owed = directTransfers
          .where((t) => t.from == e.payer && t.to == e.receiver)
          .fold<int>(0, (s, t) => s + t.amount);
      require(e.amount <= owed, 'Số tiền vượt khoản nợ với người nhận.');
    }
    if (e.kind == EntryKind.refund) {
      require(
        e.amount <= (b.owedByFund[e.receiver] ?? 0) && e.amount <= b.cash,
        'Số tiền vượt khoản cần hoàn hoặc tiền quỹ thực có.',
      );
    }
  }

  void addExpense({
    required String id,
    required String actor,
    required String title,
    required int amount,
    required String payer,
    required List<String> participants,
    String? evidence,
  }) {
    require(!entries.any((e) => e.id == id), 'Khoản này đã được lưu.');
    require(
      participants.isNotEmpty &&
          participants.toSet().length == participants.length &&
          participants.every(hasMember),
      'Danh sách người tham gia không hợp lệ.',
    );
    final ordered = members
        .where((m) => participants.contains(m.id))
        .map((m) => m.id)
        .toList();
    final all = ordered.length == members.length;
    require(
      hasMember(payer) || (all && payer == fundId),
      'Chỉ dùng quỹ khi đủ tất cả thành viên.',
    );
    final pending = payer == fundId && actor != treasurer;
    final e = Entry(
      id: id,
      kind: EntryKind.expense,
      title: title.trim(),
      actor: actor,
      payer: payer,
      receiver: '',
      amount: amount,
      createdAt: DateTime.now().toIso8601String(),
      participants: ordered,
      fundExpense: all,
      evidence: evidence,
      status: pending ? EntryStatus.pending : EntryStatus.confirmed,
      reviewedBy: pending ? null : actor,
      reviewedAt: pending ? null : DateTime.now().toIso8601String(),
    );
    _checkAmount(e);
    _checkBalance(e);
    entries.add(e);
  }

  void request({
    required String id,
    required EntryKind kind,
    required String actor,
    required String receiver,
    required int amount,
    String? evidence,
  }) {
    require(!entries.any((e) => e.id == id), 'Yêu cầu này đã được lưu.');
    require(
      [EntryKind.deposit, EntryKind.payment, EntryKind.refund].contains(kind),
      'Loại yêu cầu không hợp lệ.',
    );
    final payer = kind == EntryKind.refund ? fundId : actor;
    if (kind == EntryKind.deposit) {
      require(receiver == fundId, 'Nộp tiền vào quỹ chung.');
    }
    if (kind == EntryKind.payment) {
      require(
        hasMember(receiver) && receiver != actor,
        'Chọn một người nhận khác.',
      );
    }
    if (kind == EntryKind.refund) {
      require(
        actor == treasurer && hasMember(receiver),
        'Chỉ thủ quỹ được tạo khoản hoàn ứng.',
      );
    }
    final e = Entry(
      id: id,
      kind: kind,
      title: switch (kind) {
        EntryKind.deposit => 'Nộp quỹ',
        EntryKind.payment => 'Trả nợ',
        _ => 'Quỹ hoàn ứng',
      },
      actor: actor,
      payer: payer,
      receiver: receiver,
      amount: amount,
      createdAt: DateTime.now().toIso8601String(),
      evidence: evidence,
    );
    _checkAmount(e);
    _checkBalance(e);
    entries.add(e);
  }

  void review(String id, String actor, {required bool accept, String? reason}) {
    final index = entries.indexWhere((e) => e.id == id);
    require(index >= 0, 'Không tìm thấy yêu cầu.');
    final e = entries[index];
    require(
      e.status == EntryStatus.pending,
      'Yêu cầu đã được xử lý, không ghi nhận lần nữa.',
    );
    require(
      actor == reviewer(e),
      'Cần đổi sang vai người nhận hoặc thủ quỹ để xác nhận.',
    );
    if (accept) {
      _checkBalance(e);
    } else {
      require(
        reason != null && reason.trim().isNotEmpty && reason.length <= 300,
        'Nhập lý do từ chối, tối đa 300 ký tự.',
      );
    }
    entries[index] = e.reviewed(
      accept ? EntryStatus.confirmed : EntryStatus.rejected,
      actor,
      reason?.trim(),
    );
  }

  void reverseLatest(String actor, String reason, String id) {
    require(actor == treasurer, 'Chỉ thủ quỹ được đảo giao dịch.');
    require(
      reason.trim().isNotEmpty && reason.length <= 300,
      'Nhập lý do điều chỉnh, tối đa 300 ký tự.',
    );
    require(!entries.any((e) => e.id == id), 'Điều chỉnh đã được lưu.');
    final current = active.toList();
    require(current.isNotEmpty, 'Chưa có giao dịch để đảo.');
    // shortcut: chỉ đảo lần ghi sổ gần nhất, thêm kiểm tra phụ thuộc khi cần sửa giao dịch cũ.
    current.sort(
      (a, b) =>
          (a.reviewedAt ?? a.createdAt).compareTo(b.reviewedAt ?? b.createdAt),
    );
    final target = current.last;
    entries.add(
      Entry(
        id: id,
        kind: EntryKind.reversal,
        title: 'Đảo ${target.title}',
        actor: actor,
        payer: target.payer,
        receiver: target.receiver,
        amount: target.amount,
        createdAt: DateTime.now().toIso8601String(),
        status: EntryStatus.confirmed,
        reason: reason.trim(),
        reverses: target.id,
        reviewedBy: actor,
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'schema': 1,
    'id': id,
    'name': name,
    'workflow': workflow,
    'invitations': invitations,
    'joinRequests': joinRequests,
    'membershipAudit': membershipAudit,
    'treasurer': treasurer,
    'members': members.map((m) => m.toJson()).toList(),
    'entries': entries.map((e) => e.toJson()).toList(),
  };
  factory BillGroup.fromJson(Map<String, dynamic> j) {
    require(j['schema'] == 1, 'Phiên bản dữ liệu chưa được hỗ trợ.');
    return BillGroup(
      id: j['id'] as String,
      name: j['name'] as String,
      treasurer: j['treasurer'] as String,
      workflow: j['workflow'] == null
          ? null
          : Map<String, dynamic>.from(j['workflow'] as Map),
      invitations: (j['invitations'] as List? ?? [])
          .map((x) => Map<String, dynamic>.from(x as Map))
          .toList(),
      joinRequests: (j['joinRequests'] as List? ?? [])
          .map((x) => Map<String, dynamic>.from(x as Map))
          .toList(),
      membershipAudit: (j['membershipAudit'] as List? ?? [])
          .map((x) => Map<String, dynamic>.from(x as Map))
          .toList(),
      members: (j['members'] as List)
          .map((m) => Member.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
      entries: (j['entries'] as List)
          .map((e) => Entry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
