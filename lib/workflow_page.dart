import 'package:flutter/material.dart';

import 'ledger.dart';
import 'repository.dart';
import 'forms.dart';

class WorkflowPage extends StatefulWidget {
  final BillRepository repository;
  final String groupId, actor;
  const WorkflowPage({
    super.key,
    required this.repository,
    required this.groupId,
    required this.actor,
  });
  @override
  State<WorkflowPage> createState() => _WorkflowPageState();
}

class _WorkflowPageState extends State<WorkflowPage> {
  BillGroup? group;
  String? error, entryId;
  late String actor = widget.actor;
  final reason = TextEditingController();
  bool busy = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final gs = await widget.repository.groups();
      if (mounted) {
        setState(() => group = gs.firstWhere((g) => g.id == widget.groupId));
      }
    } catch (_) {
      if (mounted) setState(() => error = 'Không đọc được dữ liệu.');
    }
  }

  Future<void> act(void Function(BillGroup) change) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.repository.update(widget.groupId, change);
      await load();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = group;
    return Scaffold(
      appBar: AppBar(title: const Text('Kỳ, quy ước & phản hồi')),
      body: g == null
          ? Center(child: Text(error ?? 'Đang tải…'))
          : AbsorbPointer(
              absorbing: busy,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: actor,
                    decoration: const InputDecoration(
                      labelText: 'Đổi vai mô phỏng',
                    ),
                    items: g.members
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => actor = v!),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Kỳ ${g.workflow['period']} · ${g.workflow['frequency'] == 'weekly' ? 'Hằng tuần' : 'Hằng tháng'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Chốt tạo bản lưu bất biến; sổ tiền tiếp tục cộng dồn, không cộng lại nợ. Khoản chờ và phản hồi mở sẽ chặn chốt.',
                  ),
                  FilledButton(
                    onPressed: actor != g.treasurer
                        ? null
                        : () => act((g) => g.closePeriod(actor)),
                    child: const Text('Chốt kỳ hiện tại'),
                  ),
                  ...g.periods.reversed.map(
                    (p) => ExpansionTile(
                      title: Text('Kỳ ${p['number']} · ${p['closedAt']}'),
                      children: [
                        ListTile(
                          title: Text(
                            'Quỹ khả dụng ${money(p['available'] as int)}',
                          ),
                        ),
                        ...(p['balances'] as Map).entries.map(
                          (e) => ListTile(
                            title: Text(g.memberName(e.key as String)),
                            trailing: Text(money(e.value as int)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Quy ước kỳ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Bản thử nghiệm: mọi thành viên đồng ý; áp dụng từ kỳ tiếp theo. Điều kiện đủ nhóm dùng quỹ không thay đổi.',
                  ),
                  if (g.workflow['proposal'] == null)
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: actor != g.treasurer
                              ? null
                              : () => act(
                                  (g) => g.proposeFrequency('weekly', actor),
                                ),
                          child: const Text('Đề xuất hằng tuần'),
                        ),
                        OutlinedButton(
                          onPressed: actor != g.treasurer
                              ? null
                              : () => act(
                                  (g) => g.proposeFrequency('monthly', actor),
                                ),
                          child: const Text('Đề xuất hằng tháng'),
                        ),
                      ],
                    )
                  else ...[
                    Text(
                      'Đề xuất: ${g.workflow['proposal']['frequency']} · ${(g.workflow['proposal']['votes'] as List).length}/${g.members.length} đồng ý',
                    ),
                    TextButton(
                      onPressed: () => act((g) => g.voteFrequency(actor)),
                      child: const Text('Đồng ý bằng vai đang chọn'),
                    ),
                  ],
                  const Divider(),
                  const Text(
                    'Phản hồi bill',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: entryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Bill cần kiểm tra',
                    ),
                    items: g.entries
                        .where((e) => e.kind == EntryKind.expense)
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(
                              e.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => entryId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reason,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Lý do / giải thích xử lý',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => act((g) {
                      require(entryId != null, 'Chọn bill.');
                      g.reportBill(entryId!, actor, reason.text);
                    }),
                    child: const Text('Gửi phản hồi'),
                  ),
                  ...g.feedback.map(
                    (f) => Card(
                      child: ListTile(
                        title: Text('${f['reason']}'),
                        subtitle: Text('${f['status']} ${f['reply'] ?? ''}'),
                        trailing: f['status'] == 'open'
                            ? TextButton(
                                onPressed: () => act(
                                  (g) => g.resolveReport(
                                    f['id'] as String,
                                    actor,
                                    reason.text,
                                  ),
                                ),
                                child: const Text('Giữ bill & trả lời'),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const Text(
                    'Nhánh điều chỉnh số tiền cũ cần quy trình đảo/ghi lại; không đóng phản hồi nếu chưa giải quyết.',
                  ),
                  const Divider(),
                  SwitchListTile(
                    value:
                        (g.workflow['reminderPrefs'] as Map?)?[actor] != false,
                    onChanged: (v) => act((g) {
                      g.workflow.putIfAbsent(
                        'reminderPrefs',
                        () => <String, dynamic>{},
                      );
                      g.workflow['reminderPrefs'][actor] = v;
                    }),
                    title: const Text('Nhắc tiền trong ứng dụng mẫu'),
                  ),
                  OutlinedButton(
                    onPressed: () => act((g) => g.remind(actor)),
                    child: const Text('Tạo nhắc theo công nợ hiện tại'),
                  ),
                  ...g.notifications.reversed.map(
                    (n) => ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: Text(n['text'] as String),
                    ),
                  ),
                  const Text(
                    'Thông báo cục bộ, chưa có push hoặc gửi ra ngoài.',
                  ),
                ],
              ),
            ),
    );
  }
}
