# sharebill_AnTruc

**Chung** — ứng dụng Flutter thử nghiệm và bản thiết kế mobile cho ứng dụng chia bill, công nợ và quỹ nhóm.

## Tài liệu và giao diện

- [FRS hiện tại (Markdown)](docs/FRS.md)
- [FRS 0.4 lưu trữ (Word)](docs/Share_Bill_FRS_v0.4.docx)
- [Giao diện HTML độc lập](frontend/Chung-Mobile.html) — tải về và mở bằng trình duyệt.
- [Gói giao diện](Chung-Mobile-Prototype.zip)
- [Hướng dẫn dùng bản mẫu](frontend/HUONG-DAN.txt)

FRS hiện tại là 0.6, bổ sung quy tắc chia bill cá nhân khi đủ nhóm và quỹ bằng 0, sau yêu cầu tự đọc ảnh và tính chia ngay ở 0.5. Bản Word 0.4 là tài liệu lưu trữ trước thay đổi OCR. FRS 0.4 bổ sung hai luồng mời: link riêng gắn với hồ sơ thành viên cho xem nhóm không cần tài khoản; link chung cần trưởng nhóm duyệt vào hồ sơ cũ hoặc thêm thành viên mới. Đăng ký sau giữ nguyên hồ sơ và công nợ. Không ghép theo tên.

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

### Kết quả kiểm chứng đã ghi nhận cho bản 0.3 trước thay đổi chia bill

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

Đọc ảnh không xác thực ngân hàng và không tự biết ai tham gia/người trả. Chia bill cá nhân vẫn ghi công nợ khi đủ nhóm và quỹ bằng 0; chi/ứng cho quỹ là lựa chọn riêng. Ảnh trả nợ/nộp quỹ dùng luồng xác nhận riêng. Bản HTML độc lập ở frontend chưa có OCR.

### Chia bill cá nhân khi quỹ bằng 0 — xác nhận 12/11/2026

Mặc định **Chia bill cá nhân**: chọn người trả trước và người tham gia. Đủ cả nhóm vẫn tạo công nợ cá nhân, không tự chuyển bill sang quỹ. Ví dụ An trả 300.000đ cho An, Bình và Chi khi quỹ 0đ: Bình nợ An 100.000đ, Chi nợ An 100.000đ, An cần thu 200.000đ; quỹ và khoản quỹ cần hoàn đều không đổi.

Khi đủ cả nhóm, có thêm hai lựa chọn rõ ràng:

- **Chi trực tiếp từ quỹ:** cần đủ quỹ khả dụng; không tạo công nợ cá nhân.
- **Ứng trước cho quỹ:** người trả được quỹ ghi khoản cần hoàn, kể cả quỹ chưa đủ tiền; không tạo nợ cá nhân. Hoàn ứng cần đủ tiền thực có và người nhận xác nhận.

Chọn đủ người không tự đổi chế độ chi. Bill đã lưu từ phiên bản trước giữ nguyên cách ghi quỹ/công nợ; thay đổi này không tự phân loại lại lịch sử. Kiểm chứng bản sửa ngày 12/11/2026 trên macOS: 39/39 kiểm thử Flutter và 6 bộ kiểm thử HTML đã qua; `flutter analyze` không có vấn đề. Build iOS Simulator debug bằng Xcode 27.2 thành công; đây là bản cho Simulator, chưa phải IPA có chữ ký cho iPhone. Các kết quả Android/web cũ ở trên không xác nhận bản sửa này.
