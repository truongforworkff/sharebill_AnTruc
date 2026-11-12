import 'package:flutter_test/flutter_test.dart';
import 'package:sharebill_antruc/receipt_amount.dart';

void main() {
  test(
    'Vietnamese bill picks the final total, not tendered cash or change',
    () {
      final result = readReceiptAmounts('''
QUÁN ĂN CHUNG
Hotline 0912345678
Tạm tính 500.000
VAT 50.000
TỔNG THANH TOÁN 550.000 đ
Tiền khách đưa 1.000.000
Tiền thừa 450.000
''');
      expect(result.automaticAmount, 550000);
      expect(result.candidates.map((c) => c.amount), [550000]);
    },
  );

  test('Bank receipt separates amount from account, ID, balance and time', () {
    final result = readReceiptAmounts('''
CHUYỂN TIỀN THÀNH CÔNG
Số tiền
1,250,000 VND
Tài khoản nhận
123.456.789
Mã giao dịch FT123456789
Ngày 12/11/2026 15:30
Số dư
9,000,000 VND
''');
    expect(result.automaticAmount, 1250000);
    expect(result.candidates.map((c) => c.amount), [1250000]);
  });

  test('VND grouping and zero fractions preserve integer money', () {
    for (final value in [
      '1.250.000',
      '1,250,000',
      '1 250 000',
      '1250000',
      '1.250.000,00',
      '1,250,000.00',
    ]) {
      expect(
        readReceiptAmounts('Tổng tiền: $value VND').automaticAmount,
        1250000,
        reason: value,
      );
    }
    expect(readReceiptAmounts('500000đ').automaticAmount, 500000);
    expect(readReceiptAmounts('-500.000 VND').automaticAmount, 500000);
  });

  test('Conflicting totals require a choice; duplicate totals do not', () {
    expect(
      readReceiptAmounts(
        'Tổng tiền 500.000\nTổng thanh toán 600.000',
      ).automaticAmount,
      isNull,
    );
    expect(
      readReceiptAmounts(
        'Tổng tiền 500.000\nTổng cộng 500.000',
      ).automaticAmount,
      500000,
    );
    expect(readReceiptAmounts('500.000\n900.000').automaticAmount, isNull);
    expect(readReceiptAmounts('Phở bò 60.000 VND').automaticAmount, isNull);
    expect(readReceiptAmounts('Tổng thuế 60.000 VND').automaticAmount, isNull);
    expect(
      readReceiptAmounts('Số tiền 800.000\n900.000').automaticAmount,
      800000,
    );
  });

  test(
    'Do not invent VND totals from decimals, IDs, foreign currency or blanks',
    () {
      for (final value in [
        '',
        'Tài khoản 123456789',
        'Mã giao dịch\n123.456.789',
        'Số dư\n9.000.000 VND',
        'Tổng 12.50 VND',
        'Tổng 999999999999999 VND',
        'Tổng 0 VND',
        'TOTAL 25 USD',
        'Tổng 20 EUR\n100.000 VND',
      ]) {
        expect(
          readReceiptAmounts(value).automaticAmount,
          isNull,
          reason: value,
        );
      }
      expect(readReceiptAmounts('Tổng 20 EUR').foreignCurrency, isTrue);
    },
  );
}
