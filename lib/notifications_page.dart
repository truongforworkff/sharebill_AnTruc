import 'package:flutter/material.dart';
import 'notification_sticker.dart';

class NoticeCard extends StatelessWidget {
  final NoticeKind kind;
  final String text;
  final bool example;
  const NoticeCard({
    super.key,
    required this.kind,
    required this.text,
    this.example = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xffeae6f2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationSticker(kind: kind, size: 64, decorative: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                example ? 'MẪU MINH HỌA · ${kind.label}' : kind.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xff706780),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kind.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff332c51),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: const TextStyle(height: 1.45, color: Color(0xff5c566d)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class NotificationsPage extends StatefulWidget {
  final List<Map<String, dynamic>> notices;
  const NotificationsPage({super.key, this.notices = const []});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool gallery = false;
  NoticeKind selected = NoticeKind.reminder;
  static const samples = {
    NoticeKind.reminder:
        'Bạn còn khoản cần trả. Mở Công nợ để xem đúng người nhận nhé.',
    NoticeKind.received:
        'Người nhận đã xác nhận khoản thanh toán. Công nợ đã được cập nhật.',
    NoticeKind.fund:
        'Khoản nộp quỹ đã được xác nhận. Cả hội lại có thêm ngân sách ăn ngon.',
    NoticeKind.period:
        'Kỳ này đã chốt. Khoản còn nợ được giữ sang kỳ sau, không cộng thêm lần nữa.',
    NoticeKind.pending:
        'Khoản chuyển đang chờ người nhận xác nhận. Chưa cần chuyển lại đâu nha.',
    NoticeKind.feedback:
        'Có phản hồi về khoản chia. Cùng kiểm tra bill trước khi chốt kỳ nhé.',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thông báo')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHUNG NHẮN NHẸ',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff777089),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tiền nong,\nbớt căng.',
                        style: TextStyle(
                          fontSize: 32,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                          color: Color(0xff332c51),
                        ),
                      ),
                    ],
                  ),
                ),
                const NotificationSticker(
                  kind: NoticeKind.reminder,
                  size: 100,
                  decorative: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Hộp thư'),
                  icon: Icon(Icons.inbox_outlined),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Bộ sticker'),
                  icon: Icon(Icons.auto_awesome_outlined),
                ),
              ],
              selected: {gallery},
              showSelectedIcon: false,
              onSelectionChanged: (value) =>
                  setState(() => gallery = value.single),
            ),
            const SizedBox(height: 20),
            if (!gallery) ...[
              if (widget.notices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xffeeeafd),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      const NotificationSticker(
                        kind: NoticeKind.pending,
                        size: 112,
                        decorative: true,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hộp thư đang chill',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: Color(0xff332c51),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chưa có thông báo mới.\nCứ vui, chuyện tiền để Chung nhắc nhẹ.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => setState(() => gallery = true),
                        child: const Text('Khám phá bộ sticker'),
                      ),
                    ],
                  ),
                ),
              ...widget.notices.reversed.map(
                (n) => NoticeCard(
                  kind: NoticeKind.fromKey(n['key'] as String? ?? ''),
                  text: n['text'] as String? ?? '',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thông báo trên thiết bị này. Chưa gửi push ra ngoài.',
                style: TextStyle(fontSize: 12, color: Color(0xff706780)),
              ),
            ] else ...[
              const Text(
                'Một chút lầy. Một chút dễ thương.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chạm một bạn để xem mẫu thông báo. Đây là mẫu thiết kế, không phải giao dịch đã phát sinh.',
                style: TextStyle(color: Color(0xff706780), height: 1.4),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      MediaQuery.textScalerOf(context).scale(14) > 20 ? 1 : 2;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: samples.keys
                        .map(
                          (kind) => SizedBox(
                            width: width,
                            child: Semantics(
                              selected: selected == kind,
                              child: Material(
                                color: kind.background,
                                borderRadius: BorderRadius.circular(24),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => setState(() => selected = kind),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      12,
                                      12,
                                      18,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: selected == kind
                                            ? const Color(0xff6451b5)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        NotificationSticker(
                                          kind: kind,
                                          size: 96,
                                          decorative: true,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          kind.title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xff332c51),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          kind.label,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff706780),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              NoticeCard(
                kind: selected,
                text: samples[selected]!,
                example: true,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
