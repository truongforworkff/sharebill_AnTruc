import 'ledger.dart';

class ReceiptAmount {
  final int amount;
  final String source;
  final int priority;
  const ReceiptAmount(this.amount, this.source, this.priority);
}

class ReceiptAmounts {
  final List<ReceiptAmount> candidates;
  final bool foreignCurrency;
  const ReceiptAmounts(this.candidates, {this.foreignCurrency = false});

  int? get automaticAmount {
    if (foreignCurrency || candidates.isEmpty) return null;
    final first = candidates.first;
    if (first.priority < 3) return null;
    return candidates.where((c) => c.priority == first.priority).length == 1
        ? first.amount
        : null;
  }
}

String _plain(String text) {
  var value = text.toLowerCase().replaceAll(RegExp('[\u0300-\u036f]'), '');
  const accents = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };
  for (final entry in accents.entries) {
    value = value.replaceAll(RegExp('[${entry.value}]'), entry.key);
  }
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

int? _vnd(String token) {
  var value = token.trim().replaceAll('\u00a0', ' ');
  // VND has no fractional unit here; never turn 12.50 into 1,250 VND.
  value = value.replaceFirst(RegExp(r'[.,]00$'), '');
  if (!RegExp(r'^\d+$').hasMatch(value) &&
      !RegExp(r'^\d{1,3}([., ])\d{3}(?:\1\d{3})*$').hasMatch(value)) {
    return null;
  }
  final amount = int.tryParse(value.replaceAll(RegExp(r'[., ]'), ''));
  return amount != null && amount > 0 && amount <= maxAmount ? amount : null;
}

/// Conservatively selects a labelled VND total, never the largest number.
ReceiptAmounts readReceiptAmounts(String text) {
  final lines = text
      .split(RegExp(r'[\r\n]+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  final found = <int, ReceiptAmount>{};
  final currency = RegExp(
    r'\b(vnd|vndong|dong)\b|₫|(?:^|[\s\d])đ(?:$|\s)',
    caseSensitive: false,
  );
  final foreign = RegExp(
    r'\b(usd|eur|gbp|jpy|cny|thb|aud|sgd)\b|[$€£]',
    caseSensitive: false,
  );
  final excluded = RegExp(
    r'\b(so du|balance|tai khoan|stk|account|ma giao dich|transaction id|'
    r'ma tham chieu|reference|dien thoai|hotline|sdt|mst|ma so thue|'
    r'tien khach dua|khach dua|tien thua|tien tra lai|cash tendered|change|'
    r'tam tinh|subtotal|giam gia|discount|bang chu|tong thue|tong phi|truoc thue)\b|'
    r'^(phi\b|thue\b|vat\b|service charge\b)|\d[/:]\d',
  );
  int label(String line) {
    if (RegExp(
      r'\b(tong thanh toan|tong cong|tong tien|can thanh toan|phai tra|grand total|amount due|total amount)\b',
    ).hasMatch(line)) {
      return 6;
    }
    if (RegExp(r'\b(so tien|transfer amount|amount paid)\b').hasMatch(line)) {
      return 5;
    }
    if (RegExp(r'^(tong|total|thanh toan)\b').hasMatch(line)) return 4;
    return 0;
  }

  var hasForeign = false;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final plain = _plain(line);
    if (foreign.hasMatch(line)) {
      hasForeign = true;
      continue;
    }
    if (excluded.hasMatch(plain)) continue;
    var priority = label(plain);
    var source = line;
    if (priority == 0 && i > 0) {
      final previous = _plain(lines[i - 1]);
      if (excluded.hasMatch(previous) && !RegExp(r'\d').hasMatch(previous)) {
        continue;
      }
      // A label on the previous line applies only when it has no own amount.
      if (!excluded.hasMatch(previous) && !RegExp(r'\d').hasMatch(previous)) {
        priority = label(previous);
        if (priority > 0) source = '${lines[i - 1]} · $line';
      }
    }
    final hasCurrency = currency.hasMatch(line);
    if (priority == 0 && hasCurrency) {
      final remainder = line
          .replaceAll(currency, '')
          .replaceAll(RegExp(r'[\d.,+\-\s]'), '');
      priority = remainder.isEmpty ? 3 : 1;
    }
    for (final match in RegExp(r'\d(?:[\d., \u00a0]*\d)?').allMatches(line)) {
      if ((match.start > 0 &&
              RegExp(r'[A-Za-z/:%]').hasMatch(line[match.start - 1])) ||
          (match.end < line.length &&
              RegExp(r'[A-Za-z/:%]').hasMatch(line[match.end]) &&
              !RegExp(r'^(VND|vnd)').hasMatch(line.substring(match.end)))) {
        continue;
      }
      final token = match[0]!;
      final amount = _vnd(token);
      if (amount == null) continue;
      if (priority == 0 && !RegExp(r'[., ]').hasMatch(token)) continue;
      final candidate = ReceiptAmount(amount, source, priority);
      if (found[amount] == null || found[amount]!.priority < priority) {
        found[amount] = candidate;
      }
    }
  }
  final candidates = found.values.toList()
    ..sort((a, b) => b.priority.compareTo(a.priority));
  return ReceiptAmounts(candidates, foreignCurrency: hasForeign);
}
