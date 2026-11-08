# Đặc tả yêu cầu chức năng Share Bill

Phiên bản 0.1 · Ngày 08 tháng 11 năm 2026 · Trạng thái: bản nháp để thảo luận, chưa duyệt triển khai

Share Bill giúp nhóm bạn theo dõi tiền ăn uống, đi chơi, khoản ứng trước và quỹ chung. Người dùng thêm hóa đơn, chọn người tham gia và kiểm tra số tiền; hệ thống tự phân bổ chi phí, cộng dồn công nợ và đề xuất thanh toán sau bù trừ. Mục tiêu hiện tại là thống nhất yêu cầu chức năng trước khi thiết kế kỹ thuật hoặc xây dựng ứng dụng.

## Những yêu cầu đã xác nhận

- Định hướng app di động đa nền tảng bằng Dart.
- Nhóm bạn khoảng 6–10 người, dùng cho ăn uống và đi chơi.
- Đưa bill vào, chọn những người tham gia và tự chia tiền.
- Cộng dồn khoản chưa trả qua nhiều lần; bù trừ khi thành viên khác trả trước, mở rộng trên cả nhóm.
- Có nộp quỹ chung; chỉ dùng quỹ khi tất cả thành viên tham gia hôm đó.
- Thành viên trong nhóm xem được các khoản thu chi và chứng từ.
- Có nhu cầu xác thực bill ngân hàng; cách xác thực chưa được chốt.

Các chi tiết còn lại trong tài liệu là **đề xuất để thảo luận**, bao gồm vai trò, cách duyệt, giới hạn tiền, chia số lẻ, xử lý thiếu quỹ và thời điểm ghi nhận. Các tình huống nghiệm thu tương ứng chỉ có hiệu lực sau khi quy tắc được duyệt. Việc chọn hướng thử nghiệm trên máy không đồng nghĩa cho phép bắt đầu viết app trước khi chốt FRS.

## 1 Mục tiêu và phạm vi

- Phục vụ nhóm khoảng 6–10 người, cho phép tạo nhóm từ 2 thành viên; không gắn thuật toán với một số lượng cố định.
- App Flutter bằng Dart, ưu tiên Android và iOS, giao diện tiếng Việt, tiền VND.
- Thành viên được xem thu, chi, hóa đơn, khoản đóng quỹ, lịch sử xác nhận và công nợ của nhóm mình.
- Chi phí phát sinh qua nhiều ngày vẫn được cộng dồn đến khi có giao dịch thanh toán được xác nhận.
- Đủ tất cả thành viên tham gia: chi phí thuộc quỹ. Chỉ một phần nhóm tham gia: chi phí cá nhân của những người được chọn.
- Hỗ trợ chứng từ chuyển khoản và xác nhận của người nhận. Đối soát ngân hàng tự động là một tích hợp riêng, không được suy ra từ ảnh.

## 2 Vai trò

| Vai trò | Quyền |
| --- | --- |
| Thành viên | Xem dữ liệu nhóm; thêm khoản chi; gửi yêu cầu ghi nhận nộp quỹ và trả nợ; xác nhận tiền mình nhận; báo sai chứng từ |
| Quản trị nhóm | Các quyền thành viên; mời thành viên; quản lý tên nhóm và vai trò; xử lý điều chỉnh có lịch sử |
| Thủ quỹ | Các quyền thành viên; xác nhận tiền quỹ nhận; xác nhận tiền quỹ chi; xử lý hoàn tiền người ứng trước |

Người tạo nhóm ban đầu kiêm quản trị và thủ quỹ. Việc đổi thủ quỹ phải có bàn giao số dư được xác nhận. Không dùng việc chọn tên trên giao diện thay cho đăng nhập trong bản dùng thật.

## 3 Thuật ngữ và số dư

- **Khoản chi**: hóa đơn đã được chốt với tổng tiền và danh sách tham gia.
- **Công nợ cá nhân**: số tiền thành viên cần trả hoặc được nhận sau các khoản chi cá nhân và thanh toán đã xác nhận. Số dương là được nhận; số âm là phải trả.
- **Tiền quỹ thực có**: các khoản nộp đã xác nhận trừ tiền đã chi thực tế từ quỹ và tiền đã hoàn ứng.
- **Quỹ cần hoàn**: tiền thành viên đã ứng cho các khoản chi thuộc quỹ nhưng quỹ chưa hoàn.
- **Quỹ khả dụng**: tiền quỹ thực có trừ tổng quỹ cần hoàn. Không trộn quỹ vào thuật toán bù trừ nợ cá nhân.
- **Chứng từ**: ảnh hóa đơn ăn uống hoặc ảnh chuyển khoản; không tự chứng minh tiền đã vào tài khoản.
- **Đề xuất tất toán**: danh sách chuyển tiền được tính từ số dư hiện tại, chưa phải giao dịch đã xảy ra.

## 4 Quy tắc nghiệp vụ

### BR01 Tiền và chia đều

Lưu tiền bằng số nguyên VND dương, không dùng số thực. Tổng phần chia phải bằng tổng hóa đơn. Với 100.000đ chia 3, phân bổ 33.334đ, 33.333đ, 33.333đ theo thứ tự thành viên được lưu trong nhóm. Hiển thị phần chênh 1đ trước khi lưu. Giới hạn đề xuất mỗi giao dịch là 1.000.000.000đ; server phải kiểm tra lại giới hạn.

### BR02 Xác định đủ nhóm

So sánh tập ID người tham gia với tập ID thành viên đang hoạt động tại thời điểm sự kiện, không chỉ so sánh số lượng. Lưu ảnh chụp danh sách thành viên tại thời điểm chốt. Việc có người vào hoặc rời nhóm sau này không được thay đổi hóa đơn cũ. Khi nhập lùi ngày cần chọn danh sách thành viên có hiệu lực ở ngày đó.

### BR03 Chi cá nhân

Nếu thiếu ít nhất một thành viên, không được chi từ quỹ. Người trả trước được cộng toàn bộ tiền đã trả; mỗi người tham gia bị trừ phần của mình. Nếu người trả cũng tham gia, phần của họ tự được khấu trừ. Có thể trả hộ dù không tham gia. Bản đầu hỗ trợ một người trả cho mỗi hóa đơn; nhiều người cùng trả một hóa đơn là mở rộng sau.

### BR04 Chi từ quỹ

Nếu đủ nhóm, chi phí thuộc quỹ. Khi tiền thực sự được lấy từ quỹ, giảm tiền quỹ thực có. Không tạo thêm nợ cá nhân. Chỉ thủ quỹ xác nhận tiền đã ra khỏi quỹ; các thành viên khác có thể gửi yêu cầu chờ xác nhận.

### BR05 Ứng trước cho quỹ

Nếu đủ nhóm nhưng thành viên dùng tiền riêng thanh toán, tăng quỹ cần hoàn cho người đó; chưa giảm tiền quỹ thực có. Khi người nhận xác nhận quỹ hoàn tiền, giảm cả quỹ thực có và quỹ cần hoàn. Cho phép hoàn một phần. Số tiền hoàn không vượt khoản quỹ đang nợ người đó hoặc tiền thực có.

### BR06 Quỹ không đủ

Chính sách mặc định đề xuất: không chốt khoản chi mới thuộc quỹ nếu vượt quỹ khả dụng. Giữ thông tin nhập để người dùng quay lại sau khi bổ sung quỹ. Không tự tạo quỹ âm hoặc đổi thành nợ cá nhân. Chính sách chia phần thiếu cần người dùng chốt riêng trước khi bổ sung.

### BR07 Cộng dồn và bù trừ

Tính số dư ròng từ mọi khoản chi cá nhân và trả nợ được xác nhận trong nhóm. Người nợ được ghép với người có số dư được nhận. Thuật toán phải bảo toàn tổng tiền và cho kết quả ổn định với cùng dữ liệu; không cam kết số giao dịch nhỏ nhất toàn cục. Việc đổi người nhận do bù trừ phải được giải thích và cả nhóm xem được. Giữ nguyên hóa đơn gốc.

Ví dụ: Bình nợ Bạn 200.000đ; Bạn nợ An 150.000đ. Số dư Bình −200.000đ, Bạn +50.000đ, An +150.000đ. Đề xuất Bình trả Bạn 50.000đ và An 150.000đ. Chưa có thanh toán xác nhận thì nợ vẫn còn nguyên.

### BR08 Trả nợ

Người trả chọn người nhận, số tiền và thêm chứng từ hoặc ghi chú tiền mặt. Khi gửi, yêu cầu ở trạng thái chờ. Người nhận xác nhận mới làm thay đổi công nợ. Cho trả một phần; không cho người gửi tự xác nhận khoản mình chuyển. Khi xác nhận phải kiểm tra số dư mới nhất để ngăn xác nhận khoản vượt nghĩa vụ sau khi dữ liệu thay đổi. Nếu không còn phù hợp, từ chối và yêu cầu lập lại.

### BR09 Nộp quỹ

Chỉ cộng tiền vào quỹ khi thủ quỹ xác nhận đã nhận. Tiền nộp quỹ không tự thanh toán nợ cá nhân. Hiển thị tổng đã đóng theo người; kế hoạch mức đóng và số còn thiếu theo đợt là tính năng tiếp theo. Nếu thủ quỹ tự nộp, bản dùng thật cần một quản trị khác xác nhận hoặc đánh dấu rõ tự khai để nhóm kiểm tra; không hiển thị là xác thực độc lập.

### BR10 Xác nhận và ghi nhận một lần

Trạng thái chứng từ: chờ xác nhận, đã xác nhận hoặc bị từ chối. Chỉ cho chuyển từ chờ sang một trạng thái cuối. Từ chối không làm đổi số dư và phải lưu lý do. Một yêu cầu chỉ được hạch toán một lần kể cả khi nhấn lặp, mất kết nối hoặc gửi lại. Kiểm tra quyền, số dư và ghi sổ trong cùng giao dịch dữ liệu ở server.

### BR11 Sửa sai và lịch sử

Không xóa giao dịch đã ghi sổ. Điều chỉnh bằng một bản ghi đảo có lý do, người thực hiện và liên kết bản gốc, sau đó tạo giao dịch đúng. Phải kiểm tra các khoản bị ảnh hưởng; không âm thầm làm quỹ âm hoặc làm khoản hoàn đã trả vượt nghĩa vụ. Bản thử nghiệm có thể giới hạn việc đảo ở giao dịch mới nhất và phải nêu rõ trên giao diện.

### BR12 Thành viên rời nhóm

Giữ lịch sử và ID người rời nhóm. Không xóa thành viên còn nợ hoặc còn khoản quỹ phải hoàn. Việc chia lại quỹ khi rời nhóm cần chính sách được thống nhất; không tự chia quỹ theo số người đang có.

## 5 Yêu cầu chức năng

| ID | Yêu cầu | Tiêu chí nghiệm thu chính |
| --- | --- | --- |
| FR01 | Đăng nhập và thành viên | Mỗi người có danh tính riêng; chỉ thành viên nhóm được truy cập dữ liệu và ảnh của nhóm |
| FR02 | Tạo và tham gia nhóm | Tên nhóm, thành viên, thủ quỹ; lời mời có hạn dùng; không gia nhập bằng cách tự chọn tên người khác |
| FR03 | Thêm hóa đơn | Tên khoản chi, ngày, tổng tiền, người tham gia, nguồn tiền, ảnh, ghi chú; không mất dữ liệu khi lưu lỗi |
| FR04 | Đọc ảnh hóa đơn | Đề xuất tổng tiền từ OCR; cho sửa và bắt buộc kiểm tra; không có kết quả thì nhập tay; không tự ghi sổ từ OCR |
| FR05 | Chia tiền | Tích người tham gia, xem từng phần và tổng trước khi chốt; áp dụng BR01–BR05 |
| FR06 | Quỹ chung | Xem tiền thực có, khoản chờ hoàn, tiền khả dụng và lịch sử; nộp và hoàn một phần |
| FR07 | Công nợ | Số dư từng người, đề xuất tất toán và chi tiết nguồn gốc; bù trừ toàn nhóm |
| FR08 | Chứng từ thanh toán | Đính kèm ảnh, số tiền, người gửi, người nhận; chờ xác nhận đến khi người có quyền xác nhận |
| FR09 | Duyệt và từ chối | Người nhận hoặc thủ quỹ thấy yêu cầu phù hợp; xác nhận một lần; từ chối có lý do |
| FR10 | Lịch sử minh bạch | Cả nhóm xem được người tạo, thời gian, người xác nhận, người tham gia, ảnh và trạng thái |
| FR11 | Điều chỉnh | Bản ghi đảo có lý do; giữ bản gốc; áp dụng BR11 |
| FR12 | Đồng bộ | Thành viên khác nhận thay đổi khi làm mới; không ghi đè giao dịch mới từ thiết bị khác |
| FR13 | Đối soát ngân hàng | Chỉ đánh dấu đối soát khi có giao dịch đáng tin cậy từ nhà cung cấp; ảnh chỉ là tài liệu hỗ trợ |

FR01, FR02, FR12 là điều kiện bắt buộc trước khi dùng thật cho nhiều tài khoản. FR04 và FR13 có thể phát triển sau bản thử nghiệm nhập tay và xác nhận thủ công, nhưng vẫn thuộc yêu cầu sản phẩm.

## 6 Luồng màn hình

### 6.1 Nhóm và tổng quan

Danh sách nhóm → chọn nhóm → xem quỹ thực có, quỹ cần hoàn, quỹ khả dụng, số yêu cầu chờ và các hoạt động gần đây. Có hành động thêm khoản chi, nộp quỹ và thanh toán. Nhãn bản thử nghiệm phải rõ nếu chưa có tài khoản thật.

### 6.2 Thêm khoản chi

Chọn hoặc chụp ảnh → đọc và kiểm tra tổng → nhập tên khoản chi → tích người tham gia → hệ thống thông báo quỹ chịu hoặc cá nhân chịu → chọn nguồn tiền thực tế → xem từng phần → xác nhận lưu. Trường hợp không có ảnh vẫn được nhập tay, đồng thời hiển thị chưa có chứng từ.

### 6.3 Quỹ

Xem ba số dư riêng biệt → gửi yêu cầu nộp → thủ quỹ kiểm tra tiền vào → xác nhận hoặc từ chối. Đối với hoàn ứng: thủ quỹ tạo yêu cầu hoàn → người ứng xác nhận đã nhận → ghi giảm tiền quỹ và khoản phải hoàn.

### 6.4 Công nợ

Xem số dư ròng và giải thích bù trừ → chọn đề xuất thanh toán → nhập số tiền trả một phần hoặc toàn bộ → thêm chứng từ → gửi → người nhận kiểm tra → xác nhận → tính lại mọi đề xuất từ dữ liệu mới nhất.

### 6.5 Lịch sử

Xem các khoản theo thời gian, mở chi tiết hóa đơn và chứng từ. Phân biệt khoản chi thuộc quỹ, cá nhân, nộp quỹ, trả nợ, hoàn ứng và đảo giao dịch. Đề xuất tất toán không xuất hiện như giao dịch đã trả.

## 7 Dữ liệu tối thiểu

| Đối tượng | Trường chính |
| --- | --- |
| User | ID, tên hiển thị, danh tính đăng nhập |
| Group | ID, tên, tiền tệ VND, người tạo, thủ quỹ, phiên bản dữ liệu |
| Membership | Group ID, User ID, vai trò, thời điểm vào và rời nhóm |
| Expense | ID, nhóm, tên, thời điểm, số tiền nguyên, người trả hoặc quỹ, tập thành viên của sự kiện, người tham gia, các phần chia, người tạo |
| Payment request | ID, loại, người gửi, người nhận, số tiền, trạng thái, người và thời gian xác nhận hoặc lý do từ chối |
| Evidence | ID, bản ghi liên quan, vị trí tệp riêng tư, loại tệp, kích thước, người tải lên |
| Ledger entry | ID, nguồn phát sinh, các khoản tăng giảm, người tạo, thời gian, liên kết bản ghi đảo |

Không lấy số dư nhập trực tiếp làm nguồn sự thật. Có thể lưu bản tổng hợp để đọc nhanh, nhưng phải tái dựng được từ lịch sử đã xác nhận. Tách lịch sử nghiệp vụ với thông tin nhạy cảm trong chứng từ ngân hàng.

## 8 Yêu cầu chất lượng và bảo vệ dữ liệu

- Kiểm tra quyền trên server cho cả bản ghi và tệp; URL ảnh công khai không phù hợp với chứng từ ngân hàng.
- Chỉ chấp nhận ảnh được giải mã hợp lệ, giới hạn kích thước; không tin đuôi tệp hoặc MIME do khách gửi. Không đưa khóa đặc quyền vào app.
- Kết nối mã hóa; token lưu bằng cơ chế bảo mật của thiết bị. Log không chứa ảnh bill, token hay số tài khoản đầy đủ.
- Mỗi hành động tiền có mã yêu cầu duy nhất; cập nhật nguyên tử, chống ghi hai lần và chống xác nhận đồng thời vượt số dư.
- Không thông báo lưu thành công khi việc lưu thất bại. Giữ nguyên form khi gặp lỗi, có cách thử lại an toàn.
- Backup có lịch và kiểm tra khôi phục trước triển khai dùng thật. Thời gian lưu dữ liệu và quy trình xóa tài khoản cần chốt trước phát hành.
- Màn hình cuộn được trên điện thoại nhỏ, nhãn đọc màn hình rõ, không dùng màu làm dấu hiệu trạng thái duy nhất.
- Mục tiêu đề xuất: với 10 người và 1.000 giao dịch, thao tác chia tiền tại máy dưới 200 ms; tải tổng quan dưới 2 giây trên mạng ổn định. Đo trên thiết bị thật trước khi cam kết.
- Khi mất mạng, bản dùng chung chỉ cho lưu nháp; không xác nhận chuyển tiền dựa trên dữ liệu cũ.

## 9 Kịch bản nghiệm thu

| ID | Dữ liệu và thao tác | Kết quả |
| --- | --- | --- |
| AT01 | Bình có phần 80.000đ rồi 120.000đ trong hai bữa Bạn trả | Bình nợ tổng 200.000đ |
| AT02 | Bình trả bữa 300.000đ cho Bình và Bạn sau AT01 | Bình còn nợ Bạn 50.000đ |
| AT03 | Bình trả hộ thêm Bạn 80.000đ | Bạn nợ Bình 30.000đ |
| AT04 | Bình nợ Bạn 200.000đ, Bạn nợ An 150.000đ | Bù trừ thành Bình → Bạn 50.000đ và Bình → An 150.000đ |
| AT05 | Nhóm 8 người đóng 500.000đ/người, đều được xác nhận | Quỹ thực có và khả dụng là 4.000.000đ |
| AT06 | Đủ 8 người đi ăn 800.000đ, lấy tiền quỹ | Quỹ còn 3.200.000đ; công nợ cá nhân không đổi |
| AT07 | Chỉ 5/8 người đi ăn 1.000.000đ, Bình trả | Mỗi người chịu 200.000đ; quỹ không đổi |
| AT08 | Đủ nhóm, Bình ứng 800.000đ, quỹ thực có 4.000.000đ | Quỹ thực có 4.000.000đ; cần hoàn 800.000đ; khả dụng 3.200.000đ |
| AT09 | Quỹ hoàn Bình 300.000đ, Bình xác nhận | Quỹ thực có 3.700.000đ; cần hoàn 500.000đ; khả dụng vẫn 3.200.000đ |
| AT10 | Gửi ảnh nộp 500.000đ nhưng chưa duyệt hoặc bị từ chối | Quỹ không tăng |
| AT11 | Gửi trả nợ 150.000đ khi đang nợ 200.000đ | Chưa xác nhận vẫn nợ 200.000đ; xác nhận còn 50.000đ |
| AT12 | 100.000đ chia 3 | 33.334đ + 33.333đ + 33.333đ, không mất 1đ |
| AT13 | Nhấn xác nhận hai lần cùng yêu cầu | Lần sau không hạch toán thêm |
| AT14 | Không chọn ai, số tiền ≤0, ID lạ hoặc người trùng | Từ chối lưu, không đổi dữ liệu |
| AT15 | Quỹ khả dụng 100.000đ, chi đủ nhóm 200.000đ | Báo thiếu 100.000đ, không âm quỹ, không tự chuyển sang nợ cá nhân |
| AT16 | Khoản trả nợ chờ duyệt đã vượt số dư hiện tại | Chặn xác nhận; không sinh thanh toán vượt nghĩa vụ |
| AT17 | Người không thuộc nhóm truy cập dữ liệu hoặc ảnh | Bị từ chối tại server |
| AT18 | Hai thiết bị đồng thời xác nhận chi quỹ | Không chi vượt quỹ và không mất giao dịch |
| AT19 | Thêm thành viên sau một hóa đơn đã chốt | Phân bổ và loại chi của hóa đơn cũ giữ nguyên |
| AT20 | Đóng và mở lại ứng dụng | Khôi phục chính xác nhóm, chứng từ, giao dịch và số dư |

## 10 Các quyết định cần chốt trước khi xây dựng

| ID | Câu hỏi cần thống nhất | Đề xuất hiện tại chưa được duyệt |
| --- | --- | --- |
| Q01 | Xác thực bill ngân hàng nghĩa là người nhận xác nhận hay đối soát giao dịch tự động? | Người nhận hoặc thủ quỹ xác nhận trước; tích hợp ngân hàng là yêu cầu riêng |
| Q02 | Đủ người tham gia nhưng quỹ thiếu thì xử lý thế nào? | Chưa chốt khoản chi, yêu cầu nộp thêm; không tự chia phần thiếu |
| Q03 | Mọi khoản đều chia đều hay cần phần riêng, theo món hoặc trọng số? | Chia đều trong phạm vi đầu tiên |
| Q04 | Nộp quỹ theo đợt bằng nhau hay mỗi người tự chọn số tiền? | Ghi nhận số thực nộp, chưa áp dụng hạn mức theo đợt |
| Q05 | Ai được thêm, duyệt và sửa khoản chi? Thủ quỹ tự nộp thì ai duyệt? | Thành viên thêm; thủ quỹ duyệt tiền quỹ; người nhận duyệt trả nợ; cần quy tắc duyệt độc lập cho thủ quỹ |
| Q06 | Tiền quỹ nằm ở tài khoản của một thủ quỹ hay nhiều người giữ? | Một thủ quỹ, một quỹ VND mỗi nhóm |
| Q07 | Nếu có khách hoặc người vào nhóm sau, thế nào là đủ nhóm cho sự kiện đó? | Dùng danh sách thành viên có hiệu lực ở thời điểm sự kiện; khách cần quy tắc riêng |
| Q08 | Người rời nhóm được hoàn phần quỹ còn dư thế nào? | Chưa tự hoàn; phải thống nhất cách tính trước |
| Q09 | Đưa ảnh bill vào có bắt buộc tự đọc tổng tiền ngay bản đầu không? | Cho nhập tay và đính kèm ảnh; OCR cần được xác nhận là phạm vi bắt buộc hay bước sau |
| Q10 | Có cho nhiều người cùng ứng tiền một bill không? | Một người trả mỗi bill trong phạm vi đầu tiên |
| Q11 | Có cho bù trừ đổi người nhận tiền trong cả nhóm không cần duyệt từng lần không? | Hiển thị đề xuất rõ ràng; chỉ ghi thanh toán sau xác nhận của người nhận |

Sau khi thống nhất các câu hỏi này, cập nhật quy tắc nghiệp vụ, quyền hạn và tiêu chí nghiệm thu thành FRS được duyệt. Chỉ bắt đầu thiết kế chi tiết và triển khai khi người dùng yêu cầu bước đó. Hướng bản thử nghiệm trên máy được giữ làm định hướng tiếp theo, chưa phải lệnh triển khai.
