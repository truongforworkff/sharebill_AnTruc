import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:sharebill_antruc/repository.dart';
import 'package:sharebill_antruc/ledger.dart';

void main() {
  test(
    'Repository rolls back a failed change and keeps saved membership',
    () async {
      final db = await databaseFactoryMemory.openDatabase('test');
      final repo = BillRepository(db);
      await repo.create(
        BillGroup(
          id: 'g',
          name: 'Group',
          treasurer: 'a',
          members: const [Member('a', 'Bạn'), Member('b', 'Huy')],
        ),
      );
      await expectLater(
        repo.update('g', (g) {
          g.members.add(const Member('c', 'Huy'));
          throw RuleError('Stop');
        }),
        throwsA(isA<RuleError>()),
      );
      expect((await repo.groups()).single.members.length, 2);
      String token = '';
      await repo.update('g', (g) {
        token = g.createInvite('a', memberId: 'b');
      });
      await repo.update('g', (g) => g.claimProfile(token, 'huy-account'));
      expect((await repo.groups()).single.members[1].accountId, 'huy-account');
      await db.close();
    },
  );
}
