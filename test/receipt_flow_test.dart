import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharebill_antruc/forms.dart';
import 'package:sharebill_antruc/ledger.dart';

const image =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=';
const channel = MethodChannel('chung/receipt_ocr');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  Future<BillGroup> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final group = BillGroup(
      id: 'ocr',
      name: 'Ăn cùng nhau',
      treasurer: 'me',
      members: const [
        Member('me', 'Bạn'),
        Member('h', 'Huy'),
        Member('b', 'Bình'),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ExpensePage(
          group: group,
          actor: 'me',
          recoveredEvidence: image,
          save: (change) async => change(group),
        ),
      ),
    );
    await tester.pump();
    return group;
  }

  Finder getAmount() => find.widgetWithText(TextField, 'Số tiền (VND)');

  testWidgets(
    'Image automatically fills amount and shares, records only on explicit save',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (_) async => 'Tổng thanh toán 300.001 VND',
          );
      final group = await open(tester);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(getAmount()).controller!.text, '300001');
      expect(group.entries, isEmpty);
      final chip = find.widgetWithText(FilterChip, 'Bình');
      await tester.scrollUntilVisible(
        chip,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(chip);
      await tester.pumpAndSettle();
      final save = find.text('Chốt khoản chi');
      await tester.scrollUntilVisible(
        save,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(group.entries.single.amount, 300001);
      expect(group.entries.single.participants, ['me', 'h']);
      expect(group.directTransfers.single.amount, 150000);
      expect(group.entries.single.evidence, image);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'All-member bill with personal payer saves even with an empty fund',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (_) async => 'Tổng thanh toán 300.000 VND',
          );
      final group = await open(tester);
      await tester.pumpAndSettle();
      final payer = find.byType(DropdownButtonFormField<String>);
      await tester.scrollUntilVisible(
        payer,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(payer);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Huy trả trước').last);
      await tester.pumpAndSettle();
      final save = find.text('Chốt khoản chi');
      await tester.scrollUntilVisible(
        save,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(group.entries.single.payer, 'h');
      expect(group.balances.cash, 0);
      expect(group.balances.owedByFund['h'], 300000);
      expect(group.balances.available, -300000);
      expect(group.directTransfers, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Ambiguous totals stay blank until the user chooses one', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => 'Tổng tiền 500.000\nTổng cộng 600.000',
        );
    final group = await open(tester);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(getAmount()).controller!.text, '');
    await tester.ensureVisible(find.text('600.000 đ'));
    await tester.tap(find.text('600.000 đ'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(getAmount()).controller!.text, '600000');
    expect(group.entries, isEmpty);
  });

  testWidgets('Late OCR cannot replace a manual correction or write an entry', (
    tester,
  ) async {
    final read = Completer<String>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) => read.future);
    final group = await open(tester);
    await tester.enterText(getAmount(), '123000');
    read.complete('Số tiền 900.000 VND');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(getAmount()).controller!.text, '123000');
    expect(group.entries, isEmpty);
  });

  testWidgets('OCR error preserves image and allows manual amount', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => throw PlatformException(code: 'ocr_failed'),
        );
    await open(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('Chưa đọc được ảnh.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.enterText(getAmount(), '120000');
    expect(tester.widget<TextField>(getAmount()).controller!.text, '120000');
  });

  testWidgets('Leaving while OCR is pending does not update a disposed page', (
    tester,
  ) async {
    final read = Completer<String>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) => read.future);
    await open(tester);
    await tester.pumpWidget(const SizedBox());
    read.complete('Tổng 500.000');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
