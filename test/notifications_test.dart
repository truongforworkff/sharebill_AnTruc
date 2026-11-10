import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharebill_antruc/notification_sticker.dart';
import 'package:sharebill_antruc/notifications_page.dart';

void main() {
  test(
    'Existing notice keys select the right art without guessing payment status',
    () {
      expect(NoticeKind.fromKey('reminder:a:1:50000'), NoticeKind.reminder);
      expect(NoticeKind.fromKey('period:2'), NoticeKind.period);
      expect(NoticeKind.fromKey('unknown'), NoticeKind.message);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets('Sticker gallery fits 320px with text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const NotificationsPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Hộp thư đang chill'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Hộp thư đang chill'), findsOneWidget);
      expect(find.text('MẪU MINH HỌA'), findsNothing);
      await tester.scrollUntilVisible(find.text('Bộ sticker'), -200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bộ sticker'));
      await tester.pumpAndSettle();
      final fund = find.text('Heo được ăn ngon');
      await tester.scrollUntilVisible(fund, 200);
      await tester.pumpAndSettle();
      await tester.tap(fund);
      await tester.pumpAndSettle();
      final example = find.text('MẪU MINH HỌA · Nộp quỹ');
      await tester.scrollUntilVisible(example, 200);
      await tester.pumpAndSettle();
      expect(example, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Inbox preserves the actual message, with no fabricated sample transactions',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsPage(
            notices: [
              {'key': 'period:2', 'text': 'Đã chốt kỳ 1. Còn nợ 200.000đ.'},
            ],
          ),
        ),
      );
      expect(find.text('Đã chốt kỳ 1. Còn nợ 200.000đ.'), findsOneWidget);
      expect(find.text('Chốt sổ, thở cái đã'), findsOneWidget);
      expect(find.text('Ting ting, vui liền'), findsNothing);
    },
  );
}
