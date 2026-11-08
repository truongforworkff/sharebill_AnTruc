import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sharebill_antruc/ledger.dart';

void main() {
  test(
    'Close blocks pending/report, carries once and snapshots never change',
    () {
      final g = BillGroup(
        id: 'g',
        name: 'Group',
        treasurer: 'me',
        members: const [
          Member('me', 'Bạn'),
          Member('h', 'Huy'),
          Member('b', 'Bình'),
        ],
      );
      g.addExpense(
        id: 'e',
        actor: 'me',
        title: 'Bill',
        amount: 200000,
        payer: 'h',
        participants: ['me'],
      );
      g.reportBill('e', 'me', 'Kiểm tra');
      expect(() => g.closePeriod('me'), throwsA(isA<RuleError>()));
      g.resolveReport(
        g.feedback.single['id'] as String,
        'me',
        'Đã kiểm tra, giữ số tiền',
      );
      g.proposeFrequency('monthly', 'me');
      g.voteFrequency('h');
      g.voteFrequency('b');
      g.closePeriod('me');
      expect(g.workflow['period'], 2);
      expect(g.workflow['frequency'], 'monthly');
      expect(g.balances.personal['me'], -200000);
      final snapshot = jsonEncode(g.periods.single);
      g.request(
        id: 'p',
        kind: EntryKind.payment,
        actor: 'me',
        receiver: 'h',
        amount: 50000,
      );
      expect(() => g.closePeriod('me'), throwsA(isA<RuleError>()));
      g.review('p', 'h', accept: true);
      expect(g.balances.personal['me'], -150000);
      expect(jsonEncode(g.periods.single), snapshot);
      g.closePeriod('me');
      expect(g.balances.personal['me'], -150000);
      expect(g.periods.length, 2);
    },
  );
  test('Reminder respects pending payment, opt out and deduplication', () {
    final g = BillGroup(
      id: 'g',
      name: 'Group',
      treasurer: 'me',
      members: const [
        Member('me', 'Bạn'),
        Member('h', 'Huy'),
        Member('b', 'Bình'),
      ],
    );
    g.addExpense(
      id: 'e',
      actor: 'me',
      title: 'Bill',
      amount: 100,
      payer: 'h',
      participants: ['me'],
    );
    g.remind('me');
    g.remind('me');
    expect(g.notifications.length, 1);
    g.workflow['reminderPrefs'] = {'me': false};
    expect(() => g.remind('me'), throwsA(isA<RuleError>()));
    g.workflow['reminderPrefs'] = {'me': true};
    g.request(
      id: 'p',
      kind: EntryKind.payment,
      actor: 'me',
      receiver: 'h',
      amount: 100,
    );
    expect(() => g.remind('me'), throwsA(isA<RuleError>()));
  });
}
