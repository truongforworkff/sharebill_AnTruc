import 'ledger.dart';

BillGroup demoGroup() {
  final members = ['Bạn', 'Bình', 'An', 'Chi', 'Dũng', 'Hà', 'Linh', 'Huy']
      .asMap()
      .entries
      .map(
        (e) => Member(
          'm${e.key}',
          e.value,
          accountId: e.key == 0
              ? 'local-me'
              : e.value == 'Chi'
              ? null
              : 'sample-${e.value}',
        ),
      )
      .toList();
  final g = BillGroup(
    id: newId(),
    name: 'Hội ăn ngon • dữ liệu mẫu',
    treasurer: 'm0',
    members: members,
  );
  for (final m in members) {
    final id = newId();
    g.request(
      id: id,
      kind: EntryKind.deposit,
      actor: m.id,
      receiver: fundId,
      amount: 500000,
    );
    g.review(id, 'm0', accept: true);
  }
  g.addExpense(
    id: newId(),
    actor: 'm0',
    title: 'Bữa tối đủ cả hội',
    amount: 800000,
    payer: fundId,
    participants: members.map((m) => m.id).toList(),
  );
  g.addExpense(
    id: newId(),
    actor: 'm1',
    title: 'Bún bò sáng thứ bảy',
    amount: 1000000,
    payer: 'm1',
    participants: ['m0', 'm1', 'm2', 'm3', 'm4'],
  );
  g.addExpense(
    id: newId(),
    actor: 'm2',
    title: 'Cà phê cả nhóm • An ứng',
    amount: 400000,
    payer: 'm2',
    participants: members.map((m) => m.id).toList(),
  );
  g.request(
    id: newId(),
    kind: EntryKind.payment,
    actor: 'm0',
    receiver: 'm1',
    amount: 100000,
  );
  return g;
}

List<BillGroup> demoGroups() {
  final first = demoGroup();
  BillGroup sample(String name, List<String> labels) {
    final ms = labels
        .asMap()
        .entries
        .map(
          (e) => Member(
            newId(),
            e.value,
            accountId: e.key == 0
                ? 'local-me'
                : e.value == 'Chi'
                ? null
                : 'sample-${e.value}',
          ),
        )
        .toList();
    return BillGroup(
      id: newId(),
      name: name,
      treasurer: ms.first.id,
      members: ms,
    );
  }

  final office = sample('Ăn trưa văn phòng', [
    'Bạn',
    'Nam',
    'Mai',
    'Huy',
    'Lan',
    'Phúc',
  ]);
  final travel = sample('Hội mê Đà Lạt', [
    'Bạn',
    'Bình',
    'An',
    'Chi',
    'Dũng',
    'Hà',
    'Linh',
    'Huy',
    'Vy',
    'Tuấn',
  ]);
  first.addExpense(
    id: newId(),
    actor: 'm0',
    title: 'Bạn ứng phần Huy',
    amount: 50000,
    payer: 'm0',
    participants: ['m7'],
  );
  office.addExpense(
    id: newId(),
    actor: office.members[3].id,
    title: 'Huy ứng bữa trưa',
    amount: 120000,
    payer: office.members[3].id,
    participants: [office.members[0].id],
  );
  travel.addExpense(
    id: newId(),
    actor: travel.members[0].id,
    title: 'Bạn ứng vé cho Huy',
    amount: 80000,
    payer: travel.members[0].id,
    participants: [travel.members[7].id],
  );
  return [first, office, travel];
}
