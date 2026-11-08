import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ledger.dart';
import 'repository.dart';
import 'forms.dart';

class MembersPage extends StatefulWidget {
  final BillRepository repository;
  final String groupId, actor;
  const MembersPage({
    super.key,
    required this.repository,
    required this.groupId,
    required this.actor,
  });
  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  BillGroup? group;
  String? token, error;
  bool preview = false, busy = false, asLeader = false;
  final account = TextEditingController(text: 'tai-khoan-moi'),
      name = TextEditingController(text: 'Huy');
  final choices = <String, String>{};
  String get actor => asLeader ? group!.treasurer : widget.actor;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    account.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final gs = await widget.repository.groups();
      if (mounted) {
        setState(() => group = gs.firstWhere((g) => g.id == widget.groupId));
      }
    } catch (_) {
      if (mounted) setState(() => error = 'Không tải được nhóm.');
    }
  }

  Future<void> change(void Function(BillGroup) action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.repository.update(widget.groupId, action);
      await load();
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is RuleError
              ? e.message
              : 'Chưa lưu được. Hãy thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget guest(BillGroup g) {
    try {
      final l = g.invitation(token!);
      if (l['memberId'] == null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Link chung · Chưa có quyền xem nhóm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Tài khoản dưới đây là mô phỏng. Sản phẩm thật lấy từ phiên đăng nhập.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Tên hiển thị'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: account,
              decoration: const InputDecoration(labelText: 'Tài khoản mẫu'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => change(
                (g) => g.requestJoin(token!, account.text.trim(), name.text),
              ),
              child: const Text('Gửi yêu cầu tham gia'),
            ),
            ...g.joinRequests
                .where((r) => r['accountId'] == account.text.trim())
                .map(
                  (r) => ListTile(
                    title: Text(switch (r['status']) {
                      'approved' => 'Đã được duyệt',
                      'rejected' => 'Đã từ chối',
                      _ => 'Đang chờ trưởng nhóm',
                    }),
                  ),
                ),
            TextButton(
              onPressed: () => setState(() {
                preview = false;
                asLeader = true;
                token = null;
              }),
              child: const Text('Mô phỏng trưởng nhóm duyệt'),
            ),
          ],
        );
      }
      final m = g.guestMember(token!), ts = g.directTransfers;
      final owe = ts
              .where((t) => t.from == m.id)
              .fold<int>(0, (s, t) => s + t.amount),
          receive = ts
              .where((t) => t.to == m.id)
              .fold<int>(0, (s, t) => s + t.amount);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            g.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Hồ sơ ${m.name} · Không cần đăng ký'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Bạn nợ ${money(owe)}\nNợ bạn ${money(receive)}\nQuỹ khả dụng ${money(g.balances.available)}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          ExpansionTile(
            title: const Text('Thành viên'),
            children: g.members
                .map((x) => ListTile(title: Text(x.name)))
                .toList(),
          ),
          ExpansionTile(
            title: const Text('Công nợ của bạn'),
            children: ts
                .where((t) => t.from == m.id || t.to == m.id)
                .map(
                  (t) => ListTile(
                    title: Text(
                      '${g.memberName(t.from)} → ${g.memberName(t.to)}',
                    ),
                    trailing: Text(money(t.amount)),
                  ),
                )
                .toList(),
          ),
          ExpansionTile(
            title: const Text('Quỹ và tiền ứng'),
            children: [
              ListTile(
                title: const Text('Tiền thực có'),
                trailing: Text(money(g.balances.cash)),
              ),
              ...g.balances.owedByFund.entries
                  .where((e) => e.value > 0)
                  .map(
                    (e) => ListTile(
                      title: Text('Cần hoàn ${g.memberName(e.key)}'),
                      trailing: Text(money(e.value)),
                    ),
                  ),
            ],
          ),
          ...g.entries.reversed.map(
            (e) => ExpansionTile(
              title: Text(e.title),
              subtitle: Text('${money(e.amount)} · ${e.status.name}'),
              children: [
                ListTile(
                  title: Text(g.memberName(e.payer)),
                  subtitle: Text(
                    'Ngày phát sinh: ${e.occurredOn ?? e.createdAt.substring(0, 10)}',
                  ),
                ),
                if (e.note.isNotEmpty) ListTile(title: Text(e.note)),
                if (e.evidence != null)
                  Image.memory(
                    base64Decode(e.evidence!),
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                if (e.kind == EntryKind.expense)
                  ...splitEqually(e.amount, e.participants).entries.map(
                    (s) => ListTile(
                      title: Text(g.memberName(s.key)),
                      trailing: Text(money(s.value)),
                    ),
                  ),
              ],
            ),
          ),
          if (m.accountId == null) ...[
            const SizedBox(height: 16),
            TextField(
              controller: account,
              decoration: const InputDecoration(
                labelText: 'Tài khoản đăng ký mẫu',
              ),
            ),
            FilledButton(
              onPressed: () async {
                await change(
                  (g) => g.claimProfile(token!, account.text.trim()),
                );
                if (error == null && mounted) {
                  setState(() {
                    preview = false;
                    token = null;
                  });
                }
              },
              child: const Text('Đăng ký & giữ hồ sơ'),
            ),
          ],
          const Text(
            'Chỉ xem qua link. Không cấp quyền sửa hoặc xác nhận tiền. Link được chuyển tiếp cũng cho phép xem.',
          ),
        ],
      );
    } catch (e) {
      return Text(e.toString(), style: const TextStyle(color: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = group;
    return Scaffold(
      appBar: AppBar(title: const Text('Thành viên & lời mời')),
      body: g == null
          ? Center(
              child: error != null
                  ? Text(error!)
                  : const CircularProgressIndicator(),
            )
          : AbsorbPointer(
              absorbing: busy,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  if (preview) ...[
                    guest(g),
                    TextButton(
                      onPressed: () => setState(() => preview = false),
                      child: const Text('Thoát xem thử'),
                    ),
                  ] else ...[
                    const Text(
                      'Link và tài khoản chỉ mô phỏng trên máy này, chưa gửi lời mời thật.',
                      style: TextStyle(fontSize: 12),
                    ),
                    if (actor != g.treasurer)
                      TextButton(
                        onPressed: () => setState(() => asLeader = true),
                        child: const Text('Thử vai trưởng nhóm'),
                      ),
                    FilledButton(
                      onPressed: actor != g.treasurer
                          ? null
                          : () => change((g) {
                              token = g.createInvite(actor);
                            }),
                      child: const Text('Tạo link chung'),
                    ),
                    if (token != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Link minh họa · hiệu lực 7 ngày'),
                              SelectableText('sharebill://demo/${g.id}/$token'),
                              TextButton(
                                onPressed: () => Clipboard.setData(
                                  ClipboardData(
                                    text: 'sharebill://demo/${g.id}/$token',
                                  ),
                                ),
                                child: const Text('Sao chép link mẫu'),
                              ),
                              FilledButton(
                                onPressed: () => setState(() => preview = true),
                                child: const Text('Xem thử người nhận'),
                              ),
                              TextButton(
                                onPressed: () => change(
                                  (g) => g.revokeInvite(token!, actor),
                                ),
                                child: const Text('Thu hồi link'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ...g.members.asMap().entries.map((entry) {
                      final m = entry.value;
                      return Card(
                        child: ListTile(
                          title: Text(m.name),
                          subtitle: Text(
                            'Hồ sơ ${entry.key + 1} · ${m.accountId == null ? 'Chưa đăng ký' : 'Có tài khoản'}',
                          ),
                          trailing: TextButton(
                            onPressed: actor != g.treasurer
                                ? null
                                : () => change((g) {
                                    token = g.createInvite(
                                      actor,
                                      memberId: m.id,
                                    );
                                  }),
                            child: const Text('Link riêng'),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    const Text(
                      'Yêu cầu tham gia',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...g.joinRequests.map(
                      (r) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('${r['name']} · ${r['accountId']}'),
                              Text(switch (r['status']) {
                                'approved' => 'Đã duyệt',
                                'rejected' => 'Đã từ chối',
                                _ => 'Chờ duyệt',
                              }),
                              if (r['status'] == 'pending') ...[
                                DropdownButtonFormField<String>(
                                  initialValue: choices[r['id']],
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Chọn hồ sơ hoặc người mới',
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'new',
                                      child: Text('Tạo thành viên mới'),
                                    ),
                                    ...g.members
                                        .where((m) => m.accountId == null)
                                        .map(
                                          (m) => DropdownMenuItem(
                                            value: m.id,
                                            child: Text(
                                              '${m.name} · hồ sơ ${g.members.indexOf(m) + 1}',
                                            ),
                                          ),
                                        ),
                                  ],
                                  onChanged: (v) => setState(
                                    () => choices[r['id'] as String] = v!,
                                  ),
                                ),
                                FilledButton(
                                  onPressed: actor != g.treasurer
                                      ? null
                                      : () {
                                          final choice = choices[r['id']];
                                          if (choice == null) {
                                            setState(
                                              () => error =
                                                  'Chọn hồ sơ hoặc người mới trước khi duyệt.',
                                            );
                                            return;
                                          }
                                          change(
                                            (g) => g.reviewJoin(
                                              r['id'] as String,
                                              actor,
                                              accept: true,
                                              memberId: choice == 'new'
                                                  ? null
                                                  : choice,
                                            ),
                                          );
                                        },
                                  child: const Text('Duyệt'),
                                ),
                                TextButton(
                                  onPressed: actor != g.treasurer
                                      ? null
                                      : () => change(
                                          (g) => g.reviewJoin(
                                            r['id'] as String,
                                            actor,
                                            accept: false,
                                          ),
                                        ),
                                  child: const Text('Từ chối'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
