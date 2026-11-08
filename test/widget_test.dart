import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:sharebill_antruc/main.dart';
import 'package:sharebill_antruc/repository.dart';
import 'package:sharebill_antruc/demo.dart';

void main() {
  testWidgets('Mobile home opens debt and member invitation screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = (await tester.runAsync(
      () => databaseFactoryMemory.openDatabase('widget'),
    ))!;
    final repo = BillRepository(db);
    await tester.runAsync(() async {
      for (final g in demoGroups()) {
        await repo.create(g);
      }
    });
    await tester.pumpWidget(ShareBillApp(repository: repo));
    await tester.pumpAndSettle();
    expect(find.text('Chuyện tiền của nhóm'), findsOneWidget);
    expect(find.text('Tổng nợ'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Công nợ').last);
    await tester.pumpAndSettle();
    expect(find.text('Nợ ai · Ai nợ mình'), findsOneWidget);
    await tester.tap(find.text('Vì sao có số tiền này?'));
    await tester.pumpAndSettle();
    expect(find.text('Số dư ròng đã ghi nhận'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    final groupButton = find.text('Nhóm của tôi · Xem công nợ từng nhóm');
    await tester.ensureVisible(groupButton);
    await tester.tap(groupButton);
    await tester.pumpAndSettle();
    expect(find.text('Nhóm của tôi'), findsOneWidget);
    final office = find.text('Ăn trưa văn phòng');
    await tester.ensureVisible(office);
    await tester.tap(office);
    await tester.pumpAndSettle();
    expect(find.text('Ăn trưa văn phòng'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Tổng quan').last);
    await tester.pumpAndSettle();
    final members = find.textContaining('Cả nhóm ·');
    await tester.ensureVisible(members);
    await tester.tap(members);
    await tester.pumpAndSettle();
    expect(find.text('Thành viên & lời mời'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}
