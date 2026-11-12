import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';

import 'demo.dart';
import 'forms.dart';
import 'ledger.dart';
import 'repository.dart';
import 'members_page.dart';
import 'workflow_page.dart';
import 'statement_page.dart';
import 'notification_sticker.dart';
import 'notifications_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShareBillApp());
}

class ShareBillApp extends StatelessWidget {
  final BillRepository? repository;
  const ShareBillApp({super.key, this.repository});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Share Bill',
    debugShowCheckedModeBanner: false,
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xfff7f8fc),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff4148bc)),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xfff7f8fc)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    home: repository != null
        ? HomePage(repository: repository!)
        : const _Boot(),
  );
}

class _Boot extends StatefulWidget {
  const _Boot();
  @override
  State<_Boot> createState() => _BootState();
}

class _BootState extends State<_Boot> {
  late Future<BillRepository> future = openBillDatabase().then(
    BillRepository.new,
  );
  @override
  Widget build(BuildContext context) => FutureBuilder<BillRepository>(
    future: future,
    builder: (context, snap) {
      if (snap.hasData) return HomePage(repository: snap.data!);
      if (snap.hasError) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Chưa mở được dữ liệu trên máy. Dữ liệu cũ chưa bị thay đổi.',
                  ),
                  FilledButton(
                    onPressed: () => setState(
                      () =>
                          future = openBillDatabase().then(BillRepository.new),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
  );
}

class HomePage extends StatefulWidget {
  final BillRepository repository;
  const HomePage({super.key, required this.repository});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BillGroup> groups = [];
  String? groupId, actor, loadError, recovered;
  final scrollController = ScrollController();
  int tab = 0;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void resetScroll() {
    if (scrollController.hasClients) scrollController.jumpTo(0);
  }

  bool loading = true, busy = false;
  BillGroup? get group => groups.where((g) => g.id == groupId).firstOrNull;
  @override
  void initState() {
    super.initState();
    load();
    recoverImage();
  }

  Future<void> recoverImage() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final response = await ImagePicker().retrieveLostData();
      if (response.files?.isNotEmpty == true) {
        final image = await readEvidence(response.files!.first);
        if (mounted) setState(() => recovered = image);
      }
    } catch (_) {
      if (mounted) {
        message('Không khôi phục được ảnh đã chọn. Bạn có thể chọn lại ảnh.');
      }
    }
  }

  Future<void> load() async {
    try {
      final result = await widget.repository.groups();
      if (!mounted) return;
      setState(() {
        groups = result;
        if (!groups.any((g) => g.id == groupId)) {
          groupId = groups.firstOrNull?.id;
        }
        if (group != null && !group!.hasMember(actor ?? '')) {
          actor = group!.treasurer;
        }
        loadError = null;
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          loadError =
              'Không đọc được dữ liệu. Không ghi đè dữ liệu cũ; hãy thử tải lại.';
        });
      }
    }
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> saveFor(String id, void Function(BillGroup) change) async {
    await widget.repository.update(id, change);
    await load();
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        message(
          e is RuleError
              ? e.message
              : 'Chưa lưu được thay đổi. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> addGroup({bool demo = false}) async {
    final created = demo
        ? demoGroup()
        : await Navigator.push<BillGroup>(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupPage()),
          );
    if (created == null || !mounted) return;
    await run(() async {
      await widget.repository.create(created);
      groupId = created.id;
      actor = created.treasurer;
      tab = 0;
      await load();
    });
  }

  Future<void> expense() async {
    final g = group!;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpensePage(
          group: g,
          actor: actor!,
          recoveredEvidence: recovered,
          save: (change) => saveFor(g.id, change),
        ),
      ),
    );
    if (mounted) setState(() => recovered = null);
  }

  void payment(EntryKind kind, String receiver, {int? amount}) {
    final g = group!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          group: g,
          actor: actor!,
          receiver: receiver,
          kind: kind,
          initialAmount: amount,
          save: (change) => saveFor(g.id, change),
        ),
      ),
    );
  }

  Future<String?> reasonDialog(String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLength: 300,
          decoration: const InputDecoration(
            labelText: 'Lý do',
            helperText: 'Được giữ lại trong lịch sử',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    // Dialog may still be animating when its route completes.
    Future<void>.delayed(const Duration(seconds: 1), controller.dispose);
    return result;
  }

  Widget totals(BillGroup g, String person) {
    final summary = g.totalsFor(person);
    final owe = summary.owe, receive = summary.receive;
    return Row(
      children: [
        Expanded(child: metric('Tổng nợ', owe, Colors.deepOrange)),
        const SizedBox(width: 10),
        Expanded(
          child: metric('Tổng cần thu', receive, const Color(0xff4148bc)),
        ),
      ],
    );
  }

  Widget metric(String label, int amount, Color color) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              money(amount),
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget entryTile(Entry e, {bool readonly = false}) => Card(
    child: ExpansionTile(
      title: Text(e.title),
      subtitle: Text(
        '${money(e.amount)} · ${switch (e.status) {
          EntryStatus.pending => 'Chờ xác nhận',
          EntryStatus.confirmed => 'Đã ghi nhận',
          EntryStatus.rejected => 'Đã từ chối',
        }}',
      ),
      children: [
        ListTile(
          title: Text(
            '${group!.memberName(e.payer)}${e.receiver.isNotEmpty ? ' → ${group!.memberName(e.receiver)}' : ''}',
          ),
          subtitle: Text(
            'Ngày phát sinh: ${e.occurredOn ?? e.createdAt.substring(0, 10)}\nGhi sổ: ${e.createdAt}',
          ),
        ),
        if (e.note.isNotEmpty) ListTile(title: Text(e.note)),
        if (e.kind == EntryKind.expense)
          ...splitEqually(e.amount, e.participants).entries.map(
            (s) => ListTile(
              dense: true,
              title: Text(group!.memberName(s.key)),
              trailing: Text(money(s.value)),
            ),
          ),
        if (e.evidence != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Image.memory(
              base64Decode(e.evidence!),
              height: 220,
              fit: BoxFit.contain,
            ),
          ),
        if (e.reason != null) ListTile(title: Text(e.reason!)),
        if (!readonly && e.status == EntryStatus.pending)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  'Cần ${group!.memberName(group!.reviewer(e))} xác nhận. Đổi vai trong menu để thử.',
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: busy || actor != group!.reviewer(e)
                          ? null
                          : () => run(
                              () => saveFor(
                                group!.id,
                                (g) => g.review(e.id, actor!, accept: true),
                              ),
                            ),
                      child: const Text('Xác nhận nhận tiền'),
                    ),
                    TextButton(
                      onPressed: busy || actor != group!.reviewer(e)
                          ? null
                          : () async {
                              final reason = await reasonDialog(
                                'Lý do từ chối',
                              );
                              if (reason != null) {
                                await run(
                                  () => saveFor(
                                    group!.id,
                                    (g) => g.review(
                                      e.id,
                                      actor!,
                                      accept: false,
                                      reason: reason,
                                    ),
                                  ),
                                );
                              }
                            },
                      child: const Text('Từ chối'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    ),
  );
  List<Widget> debtWidgets(
    BillGroup g,
    String who, {
    bool readonly = false,
  }) => [
    totals(g, who),
    OutlinedButton.icon(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StatementPage(group: g, member: who),
        ),
      ),
      icon: const Icon(Icons.receipt_long_outlined),
      label: const Text('Vì sao có số tiền này?'),
    ),
    if (!g.directTransfers.any((t) => t.from == who || t.to == who))
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Bạn không còn công nợ cá nhân trong nhóm này.'),
      ),
    const SizedBox(height: 16),
    const Text(
      'Nợ ai · Ai nợ mình',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    ...g.directTransfers
        .where((t) => t.from == who || t.to == who)
        .map(
          (t) => Card(
            child: ListTile(
              title: Text(
                t.from == who
                    ? 'Bạn nợ ${g.memberName(t.to)}'
                    : '${g.memberName(t.from)} nợ bạn',
              ),
              subtitle: Text('${money(t.amount)} · Chạm để xem nguồn gốc'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatementPage(
                    group: g,
                    member: who,
                    counterparty: t.from == who ? t.to : t.from,
                  ),
                ),
              ),
              trailing: !readonly && t.from == who
                  ? TextButton(
                      onPressed: () =>
                          payment(EntryKind.payment, t.to, amount: t.amount),
                      child: const Text('Ghi trả nợ'),
                    )
                  : null,
            ),
          ),
        ),
    const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Hai tổng giữ riêng từng chiều. Khoản chờ xác nhận chưa được trừ nợ.',
      ),
    ),
  ];
  List<Widget> fundWidgets({bool readonly = false}) {
    final g = group!, b = g.balances;
    return [
      metric('Quỹ khả dụng', b.available, const Color(0xff4148bc)),
      if (b.available < 0)
        Text('Quỹ còn thiếu ${money(-b.available)} để hoàn đủ tiền ứng.'),
      ListTile(
        title: const Text('Tiền thực có'),
        trailing: Text(money(b.cash)),
      ),
      ListTile(
        title: const Text('Cần hoàn ứng'),
        trailing: Text(money(b.liability)),
      ),
      if (!readonly)
        FilledButton.icon(
          onPressed: () => payment(EntryKind.deposit, fundId),
          icon: const Icon(Icons.add),
          label: const Text('Nộp quỹ'),
        ),
      ...b.owedByFund.entries
          .where((e) => e.value > 0)
          .map(
            (e) => ListTile(
              title: Text('Quỹ cần hoàn ${g.memberName(e.key)}'),
              subtitle: Text(money(e.value)),
              trailing: !readonly && actor == g.treasurer
                  ? TextButton(
                      onPressed: () =>
                          payment(EntryKind.refund, e.key, amount: e.value),
                      child: const Text('Hoàn ứng'),
                    )
                  : null,
            ),
          ),
      const Text(
        'Chỉ dùng quỹ khi đủ thành viên của nhóm tại thời điểm tạo bill.',
      ),
      ...g.entries.reversed
          .where(
            (e) =>
                e.fundExpense ||
                e.kind == EntryKind.deposit ||
                e.kind == EntryKind.refund,
          )
          .map((e) => entryTile(e, readonly: readonly)),
    ];
  }

  void myGroups() {
    final current = group!.members.firstWhere((m) => m.id == actor);
    final rows = <({BillGroup group, Member me})>[];
    for (final g in groups) {
      final me = current.accountId == null
          ? (g.id == groupId ? current : null)
          : g.members
                .where((m) => m.accountId == current.accountId)
                .firstOrNull;
      if (me != null) rows.add((group: g, me: me));
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Nhóm của tôi')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${rows.length} nhóm · ${current.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text('Công nợ và quỹ được giữ riêng trong từng nhóm.'),
              ...rows.map(
                (r) => Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        groupId = r.group.id;
                        actor = r.me.id;
                        tab = 0;
                        resetScroll();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(r.group.name),
                            subtitle: Text(
                              '${r.group.members.length} thành viên · ${r.me.id == r.group.treasurer ? 'Quản lý / thủ quỹ' : 'Thành viên'}',
                            ),
                            trailing: Icon(
                              r.group.id == groupId
                                  ? Icons.check_circle
                                  : Icons.chevron_right,
                            ),
                          ),
                          totals(r.group, r.me.id),
                          Text(
                            'Quỹ khả dụng: ${money(r.group.balances.available)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void contactView() {
    final account = group!.members.firstWhere((m) => m.id == actor).accountId;
    if (account == null) {
      message('Hồ sơ chưa liên kết tài khoản; chưa tổng hợp xuyên nhóm.');
      return;
    }
    final contacts =
        <
          String,
          ({String name, List<({BillGroup group, int owe, int receive})> rows})
        >{};
    for (final g in groups) {
      final me = g.members.where((m) => m.accountId == account).firstOrNull;
      if (me == null) continue;
      for (final m in g.members.where((m) => m.id != me.id)) {
        final key = m.accountId ?? 'guest:${g.id}:${m.id}';
        final owe = g.directTransfers
            .where((t) => t.from == me.id && t.to == m.id)
            .fold<int>(0, (s, t) => s + t.amount);
        final receive = g.directTransfers
            .where((t) => t.to == me.id && t.from == m.id)
            .fold<int>(0, (s, t) => s + t.amount);
        final c = contacts.putIfAbsent(key, () => (name: m.name, rows: []));
        c.rows.add((group: g, owe: owe, receive: receive));
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Công nợ với từng người')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Tổng hợp theo tài khoản đã liên kết. Không tự tất toán giữa các nhóm.',
              ),
              ...contacts.values
                  .where((c) => c.rows.any((r) => r.owe > 0 || r.receive > 0))
                  .map((c) {
                    final owe = c.rows.fold<int>(0, (s, r) => s + r.owe),
                        receive = c.rows.fold<int>(0, (s, r) => s + r.receive);
                    return Card(
                      child: ExpansionTile(
                        title: Text(c.name),
                        subtitle: Text(
                          '${c.rows.length} nhóm chung\nBạn nợ ${money(owe)} · Nợ bạn ${money(receive)}',
                        ),
                        children: [
                          ListTile(
                            title: Text('Chênh lệch: ${money(receive - owe)}'),
                            subtitle: const Text(
                              'Dương: được nhận · Âm: cần trả',
                            ),
                          ),
                          ...c.rows.map(
                            (r) => ListTile(
                              title: Text(r.group.name),
                              subtitle: Text(
                                'Bạn nợ ${money(r.owe)} · Nợ bạn ${money(r.receive)}',
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  groupId = r.group.id;
                                  actor = r.group.members
                                      .firstWhere((m) => m.accountId == account)
                                      .id;
                                  tab = 2;
                                  resetScroll();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> membersPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MembersPage(
          repository: widget.repository,
          groupId: group!.id,
          actor: actor!,
        ),
      ),
    );
    await load();
  }

  @override
  Widget build(BuildContext context) {
    final g = group;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'chung.',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Thông báo',
            icon: const NotificationSticker(
              kind: NoticeKind.reminder,
              size: 36,
              decorative: true,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationsPage(
                  notices:
                      g?.notifications
                          .map((n) => Map<String, dynamic>.from(n as Map))
                          .toList() ??
                      const [],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => addGroup(),
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Tạo nhóm',
          ),
          if (g != null)
            PopupMenuButton<String>(
              tooltip: 'Đổi vai thử nghiệm',
              onSelected: (v) => setState(() => actor = v),
              itemBuilder: (_) => g.members
                  .map(
                    (m) => PopupMenuItem(
                      value: m.id,
                      child: Text('Thử vai ${m.name}'),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      bottomNavigationBar: g == null
          ? null
          : NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (v) => setState(() {
                tab = v;
                resetScroll();
              }),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Tổng quan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  label: 'Quỹ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.swap_horiz),
                  label: 'Công nợ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'Hoạt động',
                ),
              ],
            ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loadError!),
                  FilledButton(onPressed: load, child: const Text('Thử lại')),
                ],
              ),
            )
          : g == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Chung cuộc vui. Rõ chuyện tiền.'),
                  FilledButton(
                    onPressed: () => addGroup(),
                    child: const Text('Tạo nhóm đầu tiên'),
                  ),
                  TextButton(
                    onPressed: () => run(() async {
                      for (final sample in demoGroups()) {
                        await widget.repository.create(sample);
                      }
                      await load();
                    }),
                    child: const Text('Khám phá 3 nhóm mẫu'),
                  ),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: AbsorbPointer(
                  absorbing: busy,
                  child: RefreshIndicator(
                    onRefresh: load,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey(groupId),
                          initialValue: groupId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Nhóm đang xem',
                          ),
                          items: groups
                              .map(
                                (x) => DropdownMenuItem(
                                  value: x.id,
                                  child: Text(
                                    x.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (id) => setState(() {
                            resetScroll();
                            final account = group!.members
                                .firstWhere((m) => m.id == actor)
                                .accountId;
                            groupId = id;
                            actor =
                                group!.members
                                    .where(
                                      (m) =>
                                          account != null &&
                                          m.accountId == account,
                                    )
                                    .firstOrNull
                                    ?.id ??
                                group!.treasurer;
                          }),
                        ),
                        TextButton.icon(
                          onPressed: myGroups,
                          icon: const Icon(Icons.groups_outlined),
                          label: const Text(
                            'Nhóm của tôi · Xem công nợ từng nhóm',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'BẢN THỬ NGHIỆM · Vai ${g.memberName(actor!)} · Lưu trên máy',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        if (tab == 0) ...[
                          Text(
                            'Chuyện tiền của nhóm',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Card(
                            color: const Color(0xff4148bc),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quỹ chung khả dụng',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 12),
                                  FittedBox(
                                    child: Text(
                                      money(g.balances.available),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          totals(g, actor!),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: expense,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm bill'),
                          ),
                          TextButton(
                            onPressed: contactView,
                            child: const Text('Với từng người · Tất cả nhóm →'),
                          ),
                          OutlinedButton.icon(
                            onPressed: membersPage,
                            icon: const Icon(Icons.group_outlined),
                            label: Text(
                              'Cả nhóm · ${g.members.length} người · Lời mời',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkflowPage(
                                    repository: widget.repository,
                                    groupId: g.id,
                                    actor: actor!,
                                  ),
                                ),
                              );
                              await load();
                            },
                            child: const Text(
                              'Chốt kỳ · Quy ước · Phản hồi · Nhắc tiền',
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Khoản chi gần đây',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...g.entries.reversed
                              .take(5)
                              .map((e) => entryTile(e)),
                        ] else if (tab == 1)
                          ...fundWidgets()
                        else if (tab == 2) ...[
                          ...debtWidgets(g, actor!),
                          OutlinedButton(
                            onPressed: contactView,
                            child: const Text('Công nợ xuyên nhóm'),
                          ),
                        ] else
                          ...g.entries.reversed.map((e) => entryTile(e)),
                        const SizedBox(height: 24),
                        const Text(
                          'Chưa kết nối ngân hàng. Đổi vai chỉ để thử xác nhận trên thiết bị này.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
