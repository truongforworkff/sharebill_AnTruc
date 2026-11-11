# Build và chạy Chung trên điện thoại

Mã Flutter dùng chung cho Android/iOS. Bản hiện tại lưu dữ liệu trên từng máy, chưa đồng bộ giữa người dùng và chưa kết nối ngân hàng.

## Android

Yêu cầu: Flutter 3.47.9, JDK 21, Android SDK Platform 35/36, Build Tools 36.0.0 và NDK 28.2.13676358. Android tối thiểu theo cấu hình Flutter hiện tại: API 24 (Android 7.0).

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

APK nằm trong `build/app/outputs/flutter-apk/`:

- `app-arm64-v8a-release.apk`: điện thoại Android ARM64.
- `app-armeabi-v7a-release.apk`: thiết bị ARM 32-bit.
- `app-x86_64-release.apk`: thiết bị hoặc trình giả lập x86_64.

Chép đúng APK sang điện thoại và mở để cài. Android có thể yêu cầu cho phép ứng dụng quản lý tệp đang mở APK được cài ứng dụng. Nếu điện thoại đã bật USB debugging và xác nhận kết nối với máy tính, có thể cài qua `adb install -r <đường-dẫn-apk>`.

Các APK này dùng cấu hình ký debug có sẵn để cài thử, dù được biên dịch ở chế độ release. Chưa dùng để phát hành Play Store. Không đưa keystore hoặc mật khẩu ký vào Git. Dùng cùng khóa ký khi cập nhật để giữ dữ liệu; nếu khóa khác, không gỡ app có dữ liệu thật chỉ để vượt lỗi cài đặt.

Giới hạn RAM Gradle trong repo là 2 GB và 2 worker để hỗ trợ máy phát triển 8 GB RAM. Lần build đầu cần tải dependencies và có thể lâu hơn các lần sau.

## iOS trên Mac

Cần macOS, Xcode và iOS platform tương ứng. Cấu hình Runner có bundle ID `com.antruc.sharebillAntruc`, iOS tối thiểu 15.0, tên hiển thị Chung và mô tả quyền đọc ảnh hóa đơn. Bundle ID có thể cần đổi nếu không thuộc Apple Team của bạn.

```bash
git clone https://github.com/truongforworkff/sharebill_AnTruc.git
cd sharebill_AnTruc
flutter pub get
flutter doctor -v
flutter build ios --simulator
```

Để chạy trên iPhone:

1. Mở `ios/Runner.xcworkspace` bằng Xcode.
2. Chọn Runner → Signing & Capabilities → Apple Team của bạn và bật ký tự động.
3. Kết nối iPhone, hoàn tất Trust/Developer Mode trên thiết bị khi được yêu cầu.
4. Chọn thiết bị trong Xcode và Run, hoặc dùng `flutter devices` rồi `flutter run -d <device-id>`.

Để xuất IPA sau khi đã cấu hình signing và provisioning:

```bash
flutter build ipa --release
```

Không thể tạo một IPA cài được trên iPhone chỉ bằng việc đổi đuôi file hoặc build trên máy Linux hiện tại. File build không ký cũng không phải bản có thể cài trên iPhone. Cần xác nhận build và chạy trên Mac/iPhone trước khi coi iOS đã hoàn tất.

Tài liệu chính thức: [Thiết lập iOS](https://docs.flutter.dev/platform-integration/ios/setup), [xuất bản iOS](https://docs.flutter.dev/deployment/ios), [Android SDK](https://developer.android.com/studio).

## Kết quả build ngày 11/11/2026

- Thành công: Android release, ba ABI ARM32 / ARM64 / x86_64, phiên bản 0.2.0.
- Nhãn ứng dụng: Chung; application ID: `com.antruc.sharebill_antruc`; min SDK 24, target SDK 36.
- Đã kiểm tra: chữ ký APK bằng `apksigner`, tính toàn vẹn ZIP, các thư viện Flutter/Dart của đúng ABI và căn chỉnh ZIP 16 KB bằng `zipalign`.
- SHA-256 của các APK được ghi tại `build/app/outputs/flutter-apk/SHA256SUMS.txt`. APK là tệp build trên máy, không commit binary hoặc khóa ký vào Git.
- Chưa kiểm tra: cài/chạy trên điện thoại Android thật, iOS Simulator hoặc iPhone. Máy không có thiết bị Android được kết nối và không có Xcode.
- Có cảnh báo phiên bản XML SDK khi Gradle đọc SDK mới, nhưng build và các kiểm tra APK đều thành công.
