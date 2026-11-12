import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sharebill_antruc/ledger.dart';

BillGroup group() => BillGroup(
  id: 'g',
  name: 'Nhóm',
  treasurer: 'a',
  members: const [Member('a', 'Bạn'), Member('b', 'Huy'), Member('c', 'Huy')],
);

void main() {
  test(
    'Statement reconciles both directions, odd shares, payments and reversal',
    () {
      final g = group();
      g.addExpense(
        id: 'one',
        actor: 'a',
        title: 'Bữa ăn',
        amount: 100001,
        payer: 'b',
        participants: ['a', 'b'],
      );
      g.addExpense(
        id: 'two',
        actor: 'a',
        title: 'Vé',
        amount: 20000,
        payer: 'a',
        participants: ['c'],
      );
      g.request(
        id: 'pay',
        kind: EntryKind.payment,
        actor: 'a',
        receiver: 'b',
        amount: 10000,
      );
      expect(g.statement('a').last.balance, -30001);
      g.review('pay', 'b', accept: true);
      expect(g.statement('a', counterparty: 'b').last.balance, -40001);
      expect(g.statement('a', counterparty: 'c').last.balance, 20000);
      for (final m in g.members) {
        expect(g.statement(m.id).last.balance, g.balances.personal[m.id]);
        final totals = g.totalsFor(m.id);
        expect(totals.receive - totals.owe, g.balances.personal[m.id]);
      }
      g.reverseLatest('a', 'Ghi nhầm chuyển khoản', 'undo');
      expect(g.statement('a').map((l) => l.entry.id), ['one', 'two']);
      expect(g.statement('a').last.balance, -30001);
      expect(() => g.statement('unknown'), throwsA(isA<RuleError>()));
      expect(
        () => g.statement('a', counterparty: 'a'),
        throwsA(isA<RuleError>()),
      );
    },
  );

  test('Funds never leak into the personal statement', () {
    final g = group();
    g.request(
      id: 'fund',
      kind: EntryKind.deposit,
      actor: 'a',
      receiver: fundId,
      amount: 300000,
    );
    g.review('fund', 'a', accept: true);
    g.addExpense(
      id: 'all',
      actor: 'a',
      title: 'Cả nhóm',
      amount: 90000,
      payer: 'b',
      participants: ['a', 'b', 'c'],
      chargeToFund: true,
    );
    expect(g.statement('a'), isEmpty);
    expect(g.statement('b'), isEmpty);
    expect(g.balances.owedByFund['b'], 90000);
  });

  test('Expense date and note roundtrip; invalid input changes nothing', () {
    final g = group();
    void add(String date, {String note = ''}) => g.addExpense(
      id: date,
      actor: 'a',
      title: 'Bill',
      amount: 100,
      payer: 'b',
      participants: ['a'],
      occurredOn: date,
      note: note,
    );
    for (final date in ['2026-02-30', '2099-01-01', '2026-1-01', 'wrong']) {
      expect(() => add(date), throwsA(isA<RuleError>()));
    }
    expect(() => add('2025-01-02', note: 'x' * 501), throwsA(isA<RuleError>()));
    expect(g.entries, isEmpty);
    add('2025-01-02', note: '  Ăn trưa  ');
    final restored = BillGroup.fromJson(
      jsonDecode(jsonEncode(g.toJson())) as Map<String, dynamic>,
    );
    expect(restored.entries.single.occurredOn, '2025-01-02');
    expect(restored.entries.single.note, 'Ăn trưa');
    final legacy = g.entries.single.toJson()
      ..remove('note')
      ..remove('occurredOn');
    expect(Entry.fromJson(legacy).note, '');
    expect(Entry.fromJson(legacy).occurredOn, isNull);
  });

  test('Approval preserves expense metadata', () {
    final g = group();
    g.request(
      id: 'fund',
      kind: EntryKind.deposit,
      actor: 'a',
      receiver: fundId,
      amount: 1000,
    );
    g.review('fund', 'a', accept: true);
    g.addExpense(
      id: 'pending',
      actor: 'b',
      title: 'Bill',
      amount: 100,
      payer: fundId,
      participants: ['a', 'b', 'c'],
      occurredOn: '2025-01-02',
      note: 'Chi quỹ',
    );
    g.review('pending', 'a', accept: true);
    expect(g.entries.last.note, 'Chi quỹ');
    expect(g.entries.last.occurredOn, '2025-01-02');
  });
}
