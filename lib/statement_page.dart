import 'dart:convert';
import 'package:flutter/material.dart';
import 'forms.dart';
import 'ledger.dart';

class StatementPage extends StatefulWidget {
  final BillGroup group;
  final String member;
  final String? counterparty;
  const StatementPage({
    super.key,
    required this.group,
    required this.member,
    this.counterparty,
  });
  @override
  State<StatementPage> createState() => _StatementPageState();
}

class _StatementPageState extends State<StatementPage> {
  late String? counterpart = widget.counterparty;
  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final lines = g.statement(widget.member, counterparty: counterpart);
    final total = lines.isEmpty ? 0 : lines.last.balance;
    return Scaffold(
      appBar: AppBar(title: const Text('Vì sao có số tiền này?')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(g.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: counterpart ?? '',
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Đối chiếu với'),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Tất cả thành viên'),
                  ),
                  ...g.members
                      .where((m) => m.id != widget.member)
                      .map(
                        (m) =>
                            DropdownMenuItem(value: m.id, child: Text(m.name)),
                      ),
                ],
                onChanged: (v) =>
                    setState(() => counterpart = v == '' ? null : v),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số dư ròng đã ghi nhận'),
                      Text(
                        money(total),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        total > 0
                            ? 'Bạn được nhận'
                            : total < 0
                            ? 'Bạn cần trả'
                            : 'Đã cân bằng',
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                'Dương: tăng phần được nhận hoặc giảm nợ. Âm: tăng nợ hoặc đã nhận tiền. Quỹ, khoản chờ, bị từ chối và đã đảo không tính vào bảng này.',
              ),
              const SizedBox(height: 12),
              if (lines.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Chưa có giao dịch công nợ đã ghi nhận.'),
                ),
              ...lines.map((line) {
                final e = line.entry;
                return Card(
                  child: ExpansionTile(
                    title: Text(e.title),
                    subtitle: Text(
                      '${line.delta > 0 ? '+' : ''}${money(line.delta)} · Sau khoản này: ${money(line.balance)}',
                    ),
                    children: [
                      ListTile(
                        title: Text(
                          '${g.memberName(e.payer)}${e.receiver.isEmpty ? '' : ' → ${g.memberName(e.receiver)}'}',
                        ),
                        subtitle: Text(
                          'Ngày phát sinh: ${e.occurredOn ?? e.createdAt.substring(0, 10)}\nGhi sổ: ${e.reviewedAt ?? e.createdAt}',
                        ),
                      ),
                      if (e.note.isNotEmpty) ListTile(title: Text(e.note)),
                      if (e.kind == EntryKind.expense)
                        ...splitEqually(e.amount, e.participants).entries.map(
                          (s) => ListTile(
                            title: Text(g.memberName(s.key)),
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
                      ListTile(
                        title: const Text('Mã giao dịch gốc'),
                        subtitle: SelectableText(e.id),
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
}
