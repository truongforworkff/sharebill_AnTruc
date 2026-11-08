part of 'ledger.dart';

extension GroupWorkflow on BillGroup {
  List<dynamic> get feedback => workflow['feedback'] as List;
  List<dynamic> get periods => workflow['history'] as List;
  List<dynamic> get notifications => workflow['notifications'] as List;
  void reportBill(String entryId, String actor, String reason) {
    require(hasMember(actor), 'Người phản hồi không thuộc nhóm.');
    require(
      entries.any((e) => e.id == entryId && e.kind == EntryKind.expense),
      'Không tìm thấy bill.',
    );
    require(
      reason.trim().isNotEmpty && reason.length <= 500,
      'Cần lý do, tối đa 500 ký tự.',
    );
    feedback.add({
      'id': newId(),
      'entryId': entryId,
      'actor': actor,
      'reason': reason.trim(),
      'status': 'open',
    });
  }

  void resolveReport(String id, String actor, String explanation) {
    final report = feedback.where((f) => f['id'] == id).firstOrNull;
    require(
      report != null && report['status'] == 'open',
      'Phản hồi đã xử lý hoặc không tồn tại.',
    );
    final entry = entries.firstWhere((e) => e.id == report['entryId']);
    require(
      actor == treasurer || actor == entry.actor,
      'Chỉ người tạo bill hoặc quản lý được xử lý.',
    );
    require(
      explanation.trim().isNotEmpty && explanation.length <= 500,
      'Cần giải thích, tối đa 500 ký tự.',
    );
    report['status'] = 'resolved';
    report['reply'] = explanation.trim();
    report['resolvedBy'] = actor;
  }

  void proposeFrequency(String frequency, String actor) {
    require(actor == treasurer, 'Chỉ quản lý được đề xuất.');
    require(['weekly', 'monthly'].contains(frequency), 'Kỳ không hợp lệ.');
    require(workflow['proposal'] == null, 'Đang có đề xuất chờ.');
    workflow['proposal'] = {
      'frequency': frequency,
      'votes': <dynamic>[actor],
    };
  }

  void voteFrequency(String actor) {
    require(hasMember(actor), 'Không thuộc nhóm.');
    final p = workflow['proposal'];
    require(p != null, 'Không có đề xuất.');
    final votes = p['votes'] as List;
    if (!votes.contains(actor)) votes.add(actor);
  }

  void closePeriod(String actor) {
    require(actor == treasurer, 'Chỉ quản lý được chốt kỳ.');
    require(
      !entries.any((e) => e.status == EntryStatus.pending),
      'Còn khoản chờ xác nhận.',
    );
    require(
      !feedback.any((f) => f['status'] == 'open'),
      'Còn phản hồi chưa xử lý.',
    );
    final b = balances;
    periods.add({
      'number': workflow['period'],
      'closedAt': DateTime.now().toIso8601String(),
      'frequency': workflow['frequency'],
      'policyVersion': workflow['policyVersion'],
      'balances': Map<String, int>.from(b.personal),
      'cash': b.cash,
      'available': b.available,
      'entryIds': entries.map((e) => e.id).toList(),
    });
    workflow['period'] = (workflow['period'] as int) + 1;
    final p = workflow['proposal'];
    if (p != null &&
        members.every((m) => (p['votes'] as List).contains(m.id))) {
      workflow['frequency'] = p['frequency'];
      workflow['policyVersion'] = (workflow['policyVersion'] as int) + 1;
      workflow.remove('proposal');
    }
    notifications.add({
      'key': 'period:${workflow['period']}',
      'text':
          'Đã chốt kỳ ${workflow['period'] - 1}. Công nợ được giữ nguyên sang kỳ mới.',
    });
  }

  void remind(String actor) {
    require(hasMember(actor), 'Không thuộc nhóm.');
    require(
      (workflow['reminderPrefs'] as Map?)?[actor] != false,
      'Đã tắt nhắc tiền.',
    );
    require(
      !entries.any(
        (e) =>
            e.kind == EntryKind.payment &&
            e.payer == actor &&
            e.status == EntryStatus.pending,
      ),
      'Khoản chuyển đang chờ xác nhận; không nhắc trả lần nữa.',
    );
    final owe = directTransfers
        .where((t) => t.from == actor)
        .fold<int>(0, (s, t) => s + t.amount);
    require(owe > 0, 'Không còn khoản cần trả.');
    final key = 'reminder:$actor:${workflow['period']}:$owe';
    if (notifications.any((n) => n['key'] == key)) return;
    notifications.add({
      'key': key,
      'text':
          '${memberName(actor)} còn cần trả $owe VND. Xem Công nợ để biết người nhận.',
    });
  }
}
