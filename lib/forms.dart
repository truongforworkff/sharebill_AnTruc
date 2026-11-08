import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'ledger.dart';

String money(int amount) {
  final digits = amount.abs().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return '${amount < 0 ? '−' : ''}$digits đ';
}

Future<String> readEvidence(XFile file) async {
  require(await file.length() <= 2 * 1024 * 1024, 'Chọn ảnh dưới 2 MB.');
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: 600,
    allowUpscaling: false,
  );
  final frame = await codec.getNextFrame();
  frame.image.dispose();
  codec.dispose();
  return base64Encode(bytes);
}

class EvidencePicker extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const EvidencePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });
  @override
  State<EvidencePicker> createState() => _EvidencePickerState();
}

class _EvidencePickerState extends State<EvidencePicker> {
  bool busy = false;
  Future<void> pick() async {
    setState(() => busy = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
        requestFullMetadata: false,
      );
      if (file != null) {
        final value = await readEvidence(file);
        if (mounted) widget.onChanged(value);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không đọc được ảnh. Chọn ảnh JPG hoặc PNG dưới 2 MB.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (widget.value != null) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            base64Decode(widget.value!),
            height: 160,
            fit: BoxFit.contain,
            semanticLabel: 'Chứng từ đã chọn',
          ),
        ),
        TextButton(
          onPressed: busy ? null : () => widget.onChanged(null),
          child: const Text('Bỏ ảnh này'),
        ),
      ],
      OutlinedButton.icon(
        onPressed: busy ? null : pick,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(
          busy
              ? 'Đang đọc ảnh…'
              : widget.value == null
              ? 'Thêm ảnh bill hoặc chuyển khoản'
              : 'Chọn ảnh khác',
        ),
      ),
      const Text(
        'Ảnh là chứng từ tham khảo. Bản thử nghiệm chưa tự đọc số tiền hoặc xác thực ngân hàng.',
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
    ],
  );
}

Widget amountField(
  TextEditingController controller, {
  VoidCallback? onChanged,
}) => TextField(
  controller: controller,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],
  decoration: const InputDecoration(
    labelText: 'Số tiền (VND)',
    hintText: 'Ví dụ 800000',
    suffixText: 'đ',
  ),
  onChanged: (_) => onChanged?.call(),
);

class ExpensePage extends StatefulWidget {
  final BillGroup group;
  final String actor;
  final String? recoveredEvidence;
  final Future<void> Function(void Function(BillGroup)) save;
  const ExpensePage({
    super.key,
    required this.group,
    required this.actor,
    required this.save,
    this.recoveredEvidence,
  });
  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final title = TextEditingController();
  final amount = TextEditingController();
  final id = newId();
  late Set<String> selected;
  String payer = fundId;
  String? evidence, error;
  bool busy = false;
  bool get all => selected.length == widget.group.members.length;
  @override
  void initState() {
    super.initState();
    selected = widget.group.members.map((m) => m.id).toSet();
    evidence = widget.recoveredEvidence;
  }

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final value = int.tryParse(amount.text) ?? 0;
      await widget.save(
        (group) => group.addExpense(
          id: id,
          actor: widget.actor,
          title: title.text,
          amount: value,
          payer: payer,
          participants: selected.toList(),
          evidence: evidence,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is RuleError
              ? e.message
              : 'Chưa lưu được. Dữ liệu nhập vẫn còn, hãy thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = int.tryParse(amount.text) ?? 0;
    final ordered = widget.group.members
        .where((m) => selected.contains(m.id))
        .map((m) => m.id)
        .toList();
    final shares = value > 0 && value <= maxAmount && ordered.isNotEmpty
        ? splitEqually(value, ordered)
        : <String, int>{};
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm khoản chi')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AbsorbPointer(
            absorbing: busy,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: title,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Ăn gì, chơi ở đâu?',
                    hintText: 'Bữa tối cuối tuần',
                  ),
                ),
                const SizedBox(height: 12),
                amountField(amount, onChanged: () => setState(() {})),
                const SizedBox(height: 20),
                EvidencePicker(
                  value: evidence,
                  onChanged: (v) => setState(() => evidence = v),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ai tham gia? (${selected.length}/${widget.group.members.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        selected = all
                            ? {}
                            : widget.group.members.map((m) => m.id).toSet();
                        if (!all && payer == fundId) payer = widget.actor;
                      }),
                      child: Text(all ? 'Bỏ chọn' : 'Chọn tất cả'),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.group.members
                      .map(
                        (m) => FilterChip(
                          label: Text(m.name),
                          selected: selected.contains(m.id),
                          onSelected: (yes) => setState(() {
                            yes ? selected.add(m.id) : selected.remove(m.id);
                            if (!all && payer == fundId) payer = widget.actor;
                          }),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Card(
                  color: all
                      ? const Color(0xffe3f3ec)
                      : const Color(0xfffff1d9),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      all
                          ? 'Đủ nhóm • Quỹ chịu chi phí\nKhả dụng: ${money(widget.group.balances.available)}'
                          : 'Đi một phần nhóm • Chia tiền cá nhân\nKhông sử dụng quỹ chung.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('payer-$payer-$all'),
                  initialValue: payer,
                  decoration: const InputDecoration(
                    labelText: 'Tiền thực tế lấy từ đâu?',
                  ),
                  isExpanded: true,
                  items: [
                    if (all)
                      const DropdownMenuItem(
                        value: fundId,
                        child: Text('Quỹ chung'),
                      ),
                    ...widget.group.members.map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text('${m.name} trả trước'),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => payer = v!),
                ),
                if (all && payer != fundId)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Ghi quỹ cần hoàn cho người ứng. Chỉ giảm tiền quỹ thực có khi hoàn tiền được xác nhận.',
                    ),
                  ),
                if (all &&
                    payer == fundId &&
                    widget.actor != widget.group.treasurer)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Khoản chi này sẽ chờ thủ quỹ xác nhận.'),
                  ),
                if (shares.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    all
                        ? 'Chi phí tương đương mỗi người (không ghi nợ)'
                        : 'Phần tiền mỗi người',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...shares.entries.map(
                    (s) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(widget.group.memberName(s.key)),
                      trailing: Text(money(s.value)),
                    ),
                  ),
                  const Text(
                    'Nếu có tiền lẻ, 1đ dư được chia theo thứ tự thành viên.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: busy ? null : submit,
                  icon: const Icon(Icons.check),
                  label: Text(busy ? 'Đang lưu…' : 'Chốt khoản chi'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final BillGroup group;
  final String actor, receiver;
  final EntryKind kind;
  final int? initialAmount;
  final Future<void> Function(void Function(BillGroup)) save;
  const PaymentPage({
    super.key,
    required this.group,
    required this.actor,
    required this.receiver,
    required this.kind,
    required this.save,
    this.initialAmount,
  });
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final amount = TextEditingController(
    text: widget.initialAmount?.toString() ?? '',
  );
  final id = newId();
  String? evidence, error;
  bool busy = false;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.save(
        (g) => g.request(
          id: id,
          kind: widget.kind,
          actor: widget.actor,
          receiver: widget.receiver,
          amount: int.tryParse(amount.text) ?? 0,
          evidence: evidence,
        ),
      );
      if (mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.kind) {
      EntryKind.deposit => 'Nộp quỹ',
      EntryKind.refund => 'Quỹ hoàn ứng',
      _ => 'Trả nợ',
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AbsorbPointer(
            absorbing: busy,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '${widget.kind == EntryKind.refund ? 'Quỹ chung' : widget.group.memberName(widget.actor)} → ${widget.group.memberName(widget.receiver)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                amountField(amount),
                const SizedBox(height: 24),
                EvidencePicker(
                  value: evidence,
                  onChanged: (v) => setState(() => evidence = v),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Gửi yêu cầu không làm đổi số dư. Người nhận hoặc thủ quỹ cần kiểm tra tiền thực nhận và xác nhận. Có thể trả một phần.',
                ),
                if (widget.kind == EntryKind.deposit &&
                    widget.actor == widget.group.treasurer)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Thủ quỹ tự nộp và tự xác nhận chỉ là mô phỏng, không phải kiểm chứng độc lập.',
                    ),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : submit,
                  child: Text(busy ? 'Đang lưu…' : 'Gửi để xác nhận'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});
  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final name = TextEditingController(),
      people = TextEditingController(text: 'Bạn\nHuy\nBình');
  String? error;
  @override
  void dispose() {
    name.dispose();
    people.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tạo nhóm')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: name,
          maxLength: 80,
          decoration: const InputDecoration(labelText: 'Tên nhóm'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: people,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Thành viên — mỗi dòng một người',
            helperText:
                'Người đầu tiên là bạn và quản lý nhóm mẫu. Tên có thể trùng.',
          ),
        ),
        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),
        FilledButton(
          onPressed: () {
            try {
              final labels = people.text
                  .split('\n')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              final members = labels
                  .asMap()
                  .entries
                  .map(
                    (e) => Member(
                      newId(),
                      e.value,
                      accountId: e.key == 0 ? 'local-me' : null,
                    ),
                  )
                  .toList();
              require(members.length >= 2, 'Cần ít nhất hai thành viên.');
              Navigator.pop(
                context,
                BillGroup(
                  id: newId(),
                  name: name.text.trim(),
                  treasurer: members.first.id,
                  members: members,
                ),
              );
            } catch (e) {
              setState(() => error = e.toString());
            }
          },
          child: const Text('Tạo nhóm'),
        ),
      ],
    ),
  );
}
