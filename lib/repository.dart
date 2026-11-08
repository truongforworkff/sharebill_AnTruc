import 'package:sembast/sembast.dart';

import 'ledger.dart';
export 'database_io.dart' if (dart.library.js_interop) 'database_web.dart';

class BillRepository {
  final Database database;
  final store = stringMapStoreFactory.store('groups');
  BillRepository(this.database);

  Future<List<BillGroup>> groups() async => (await store.find(
    database,
  )).map((r) => BillGroup.fromJson(r.value)).toList();

  Future<void> create(BillGroup group) => database.transaction((txn) async {
    require(!await store.record(group.id).exists(txn), 'Nhóm đã tồn tại.');
    await store.record(group.id).put(txn, group.toJson());
  });

  Future<void> update(String id, void Function(BillGroup) change) =>
      database.transaction((txn) async {
        final json = await store.record(id).get(txn);
        require(json != null, 'Không tìm thấy nhóm.');
        final group = BillGroup.fromJson(json!);
        change(group);
        await store.record(id).put(txn, group.toJson());
      });
}
