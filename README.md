# sharebill_AnTruc

**Chung** — ứng dụng Flutter thử nghiệm và bản thiết kế mobile cho ứng dụng chia bill, công nợ và quỹ nhóm.

## Tài liệu và giao diện

- [FRS hiện tại (Markdown)](docs/FRS.md)
- [FRS 0.4 lưu trữ (Word)](docs/Share_Bill_FRS_v0.4.docx)
- [Giao diện HTML độc lập](frontend/Chung-Mobile.html) — tải về và mở bằng trình duyệt.
- [Gói giao diện](Chung-Mobile-Prototype.zip)
- [Hướng dẫn dùng bản mẫu](frontend/HUONG-DAN.txt)

FRS hiện tại là 0.5, bổ sung yêu cầu tự đọc ảnh và tính chia ngay. Bản Word 0.4 là tài liệu lưu trữ trước thay đổi OCR. FRS 0.4 bổ sung hai luồng mời: link riêng gắn với hồ sơ thành viên cho xem nhóm không cần tài khoản; link chung cần trưởng nhóm duyệt vào hồ sơ cũ hoặc thêm thành viên mới. Đăng ký sau giữ nguyên hồ sơ và công nợ. Không ghép theo tên.

## Chạy giao diện

```bash
python3 -m http.server 4173 --bind 127.0.0.1 --directory frontend
```

Mở http://localhost:4173/. Tại Tổng quan → Cả nhóm, thử Link riêng cạnh Chi, Link chung và Chờ duyệt. Các nút “mô phỏng” cho phép thử vai trò người nhận/trưởng nhóm trong cùng tab.

## Kiểm tra logic

```bash
node --test frontend/tests/*.test.cjs
```

## Giới hạn

Đây là prototype HTML/CSS/JavaScript với dữ liệu mẫu trong bộ nhớ. Reload đặt lại dữ liệu. Chưa có đăng nhập thật, backend phân quyền, đồng bộ, link mời liên thiết bị, OCR hoặc kết nối ngân hàng. Không dùng cho tiền hoặc thông tin cá nhân thật. Link riêng thực tế là quyền đọc và cần kiểm tra/thu hồi trên server; người được chuyển tiếp link có thể xem.

Sổ tiền mẫu dùng chỉ số thành viên cố định và chỉ thêm người cuối danh sách; khi triển khai backend phải dùng Membership ID bất biến. Quy tắc xác thực, đồng thời và phân quyền phía server trong FRS chưa được triển khai bằng frontend.

Motion dùng hướng dẫn Animate UI qua CSS. Xem [thông báo giấy phép](frontend/ANIMATE-UI-NOTICES.txt).


## Flutter (Dart)

Mã ứng dụng tại `lib/`, kiểm thử tại `test/`. Có lưu dữ liệu cục bộ trên thiết bị (Sembast) và IndexedDB khi chạy web.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
flutter build web
```

Build iOS cần macOS/Xcode và cấu hình signing của chủ dự án. Android cần Android SDK/JDK theo `flutter doctor`.

Hướng dẫn cài APK và chạy iPhone: [Build mobile](docs/BUILD-MOBILE.md).

Bản Flutter có tạo/chuyển nhóm, nhập bill và ảnh, chia đều tiền nguyên VND, quỹ, khoản ứng/hoàn, trả nợ từng phần và xác nhận, hai tổng nợ/thu, tổng hợp theo người xuyên nhóm, lời mời/nhận hồ sơ/duyệt, chốt kỳ, biểu quyết tần suất kỳ, phản hồi và hộp thư nhắc tiền cục bộ. Menu đổi vai dùng để thử các bên trên một máy, không phải đăng nhập hay phân quyền vận hành.

Chưa triển khai backend, mời thật qua Internet, xác thực ngân hàng, push notification, lựa chọn bù trừ toàn nhóm trong Flutter và sửa lịch sử giao dịch tùy ý. Đăng ký trong luồng mời là mô phỏng liên kết tài khoản; không dùng dữ liệu thật. Quy tắc bắt buộc còn lại được giữ trong FRS, không được coi là đã hoàn thành chỉ vì có giao diện.

### Kiểm chứng bản Flutter

Đã chạy 32 test logic, đọc tiền từ ảnh, lưu trữ và màn hình mobile 390×844; Dart analyzer không có lỗi/cảnh báo. Build web release thành công. Môi trường kiểm tra: Flutter 3.47.9, Dart 3.13.7. Đã build thành công APK Android 0.3.0 release cho ARM32, ARM64 và x86_64; đã xác minh chữ ký, toàn vẹn ZIP và căn chỉnh ZIP 16 KB. APK dùng khóa debug để cài thử. Chưa kiểm thử trên điện thoại thật; iOS chưa build vì môi trường hiện tại là Linux, không có Xcode.

### Bổ sung ở bản 0.2

- **Nhóm của tôi:** xem số thành viên, vai trò, tổng nợ, tổng cần thu và quỹ khả dụng của từng nhóm; chạm để chuyển nhóm. Khi đổi nhóm giữ đúng tài khoản đang xem nếu tài khoản có trong nhóm.
- **Giải thích số dư (FR15):** vào Công nợ → Vì sao có số tiền này; lọc theo một người hoặc cả nhóm. Mỗi dòng có khoản tăng/giảm, số dư lũy kế và bill/chứng từ gốc. Quỹ, khoản chưa xác nhận, bị từ chối và đã đảo không được cộng vào công nợ. Hai tổng nợ/thu vẫn giữ riêng.
- **Ngày và ghi chú bill (FR03):** nhập ngày phát sinh không ở tương lai, ghi chú tối đa 500 ký tự; lưu cùng chứng từ, giữ khi xác nhận và xem được qua link khách mô phỏng. Ngày dùng để tra cứu; bill nhập muộn được ghi nhận vào kỳ hiện tại, không sửa snapshot kỳ cũ. Dữ liệu phiên bản trước vẫn đọc được.

Bản này tiếp tục hoàn thiện ứng dụng cục bộ. Phần FR15 giải thích giao dịch đã có; đề xuất thanh toán qua bù trừ toàn nhóm vẫn chưa được triển khai. Backend, xác thực tài khoản, phân quyền và đồng bộ nhiều thiết bị chưa hoàn thành.

### Bộ sticker thông báo

Chạm chuông ở đầu màn hình → **Bộ sticker** để xem sáu mẫu: nhắc thanh toán, đã nhận tiền, nộp quỹ, chốt kỳ, chờ xác nhận và kiểm tra bill. Nét viền tím, màu pastel và biểu cảm vui; vẽ vector trực tiếp bằng Flutter nên không tải ảnh hoặc font emoji bên ngoài.

Hộp thư và phần nhắc tiền dùng cùng thẻ thông báo. Nội dung nghiệp vụ được giữ nguyên; thông báo cũ nhận đúng icon qua mã sự kiện. Mẫu thiết kế luôn ghi “MẪU MINH HỌA”, không tạo giao dịch hoặc thông báo thanh toán giả. Chưa thay đổi icon push của hệ điều hành vì app chưa tích hợp push notification.

### Bổ sung ở bản 0.3

Vào nhóm → Thêm khoản chi → **Chọn ảnh bill · Tự chia tiền**. App đọc tổng VND, tự điền tiền và tính phần chia theo người đang chọn. Sửa người/nguồn tiền nếu cần rồi chốt. Tổng mơ hồ được đưa thành các lựa chọn, không tự lấy con số lớn nhất. Đọc lỗi vẫn giữ ảnh và cho nhập tay; kết quả đến muộn không ghi đè số vừa sửa.

- Android: Google ML Kit Latin, mô hình đóng gói cùng APK để đọc offline.
- iOS: Apple Vision có sẵn trên hệ điều hành; cần xác nhận bằng build/test trên Mac và iPhone.
- Flutter web: Tesseract.js 6.0.1 chạy trong trình duyệt, tải engine/model từ jsDelivr và Project Naptha khi cần. Cần mạng cho lần đọc đầu; ảnh không gửi tới máy chủ OCR.

Đọc ảnh không xác thực ngân hàng và không tự biết ai tham gia/người trả. Bill đủ nhóm vẫn áp dụng quỹ; ảnh trả nợ/nộp quỹ dùng luồng xác nhận riêng. Bản HTML độc lập ở frontend chưa có OCR.

Sửa quỹ thiếu: chọn một thành viên trả trước vẫn lưu được bill đủ nhóm; quỹ ghi khoản cần hoàn, không giảm tiền thực có. Phần thiếu được hiển thị rõ. Chỉ chi trực tiếp từ quỹ/hoàn ứng mới bị chặn khi không đủ tiền.
