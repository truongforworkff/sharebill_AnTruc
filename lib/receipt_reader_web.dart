import 'dart:js_interop';

@JS('chungReadReceipt')
external JSPromise<JSString> _readReceipt(JSString image);

Future<String> readReceiptText(String image) async =>
    (await _readReceipt(image.toJS).toDart).toDart;
