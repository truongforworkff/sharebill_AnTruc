import 'dart:convert';
import 'package:flutter/services.dart';

Future<String> readReceiptText(String image) async =>
    await const MethodChannel(
      'chung/receipt_ocr',
    ).invokeMethod<String>('readText', base64Decode(image)) ??
    '';
