import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sharebill_antruc/ledger.dart';

BillGroup fixture() => BillGroup(
  id: 'g',
  name: 'Nhóm',
  treasurer: 'me',
  members: const [
    Member('me', 'Bạn', accountId: 'me-account'),
    Member('h1', 'Huy'),
    Member('h2', 'Huy'),
  ],
);
void main() {
  test('IDs can be created without platform-specific shift overflow', () {
    expect(newId(), isNotEmpty);
    expect(newId(), isNot(newId()));
  });
  test('Integer split preserves total and rejects duplicates', () {
    expect(splitEqually(100000, ['a', 'b', 'c']), {
      'a': 33334,
      'b': 33333,
      'c': 33333,
    });
    expect(() => splitEqually(1, ['a', 'a']), throwsA(isA<RuleError>()));
  });
  test('Both directions stay separate; pending/confirmed partial payments', () {
    final g = fixture();
    g.addExpense(
      id: 'a',
      actor: 'me',
      title: 'Meal',
      amount: 200000,
      payer: 'h1',
      participants: ['me'],
    );
    g.addExpense(
      id: 'b',
      actor: 'me',
      title: 'Meal 2',
      amount: 150000,
      payer: 'me',
      participants: ['h2'],
    );
    expect(g.directTransfers.length, 2);
    expect(g.balances.personal['me'], -50000);
    g.request(
      id: 'pay',
      kind: EntryKind.payment,
      actor: 'me',
      receiver: 'h1',
      amount: 100000,
    );
    expect(g.directTransfers.firstWhere((t) => t.from == 'me').amount, 200000);
    expect(
      () => g.review('pay', 'me', accept: true),
      throwsA(isA<RuleError>()),
    );
    g.review('pay', 'h1', accept: true);
    expect(g.directTransfers.firstWhere((t) => t.from == 'me').amount, 100000);
    expect(g.directTransfers.firstWhere((t) => t.from == 'h2').amount, 150000);
    expect(
      () => g.review('pay', 'h1', accept: true),
      throwsA(isA<RuleError>()),
    );
  });
  test('Fund only for all; advances reserve money; reject overdraw', () {
    final g = fixture();
    g.request(
      id: 'd',
      kind: EntryKind.deposit,
      actor: 'me',
      receiver: fundId,
      amount: 600000,
    );
    expect(g.balances.cash, 0);
    g.review('d', 'me', accept: true);
    expect(
      () => g.addExpense(
        id: 'bad',
        actor: 'me',
        title: 'Bad',
        amount: 100,
        payer: fundId,
        participants: ['me'],
      ),
      throwsA(isA<RuleError>()),
    );
    g.addExpense(
      id: 'all',
      actor: 'h1',
      title: 'Meal',
      amount: 300000,
      payer: 'h1',
      participants: ['me', 'h1', 'h2'],
    );
    expect(g.balances.cash, 600000);
    expect(g.balances.available, 300000);
    expect(g.directTransfers, isEmpty);
    g.request(
      id: 'refund',
      kind: EntryKind.refund,
      actor: 'me',
      receiver: 'h1',
      amount: 300000,
    );
    g.review('refund', 'h1', accept: true);
    expect(g.balances.cash, 300000);
    expect(g.balances.liability, 0);
    expect(
      () => g.addExpense(
        id: 'over',
        actor: 'me',
        title: 'Over',
        amount: 300001,
        payer: fundId,
        participants: ['me', 'h1', 'h2'],
      ),
      throwsA(isA<RuleError>()),
    );
  });
  test('Private link targets same-name member; claim keeps ledger and ID', () {
    final g = fixture();
    g.addExpense(
      id: 'e',
      actor: 'me',
      title: 'Meal',
      amount: 100,
      payer: 'me',
      participants: ['h2'],
    );
    final before = jsonEncode(g.entries.map((e) => e.toJson()).toList());
    final token = g.createInvite('me', memberId: 'h2');
    expect(g.guestMember(token).id, 'h2');
    g.claimProfile(token, 'huy-account');
    expect(g.members.length, 3);
    expect(g.members[1].accountId, isNull);
    expect(g.members[2].accountId, 'huy-account');
    expect(jsonEncode(g.entries.map((e) => e.toJson()).toList()), before);
    expect(() => g.guestMember(token), throwsA(isA<RuleError>()));
    final restored = BillGroup.fromJson(
      jsonDecode(jsonEncode(g.toJson())) as Map<String, dynamic>,
    );
    expect(restored.members[2].accountId, 'huy-account');
    expect(restored.directTransfers.single.amount, 100);
  });
  test(
    'General invitation requires approval; duplicate and wrong role blocked',
    () {
      final g = fixture();
      final token = g.createInvite('me');
      expect(() => g.guestMember(token), throwsA(isA<RuleError>()));
      g.requestJoin(token, 'huy-account', 'Huy');
      g.requestJoin(token, 'huy-account', 'Huy');
      expect(g.joinRequests.length, 1);
      expect(g.members.length, 3);
      final r = g.joinRequests.single['id'] as String;
      expect(
        () => g.reviewJoin(r, 'h1', accept: true, memberId: 'h2'),
        throwsA(isA<RuleError>()),
      );
      g.reviewJoin(r, 'me', accept: true, memberId: 'h2');
      expect(g.members.length, 3);
      expect(g.members[2].accountId, 'huy-account');
      expect(
        () => g.reviewJoin(r, 'me', accept: true),
        throwsA(isA<RuleError>()),
      );
      g.requestJoin(token, 'another', 'Huy');
      g.reviewJoin(g.joinRequests.last['id'] as String, 'me', accept: true);
      expect(g.members.length, 4);
      expect(g.members.last.id, isNot('h2'));
      g.revokeInvite(token, 'me');
      expect(
        () => g.requestJoin(token, 'third', 'Huy'),
        throwsA(isA<RuleError>()),
      );
    },
  );
  test('Two pending payments cannot overpay on confirmation', () {
    final g = fixture();
    g.addExpense(
      id: 'e',
      actor: 'me',
      title: 'Meal',
      amount: 100,
      payer: 'h1',
      participants: ['me'],
    );
    g.request(
      id: 'p1',
      kind: EntryKind.payment,
      actor: 'me',
      receiver: 'h1',
      amount: 80,
    );
    g.request(
      id: 'p2',
      kind: EntryKind.payment,
      actor: 'me',
      receiver: 'h1',
      amount: 80,
    );
    g.review('p1', 'h1', accept: true);
    expect(() => g.review('p2', 'h1', accept: true), throwsA(isA<RuleError>()));
    expect(g.directTransfers.single.amount, 20);
  });
}
