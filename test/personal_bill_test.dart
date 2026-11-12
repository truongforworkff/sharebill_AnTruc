import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sharebill_antruc/ledger.dart';

BillGroup group({bool twoMembers = false}) => BillGroup(
  id: 'personal',
  name: 'Chia bill không dùng quỹ',
  treasurer: 'an',
  members: [
    const Member('an', 'An'),
    const Member('binh', 'Bình'),
    if (!twoMembers) const Member('chi', 'Chi'),
  ],
);

void main() {
  test(
    'An pays for the whole group with no fund and is owed personal debts',
    () {
      final g = group();
      g.addExpense(
        id: 'dinner',
        actor: 'an',
        title: 'An trả trước bữa tối',
        amount: 300000,
        payer: 'an',
        participants: ['an', 'binh', 'chi'],
      );

      expect(g.entries.single.fundExpense, isFalse);
      expect(g.balances.personal, {
        'an': 200000,
        'binh': -100000,
        'chi': -100000,
      });
      expect(g.totalsFor('an'), (owe: 0, receive: 200000));
      expect(g.totalsFor('binh'), (owe: 100000, receive: 0));
      expect(g.totalsFor('chi'), (owe: 100000, receive: 0));
      expect(g.balances.cash, 0);
      expect(g.balances.liability, 0);
      expect(g.balances.available, 0);
      expect(g.statement('an').single.balance, 200000);

      g.request(
        id: 'partial',
        kind: EntryKind.payment,
        actor: 'binh',
        receiver: 'an',
        amount: 40000,
      );
      expect(g.totalsFor('binh').owe, 100000);
      g.review('partial', 'an', accept: true);
      expect(g.totalsFor('binh').owe, 60000);
      expect(g.totalsFor('an').receive, 160000);
      expect(g.totalsFor('chi').owe, 100000);

      g.request(
        id: 'remaining',
        kind: EntryKind.payment,
        actor: 'binh',
        receiver: 'an',
        amount: 60000,
      );
      g.review('remaining', 'an', accept: true);
      g.request(
        id: 'chi-payment',
        kind: EntryKind.payment,
        actor: 'chi',
        receiver: 'an',
        amount: 100000,
      );
      g.review('chi-payment', 'an', accept: true);
      expect(g.directTransfers, isEmpty);
      expect(g.balances.personal.values, everyElement(0));
      expect(g.balances.cash, 0);
      expect(g.balances.liability, 0);
    },
  );

  test('Two-person all-member bill preserves odd VND and payer own share', () {
    final g = group(twoMembers: true);
    g.addExpense(
      id: 'odd',
      actor: 'an',
      title: 'Ăn sáng',
      amount: 100001,
      payer: 'an',
      participants: ['binh', 'an'],
    );
    expect(g.entries.single.participants, ['an', 'binh']);
    expect(g.directTransfers.single.from, 'binh');
    expect(g.directTransfers.single.to, 'an');
    expect(g.directTransfers.single.amount, 50000);
    expect(
      g.balances.personal.values.fold<int>(0, (sum, value) => sum + value),
      0,
    );
    expect(g.balances.liability, 0);
  });

  test(
    'A funded group still keeps a personally paid whole-group bill personal',
    () {
      final g = group();
      g.request(
        id: 'deposit',
        kind: EntryKind.deposit,
        actor: 'an',
        receiver: fundId,
        amount: 500000,
      );
      g.review('deposit', 'an', accept: true);
      g.addExpense(
        id: 'personal',
        actor: 'binh',
        title: 'Bình trả trước',
        amount: 300000,
        payer: 'binh',
        participants: ['an', 'binh', 'chi'],
      );
      expect(g.totalsFor('binh').receive, 200000);
      expect(g.balances.cash, 500000);
      expect(g.balances.available, 500000);
      expect(g.balances.liability, 0);
    },
  );

  test(
    'Explicit fund advance requires all members and preserves its meaning',
    () {
      final g = group();
      expect(
        () => g.addExpense(
          id: 'invalid-advance',
          actor: 'an',
          title: 'Một phần nhóm',
          amount: 300000,
          payer: 'an',
          participants: ['an', 'binh'],
          chargeToFund: true,
        ),
        throwsA(isA<RuleError>()),
      );
      expect(g.entries, isEmpty);
      g.addExpense(
        id: 'fund-advance',
        actor: 'an',
        title: 'Ứng trước cho quỹ',
        amount: 300000,
        payer: 'an',
        participants: ['an', 'binh', 'chi'],
        chargeToFund: true,
      );
      expect(g.entries.single.fundExpense, isTrue);
      expect(g.directTransfers, isEmpty);
      expect(g.balances.cash, 0);
      expect(g.balances.owedByFund['an'], 300000);
      expect(g.balances.available, -300000);
    },
  );

  test('Stored personal bills and legacy fund advances retain their classification', () {
    final g = group();
    g.addExpense(
      id: 'personal',
      actor: 'an',
      title: 'Chia cá nhân',
      amount: 300000,
      payer: 'an',
      participants: ['an', 'binh', 'chi'],
    );
    final stored = jsonDecode(jsonEncode(g.toJson())) as Map<String, dynamic>;
    final personal = BillGroup.fromJson(stored);
    expect(personal.totalsFor('an').receive, 200000);
    expect(personal.balances.liability, 0);

    // Prior versions already persisted fundExpense. Never reinterpret saved money.
    (stored['entries'] as List).single['fundExpense'] = true;
    final legacy = BillGroup.fromJson(stored);
    expect(legacy.directTransfers, isEmpty);
    expect(legacy.balances.owedByFund['an'], 300000);
    expect(legacy.balances.cash, 0);
  });
}
