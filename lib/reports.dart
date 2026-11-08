part of 'ledger.dart';

class StatementLine {
  final Entry entry;
  final int delta, balance;
  const StatementLine(this.entry, this.delta, this.balance);
}

extension DebtReports on BillGroup {
  /// Positive means receivable; only confirmed, unreversed personal entries count.
  List<StatementLine> statement(String member, {String? counterparty}) {
    require(hasMember(member), 'Không tìm thấy thành viên.');
    require(
      counterparty == null ||
          (hasMember(counterparty) && counterparty != member),
      'Người đối chiếu không hợp lệ.',
    );
    final result = <StatementLine>[];
    var running = 0;
    for (final e in active) {
      var delta = 0;
      if (e.kind == EntryKind.expense && !e.fundExpense) {
        for (final share in splitEqually(e.amount, e.participants).entries) {
          if (share.key == e.payer) continue;
          if (member == e.payer &&
              (counterparty == null || share.key == counterparty)) {
            delta += share.value;
          }
          if (member == share.key &&
              (counterparty == null || e.payer == counterparty)) {
            delta -= share.value;
          }
        }
      } else if (e.kind == EntryKind.payment) {
        if (member == e.payer &&
            (counterparty == null || e.receiver == counterparty)) {
          delta += e.amount;
        }
        if (member == e.receiver &&
            (counterparty == null || e.payer == counterparty)) {
          delta -= e.amount;
        }
      }
      if (delta == 0) continue;
      running += delta;
      result.add(StatementLine(e, delta, running));
    }
    return result;
  }

  ({int owe, int receive}) totalsFor(String member) {
    require(hasMember(member), 'Không tìm thấy thành viên.');
    var owe = 0, receive = 0;
    for (final t in directTransfers) {
      if (t.from == member) owe += t.amount;
      if (t.to == member) receive += t.amount;
    }
    return (owe: owe, receive: receive);
  }
}
