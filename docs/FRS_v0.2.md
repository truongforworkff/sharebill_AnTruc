# Đặc tả yêu cầu chức năng Share Bill

Phiên bản 0.2 · Ngày 08 tháng 11 năm 2026 · Bản nháp để thảo luận, chưa duyệt triển khai

Share Bill quản lý chia tiền, công nợ và quỹ chung cho nhóm bạn. Tài liệu được chia thành các phân hệ độc lập để bổ sung chức năng mà vẫn theo dõi được tác động đến quy tắc, dữ liệu và nghiệm thu. Mỗi yêu cầu có một mã cố định; việc sắp xếp lại tài liệu không làm thay đổi phạm vi đã thống nhất.

## 1 Quản lý và tra cứu tài liệu

### 1.1 Cách đọc

- Mục 2 và 3: mục tiêu, vai trò và thuật ngữ dùng chung.
- Mục 4: danh mục và đặc tả từng phân hệ M01–M07.
- Mục 5: quy tắc nghiệp vụ BR dùng chung giữa các phân hệ.
- Mục 6: dữ liệu và yêu cầu chất lượng.
- Mục 7: tình huống nghiệm thu AT.
- Mục 8: câu hỏi Q còn mở.
- Mục 9: cách ghi nhận chức năng mới và mẫu đặc tả.

### 1.2 Mã và trạng thái

| Loại | Cách sử dụng |
| --- | --- |
| M01–M07 | Phân hệ chức năng; bổ sung phân hệ mới bằng mã tiếp theo |
| FR01–FR13 | Yêu cầu chức năng; giữ mã cũ khi đổi vị trí hoặc đổi tên |
| BR01–BR12 | Quy tắc nghiệp vụ dùng chung |
| AT01–AT20 | Tình huống nghiệm thu; chưa phải kết quả kiểm thử đã chạy |
| Q01–Q11 | Câu hỏi chưa có quyết định |

Trạng thái yêu cầu gồm: Đề xuất, Cần chốt, Đã duyệt, Hoãn và Loại bỏ. Xác nhận một ý tưởng không tự động phê duyệt toàn bộ chi tiết của yêu cầu. Hiện các đặc tả chi tiết FR đều ở trạng thái Cần chốt. Chỉ đổi thành Đã duyệt khi có quyết định của chủ sản phẩm.

### 1.3 Lịch sử phiên bản

| Phiên bản | Nội dung |
| --- | --- |
| 0.1 | Tổng hợp ý tưởng, quy tắc, chức năng và câu hỏi ban đầu |
| 0.2 | Chia 7 phân hệ; thêm mục lục, trạng thái, liên kết yêu cầu và mẫu bổ sung; giữ mã FR, BR, AT, Q và các quyết định đang mở |

## 2 Tổng quan và phạm vi

### 2.1 Những yêu cầu đã xác nhận

- Định hướng app di động đa nền tảng bằng Dart.
- Nhóm bạn khoảng 6–10 người, dùng cho ăn uống và đi chơi.
- Đưa bill vào, chọn những người tham gia và tự chia tiền.
- Cộng dồn khoản chưa trả qua nhiều lần; bù trừ khi thành viên khác trả trước, mở rộng trên cả nhóm.
- Có nộp quỹ chung; chỉ dùng quỹ khi tất cả thành viên tham gia hôm đó.
- Thành viên trong nhóm xem được các khoản thu chi và chứng từ.
- Có nhu cầu xác thực bill ngân hàng; cách xác thực chưa được chốt.

Các chi tiết còn lại trong tài liệu là **đề xuất để thảo luận**, bao gồm vai trò, cách duyệt, giới hạn tiền, chia số lẻ, xử lý thiếu quỹ và thời điểm ghi nhận. Các tình huống nghiệm thu tương ứng chỉ có hiệu lực sau khi quy tắc được duyệt. Việc chọn hướng thử nghiệm trên máy không đồng nghĩa cho phép bắt đầu viết app trước khi chốt FRS.

### 2.2 Phạm vi đề xuất

- Phục vụ nhóm khoảng 6–10 người, cho phép tạo nhóm từ 2 thành viên; không gắn thuật toán với một số lượng cố định.
- App Flutter bằng Dart, ưu tiên Android và iOS, giao diện tiếng Việt, tiền VND.
- Thành viên được xem thu, chi, hóa đơn, khoản đóng quỹ, lịch sử xác nhận và công nợ của nhóm mình.
- Chi phí phát sinh qua nhiều ngày vẫn được cộng dồn đến khi có giao dịch thanh toán được xác nhận.
- Đủ tất cả thành viên tham gia: chi phí thuộc quỹ. Chỉ một phần nhóm tham gia: chi phí cá nhân của những người được chọn.
- Hỗ trợ chứng từ chuyển khoản và xác nhận của người nhận. Đối soát ngân hàng tự động là một tích hợp riêng, không được suy ra từ ảnh.

## 3 Vai trò và thuật ngữ dùng chung

### 3.1 Vai trò

| Vai trò | Quyền |
| --- | --- |
| Thành viên | Xem dữ liệu nhóm; thêm khoản chi; gửi yêu cầu ghi nhận nộp quỹ và trả nợ; xác nhận tiền mình nhận; báo sai chứng từ |
| Quản trị nhóm | Các quyền thành viên; mời thành viên; quản lý tên nhóm và vai trò; xử lý điều chỉnh có lịch sử |
| Thủ quỹ | Các quyền thành viên; xác nhận tiền quỹ nhận; xác nhận tiền quỹ chi; xử lý hoàn tiền người ứng trước |

Người tạo nhóm ban đầu kiêm quản trị và thủ quỹ. Việc đổi thủ quỹ phải có bàn giao số dư được xác nhận. Không dùng việc chọn tên trên giao diện thay cho đăng nhập trong bản dùng thật.

### 3.2 Thuật ngữ và số dư

- **Khoản chi**: hóa đơn đã được chốt với tổng tiền và danh sách tham gia.
- **Công nợ cá nhân**: số tiền thành viên cần trả hoặc được nhận sau các khoản chi cá nhân và thanh toán đã xác nhận. Số dương là được nhận; số âm là phải trả.
- **Tiền quỹ thực có**: các khoản nộp đã xác nhận trừ tiền đã chi thực tế từ quỹ và tiền đã hoàn ứng.
- **Quỹ cần hoàn**: tiền thành viên đã ứng cho các khoản chi thuộc quỹ nhưng quỹ chưa hoàn.
- **Quỹ khả dụng**: tiền quỹ thực có trừ tổng quỹ cần hoàn. Không trộn quỹ vào thuật toán bù trừ nợ cá nhân.
- **Chứng từ**: ảnh hóa đơn ăn uống hoặc ảnh chuyển khoản; không tự chứng minh tiền đã vào tài khoản.
- **Đề xuất tất toán**: danh sách chuyển tiền được tính từ số dư hiện tại, chưa phải giao dịch đã xảy ra.

## 4 Các phân hệ chức năng

### 4.1 Danh mục phân hệ

| Mã | Phân hệ | Yêu cầu |
| --- | --- | --- |
| M01 | Tài khoản và nhóm | FR01, FR02 |
| M02 | Hóa đơn và khoản chi | FR03, FR04 |
| M03 | Người tham gia và chia tiền | FR05 |
| M04 | Quỹ chung | FR06 |
| M05 | Công nợ và bù trừ | FR07 |
| M06 | Thanh toán và xác thực | FR08, FR09, FR13 |
| M07 | Lịch sử và tính nhất quán | FR10, FR11, FR12 |

Luồng liên kết chính: M01 xác định thành viên → M02 ghi bill → M03 chia tiền → M04 ghi quỹ hoặc M05 ghi nợ → M06 xác nhận thanh toán → M07 cung cấp lịch sử chung. Quy tắc liên phân hệ được mô tả một lần ở mục 5.

### 4.2 M01 Tài khoản và nhóm

**Mục tiêu:** Quản lý ai thuộc nhóm và ai được thao tác, làm nền tảng cho quyền xem dữ liệu.

**Tình trạng phạm vi:** Mục tiêu quản lý nhóm đã xác nhận. Đăng nhập, lời mời và cách phân quyền là đề xuất chi tiết.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR01 | Đăng nhập và thành viên | Cần chốt |
| FR02 | Tạo và tham gia nhóm | Cần chốt |

**Hành vi bắt buộc khi đặc tả được duyệt:**
- **FR01:** Mỗi người có danh tính riêng; chỉ thành viên nhóm được truy cập dữ liệu và ảnh của nhóm.
- **FR02:** Tên nhóm, thành viên, thủ quỹ; lời mời có hạn dùng; không gia nhập bằng cách tự chọn tên người khác.

**Dữ liệu đầu vào:** Thông tin đăng nhập, tên nhóm, danh sách thành viên, vai trò và lời mời.

**Luồng chính:** Đăng nhập → tạo hoặc nhận lời mời vào nhóm → xem thành viên → quản lý vai trò theo quyền.

**Kết quả:** Thành viên hợp lệ được vào nhóm; người ngoài không được xem khoản chi và chứng từ.

**Ngoại lệ:** Ngăn truy cập trái quyền; giữ lịch sử khi có người rời nhóm; cách bàn giao thủ quỹ cần được chốt.

**Liên kết:** Quy tắc BR02, BR12. Nghiệm thu AT17, AT19. Câu hỏi Q05, Q07, Q08.

### 4.3 M02 Hóa đơn và khoản chi

**Mục tiêu:** Ghi nhận một lần ăn uống hoặc đi chơi cùng chứng từ và số tiền.

**Tình trạng phạm vi:** Thêm bill đã xác nhận. Tự đọc ảnh bằng OCR và phạm vi nhiều người trả chưa chốt.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR03 | Thêm hóa đơn | Cần chốt |
| FR04 | Đọc ảnh hóa đơn | Cần chốt |

**Hành vi bắt buộc khi đặc tả được duyệt:**
- **FR03:** Tên khoản chi, ngày, tổng tiền, người tham gia, nguồn tiền, ảnh, ghi chú; không mất dữ liệu khi lưu lỗi.
- **FR04:** Đề xuất tổng tiền từ OCR; cho sửa và bắt buộc kiểm tra; không có kết quả thì nhập tay; không tự ghi sổ từ OCR.

**Dữ liệu đầu vào:** Tên khoản chi, ngày phát sinh, ảnh bill, tổng tiền, ghi chú và người tạo.

**Luồng chính:** Thêm ảnh hoặc nhập tay → kiểm tra tổng tiền → chọn người tham gia ở M03 → chọn nguồn tiền → xem lại → lưu.

**Kết quả:** Khoản chi có đủ dữ liệu để chia tiền; ảnh gắn đúng khoản và được các thành viên hợp lệ xem.

**Ngoại lệ:** Ảnh không đọc được thì cho nhập tay; không ghi sổ khi thiếu số tiền hoặc danh sách tham gia; giữ form nếu lưu lỗi.

**Liên kết:** Quy tắc BR01, BR02, BR10. Nghiệm thu AT14, AT20. Câu hỏi Q09, Q10.

### 4.4 M03 Người tham gia và chia tiền

**Mục tiêu:** Xác định ai chịu chi phí và khoản chi thuộc quỹ hay công nợ cá nhân.

**Tình trạng phạm vi:** Chọn người và điều kiện dùng quỹ đã xác nhận. Cách chia đều, chia riêng và xử lý số lẻ đang đề xuất.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR05 | Chia tiền | Cần chốt |

**Hành vi bắt buộc khi đặc tả được duyệt:**
- **FR05:** Tích người tham gia, xem từng phần và tổng trước khi chốt; áp dụng BR01–BR05.

**Dữ liệu đầu vào:** Tổng tiền, tập thành viên của sự kiện, người tham gia và nguồn tiền thực trả.

**Luồng chính:** Tích người tham gia → xác định đủ nhóm hay một phần nhóm → xem phần tiền từng người → xác nhận phân bổ.

**Kết quả:** Tổng phần chia bằng tổng bill; đủ nhóm chuyển sang M04, một phần nhóm chuyển sang M05.

**Ngoại lệ:** Không chọn người hoặc trùng ID thì chặn lưu; người vào nhóm sau không làm thay đổi bill cũ; khách và tiền lẻ theo quy tắc đã duyệt.

**Liên kết:** Quy tắc BR01–BR05. Nghiệm thu AT06, AT07, AT12, AT14, AT19. Câu hỏi Q03, Q07, Q10.

### 4.5 M04 Quỹ chung

**Mục tiêu:** Theo dõi tiền nộp quỹ, tiền chi, khoản ứng trước và tiền cần hoàn.

**Tình trạng phạm vi:** Nộp quỹ và dùng quỹ khi đủ nhóm đã xác nhận. Cách duyệt, thiếu quỹ, hoàn ứng và đợt đóng cần chốt chi tiết.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR06 | Quỹ chung | Cần chốt |

**Hành vi bắt buộc khi đặc tả được duyệt:**
- **FR06:** Xem tiền thực có, khoản chờ hoàn, tiền khả dụng và lịch sử; nộp và hoàn một phần.

**Dữ liệu đầu vào:** Người nộp, số tiền, khoản chi đủ nhóm, nguồn trả và yêu cầu hoàn ứng.

**Luồng chính:** Nộp quỹ → chờ xác nhận M06 → tăng tiền thực có. Chi đủ nhóm → chi quỹ hoặc ghi cần hoàn. Hoàn ứng → người nhận xác nhận → giảm tiền quỹ và khoản cần hoàn.

**Kết quả:** Hiển thị riêng tiền thực có, tổng cần hoàn và tiền khả dụng; theo dõi tổng đóng theo người.

**Ngoại lệ:** Thiếu quỹ theo BR06 đang chờ chốt; không cộng tiền chờ xác nhận; không trừ hai lần khi một thành viên ứng trước.

**Liên kết:** Quy tắc BR04–BR06, BR09, BR10. Nghiệm thu AT05, AT06, AT08, AT09, AT10, AT15, AT18. Câu hỏi Q02, Q04, Q05, Q06, Q08.

### 4.6 M05 Công nợ và bù trừ

**Mục tiêu:** Cộng dồn số dư cá nhân qua nhiều sự kiện và đề xuất chuyển tiền trong toàn nhóm.

**Tình trạng phạm vi:** Cộng dồn và bù trừ cả nhóm đã xác nhận. Cách đồng ý đổi người nhận và cách tất toán cần chốt.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR07 | Công nợ | Cần chốt |

**Hành vi bắt buộc khi đặc tả được duyệt:**
- **FR07:** Số dư từng người, đề xuất tất toán và chi tiết nguồn gốc; bù trừ toàn nhóm.

**Dữ liệu đầu vào:** Phần chia cá nhân từ M03 và các khoản trả nợ đã được M06 xác nhận.

**Luồng chính:** Xem số dư → mở các khoản tạo ra số dư → xem đề xuất bù trừ → chọn trả một phần hoặc toàn bộ qua M06.

**Kết quả:** Mỗi người biết cần trả hoặc được nhận bao nhiêu; đề xuất chỉ thay đổi cách tất toán, giữ nguyên bill gốc.

**Ngoại lệ:** Không trộn nợ quỹ với nợ cá nhân; không coi đề xuất là đã thanh toán; kiểm tra số dư mới khi xác nhận.

**Liên kết:** Quy tắc BR03, BR07, BR08. Nghiệm thu AT01–AT04, AT07, AT11, AT16. Câu hỏi Q11.

### 4.7 M06 Thanh toán và xác thực

**Mục tiêu:** Ghi nhận tiền thực nhận, quản lý chứng từ và phân biệt xác nhận thủ công với đối soát ngân hàng.

**Tình trạng phạm vi:** Nhu cầu xác thực bill ngân hàng đã xác nhận. Chọn xác nhận thủ công hay đối soát tự động vẫn đang mở.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR08 | Chứng từ thanh toán | Cần chốt |
| FR09 | Duyệt và từ chối | Cần chốt |
| FR13 | Đối soát ngân hàng | Cần chốt |

**Hành vi bắt buộc khi đặc tả được duyệt:**
- **FR08:** Đính kèm ảnh, số tiền, người gửi, người nhận; chờ xác nhận đến khi người có quyền xác nhận.
- **FR09:** Người nhận hoặc thủ quỹ thấy yêu cầu phù hợp; xác nhận một lần; từ chối có lý do.
- **FR13:** Chỉ đánh dấu đối soát khi có giao dịch đáng tin cậy từ nhà cung cấp; ảnh chỉ là tài liệu hỗ trợ.

**Dữ liệu đầu vào:** Loại giao dịch, người gửi, người nhận, số tiền, ảnh chuyển khoản hoặc ghi chú tiền mặt.

**Luồng chính:** Gửi yêu cầu → chờ người có quyền kiểm tra → xác nhận hoặc từ chối có lý do → cập nhật số dư đúng một lần.

**Kết quả:** Giao dịch có trạng thái, người duyệt và thời gian xử lý; khoản từ chối không làm đổi số dư.

**Ngoại lệ:** Không xác nhận từ ảnh đơn thuần; chặn duyệt trùng và khoản vượt số dư mới nhất; thủ quỹ tự nộp cần quy tắc riêng.

**Liên kết:** Quy tắc BR05, BR08–BR10. Nghiệm thu AT09–AT11, AT13, AT16, AT18. Câu hỏi Q01, Q05.

### 4.8 M07 Lịch sử và tính nhất quán

**Mục tiêu:** Cho cả nhóm kiểm tra dữ liệu chung và theo dõi mọi điều chỉnh.

**Tình trạng phạm vi:** Cả nhóm xem được các khoản đã xác nhận. Cơ chế sửa sai, đồng bộ và quyền thao tác là đề xuất.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR10 | Lịch sử minh bạch | Cần chốt |
| FR11 | Điều chỉnh | Cần chốt |
| FR12 | Đồng bộ | Cần chốt |

**Hành vi bắt buộc khi đặc tả được duyệt:**
- **FR10:** Cả nhóm xem được người tạo, thời gian, người xác nhận, người tham gia, ảnh và trạng thái.
- **FR11:** Bản ghi đảo có lý do; giữ bản gốc; áp dụng BR11.
- **FR12:** Thành viên khác nhận thay đổi khi làm mới; không ghi đè giao dịch mới từ thiết bị khác.

**Dữ liệu đầu vào:** Khoản chi, đóng quỹ, thanh toán, kết quả duyệt và yêu cầu sửa sai.

**Luồng chính:** Mở tổng quan → xem lịch sử → mở chi tiết và chứng từ → yêu cầu điều chỉnh có lý do → giữ cả bản gốc và bản điều chỉnh.

**Kết quả:** Lịch sử có người tạo, người duyệt, thời gian, người tham gia và trạng thái; thiết bị khác thấy dữ liệu sau làm mới.

**Ngoại lệ:** Không xóa dấu vết khoản đã ghi sổ; không ghi đè thay đổi của người khác; lưu lỗi không được báo thành công.

**Liên kết:** Quy tắc BR10–BR12. Nghiệm thu AT13, AT17–AT20. Câu hỏi Q05.

## 5 Quy tắc nghiệp vụ dùng chung

Các mã BR được giữ từ phiên bản 0.1. Phân hệ chỉ tham chiếu quy tắc; khi thay đổi một BR cần rà soát mọi phân hệ liên quan. Những lựa chọn chưa được duyệt vẫn là đề xuất.

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

## 6 Dữ liệu và yêu cầu chất lượng

### 6.1 Dữ liệu tối thiểu

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

### 6.2 Chất lượng và bảo vệ dữ liệu

- Kiểm tra quyền trên server cho cả bản ghi và tệp; URL ảnh công khai không phù hợp với chứng từ ngân hàng.
- Chỉ chấp nhận ảnh được giải mã hợp lệ, giới hạn kích thước; không tin đuôi tệp hoặc MIME do khách gửi. Không đưa khóa đặc quyền vào app.
- Kết nối mã hóa; token lưu bằng cơ chế bảo mật của thiết bị. Log không chứa ảnh bill, token hay số tài khoản đầy đủ.
- Mỗi hành động tiền có mã yêu cầu duy nhất; cập nhật nguyên tử, chống ghi hai lần và chống xác nhận đồng thời vượt số dư.
- Không thông báo lưu thành công khi việc lưu thất bại. Giữ nguyên form khi gặp lỗi, có cách thử lại an toàn.
- Backup có lịch và kiểm tra khôi phục trước triển khai dùng thật. Thời gian lưu dữ liệu và quy trình xóa tài khoản cần chốt trước phát hành.
- Màn hình cuộn được trên điện thoại nhỏ, nhãn đọc màn hình rõ, không dùng màu làm dấu hiệu trạng thái duy nhất.
- Mục tiêu đề xuất: với 10 người và 1.000 giao dịch, thao tác chia tiền tại máy dưới 200 ms; tải tổng quan dưới 2 giây trên mạng ổn định. Đo trên thiết bị thật trước khi cam kết.
- Khi mất mạng, bản dùng chung chỉ cho lưu nháp; không xác nhận chuyển tiền dựa trên dữ liệu cũ.

## 7 Tình huống nghiệm thu

Đây là kết quả mong đợi để kiểm tra đặc tả sau khi được duyệt. AT01–AT03 là một chuỗi liên tiếp; AT05–AT06 và AT08–AT09 là các chuỗi riêng. Các trường hợp còn lại dùng dữ liệu đầu vào được ghi tại từng dòng. Không coi các AT là bằng chứng ứng dụng đã được xây dựng hoặc kiểm thử.

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

## 8 Câu hỏi và quyết định còn mở

Tất cả Q01–Q11 hiện ở trạng thái Chưa chốt. Khi có câu trả lời, giữ mã Q và ghi quyết định, ngày xác nhận, yêu cầu FR cùng quy tắc BR bị ảnh hưởng. Không xóa câu hỏi đã giải quyết khỏi lịch sử.

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

## 9 Bổ sung chức năng và quản lý thay đổi

### 9.1 Cách thêm chức năng

Gán chức năng vào phân hệ phù hợp, cấp mã FR tiếp theo và điền mẫu bên dưới với trạng thái Đề xuất. Không đánh lại số, tái sử dụng mã đã bỏ hoặc tự chốt ưu tiên và phiên bản phát hành.

Liên kết các BR, AT, Q và FR bị ảnh hưởng. Khi có quyết định, cập nhật trạng thái và lịch sử phiên bản; rà soát tác động đến quỹ, công nợ và quyền truy cập. Chỉ triển khai khi được yêu cầu.

### 9.2 Mẫu đặc tả một chức năng

| Trường | Nội dung cần ghi |
| --- | --- |
| Mã và tên | FR tiếp theo cùng tên ngắn, rõ nghĩa |
| Phân hệ | Mã M sở hữu chức năng |
| Mục tiêu | Vấn đề người dùng cần giải quyết |
| Trạng thái và ưu tiên | Đề xuất hoặc trạng thái đã thống nhất; ưu tiên để Chưa chốt nếu chưa quyết định |
| Người thao tác và quyền | Ai được thực hiện, ai được xem, ai phải duyệt |
| Điều kiện và đầu vào | Điều kiện trước khi thao tác, trường bắt buộc, kiểm tra hợp lệ |
| Luồng chính | Các bước từ thao tác người dùng đến phản hồi hệ thống |
| Ngoại lệ | Thiếu dữ liệu, quyền, tiền, mất mạng hoặc yêu cầu trùng |
| Kết quả và ảnh hưởng | Dữ liệu thay đổi; tác động đến quỹ, nợ và lịch sử |
| Liên kết | BR, AT, Q và các FR phụ thuộc hoặc bị ảnh hưởng |
| Quyết định | Người xác nhận, ngày và nội dung duyệt |

### 9.3 Danh sách ý tưởng mới

Chưa có chức năng bổ sung cụ thể được chốt trong lần chỉnh tài liệu này. Khi có ý tưởng mới, ghi tại đây trước khi đặc tả và chuyển vào phân hệ phù hợp. Một ý tưởng chưa được duyệt không làm thay đổi phạm vi đang có.
