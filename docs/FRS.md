# Đặc tả yêu cầu chức năng Share Bill

Phiên bản 0.6 · Ngày 12 tháng 11 năm 2026 · Phạm vi bắt buộc đã cập nhật, chi tiết nghiệp vụ còn cần chốt

Share Bill quản lý chia tiền, công nợ và quỹ chung cho nhóm bạn. Tài liệu được chia thành các phân hệ độc lập để bổ sung chức năng mà vẫn theo dõi được tác động đến quy tắc, dữ liệu và nghiệm thu. Mỗi yêu cầu có một mã cố định; phiên bản này bổ sung phạm vi bắt buộc theo xác nhận của chủ sản phẩm. Bản thiết kế HTML dùng để duyệt trải nghiệm, không phải ứng dụng vận hành thật.

## 1 Quản lý và tra cứu tài liệu

### 1.1 Cách đọc

- Mục 2 và 3: mục tiêu, vai trò và thuật ngữ dùng chung.
- Mục 4: danh mục và đặc tả từng phân hệ M01–M10.
- Mục 5: quy tắc nghiệp vụ BR dùng chung giữa các phân hệ.
- Mục 6: dữ liệu và yêu cầu chất lượng.
- Mục 7: tình huống nghiệm thu AT.
- Mục 8: câu hỏi Q còn mở.
- Mục 9: cách ghi nhận chức năng mới và mẫu đặc tả.
- Mục 10: đối chiếu yêu cầu với màn hình và giới hạn bản mẫu.

### 1.2 Mã và trạng thái

| Loại | Cách sử dụng |
| --- | --- |
| M01–M10 | Phân hệ chức năng; bổ sung phân hệ mới bằng mã tiếp theo |
| FR01–FR19 | Yêu cầu chức năng; giữ mã cũ khi đổi vị trí hoặc đổi tên |
| BR01–BR18 | Quy tắc nghiệp vụ dùng chung |
| AT01–AT54 | Tình huống nghiệm thu; chưa phải kết quả kiểm thử đã chạy |
| Q01–Q15 | Câu hỏi chưa có quyết định |

Tách hai trạng thái: phạm vi chức năng và mức duyệt chi tiết. “Bắt buộc” nghĩa là phải có trong sản phẩm, không phải đã triển khai hoặc đã chốt mọi quy tắc. FR14–FR19 và các chức năng nền tảng là bắt buộc; FR04 tự đọc tiền từ ảnh và tính phần chia ngay đã được xác nhận ngày 12/11/2026; cách tích hợp ngân hàng ở FR13 vẫn cần quyết định kỹ thuật/phạm vi cụ thể. Các mốc triển khai chưa được ấn định. Ý tưởng khảo sát về người đến muộn, được mời hoặc chia quỹ khi rời nhóm không tự trở thành yêu cầu đã duyệt.

### 1.3 Lịch sử phiên bản

| Phiên bản | Nội dung |
| --- | --- |
| 0.1 | Tổng hợp ý tưởng, quy tắc, chức năng và câu hỏi ban đầu |
| 0.2 | Chia 7 phân hệ; thêm trạng thái, liên kết yêu cầu và mẫu bổ sung; giữ các quyết định đang mở |
| 0.3 | Bổ sung FR14–19, công nợ theo người và nhiều nhóm; cập nhật bản HTML |
| 0.4 | Link riêng xem nhóm không tài khoản; link chung trưởng nhóm duyệt; liên kết hồ sơ giữ lịch sử; AT39–44 |
| 0.5 | FR04 bắt buộc đọc tiền từ ảnh và tính chia ngay; xử lý tổng tiền mơ hồ, sửa tay, OCR lỗi; sửa BR06 cho ứng trước khi thiếu quỹ; AT45–50 |
| 0.6 | Xác nhận 12/11/2026: cá nhân trả trước mặc định chia công nợ cả khi đủ nhóm và quỹ 0đ; chi/ứng cho quỹ phải chọn rõ; sửa BR03–BR06, AT08/AT50, thêm AT51–54 |

## 2 Tổng quan và phạm vi

### 2.1 Những yêu cầu đã xác nhận

- Định hướng app di động đa nền tảng bằng Dart.
- Nhóm bạn khoảng 6–10 người, dùng cho ăn uống và đi chơi.
- Đưa bill vào, chọn những người tham gia và tự chia tiền.
- Cộng dồn khoản chưa trả qua nhiều lần; bù trừ khi thành viên khác trả trước, mở rộng trên cả nhóm.
- Có nộp quỹ chung; chỉ được chọn dùng quỹ khi tất cả thành viên tham gia hôm đó. Đủ nhóm không bắt buộc dùng quỹ. Cá nhân trả trước mặc định chia công nợ, kể cả khi quỹ 0đ.
- Thành viên trong nhóm xem được các khoản thu chi và chứng từ.
- Có nhu cầu xác thực bill ngân hàng; cách xác thực chưa được chốt.
- Chốt tiền theo tuần hoặc tháng; tổng hợp phần cần trả, được nhận và quỹ; khoản chưa trả được chuyển sang kỳ sau.
- Giải thích số dư đến từng khoản gốc và các bước bù trừ; nhóm được chọn có áp dụng bù trừ đổi người nhận hay không.
- Quy ước nhóm về dùng quỹ, chia tiền và quyền duyệt; thay đổi có lịch sử và thời điểm hiệu lực.
- Thành viên phản hồi khoản chia sai; xử lý phản hồi trước khi chốt kỳ.
- Link riêng mở nhóm trên trình duyệt không cần tài khoản; link chung phải được trưởng nhóm duyệt.
- Nhắc thanh toán theo kỳ, có quyền kiểm soát thông báo; không gửi nhắc cho khoản đã thanh toán.

Các chức năng trên là phạm vi nền tảng bắt buộc, không được trình bày như lợi thế cạnh tranh đã chứng minh. Chi tiết như vai trò duyệt, giới hạn, làm tròn và kênh nhắc vẫn là đề xuất có ghi rõ. Cách tách chia bill cá nhân khỏi chi/ứng cho quỹ đã được xác nhận ngày 12/11/2026 tại BR03–BR06. Người dùng đã yêu cầu cập nhật FRS, giao diện HTML và ứng dụng Flutter. Backend và ngân hàng thật chưa được triển khai.

### 2.2 Nền tảng và giới hạn hiện tại

- Phục vụ nhóm khoảng 6–10 người, cho phép tạo nhóm từ 2 thành viên; không gắn thuật toán với một số lượng cố định.
- App Flutter bằng Dart, ưu tiên Android và iOS, giao diện tiếng Việt, tiền VND.
- Thành viên được xem thu, chi, hóa đơn, khoản đóng quỹ, lịch sử xác nhận và công nợ của nhóm mình.
- Chi phí phát sinh qua nhiều ngày vẫn được cộng dồn đến khi có giao dịch thanh toán được xác nhận.
- Cá nhân trả trước: mặc định chia công nợ giữa những người tham gia, kể cả đủ nhóm và quỹ bằng 0. Đủ tất cả thành viên mới được chọn “Chi trực tiếp từ quỹ” hoặc “Ứng trước cho quỹ”; một phần nhóm chỉ chia bill cá nhân.
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
| M01 | Tài khoản và nhóm | FR01, FR02, FR18 |
| M02 | Hóa đơn và khoản chi | FR03, FR04 |
| M03 | Người tham gia và chia tiền | FR05 |
| M04 | Quỹ chung | FR06 |
| M05 | Công nợ và bù trừ | FR07, FR15 |
| M06 | Thanh toán và xác thực | FR08, FR09, FR13 |
| M07 | Lịch sử và tính nhất quán | FR10, FR11, FR12 |
| M08 | Chốt kỳ và nhắc thanh toán | FR14, FR19 |
| M09 | Quy ước nhóm | FR16 |
| M10 | Phản hồi và xử lý sai lệch | FR17 |

Luồng liên kết chính: M01 xác định thành viên → M02 ghi bill → M03 chia tiền → M04 ghi quỹ hoặc M05 ghi nợ → M06 xác nhận thanh toán → M07 cung cấp lịch sử chung. Quy tắc liên phân hệ được mô tả một lần ở mục 5.

### 4.2 M01 Tài khoản và nhóm

**Mục tiêu:** Quản lý ai thuộc nhóm và ai được thao tác, làm nền tảng cho quyền xem dữ liệu.

**Tình trạng phạm vi:** Quản lý nhóm và tham gia qua link là bắt buộc. Hai luồng lời mời đã chốt: link riêng theo thành viên và link chung cần trưởng nhóm phê duyệt; chi tiết kỹ thuật xác thực cần triển khai theo BR17.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR01 | Đăng nhập và thành viên | Bắt buộc; chi tiết cần chốt |
| FR02 | Tạo và tham gia nhóm | Bắt buộc; chi tiết cần chốt |

**Hành vi bắt buộc:**
- **FR01:** Tách hồ sơ thành viên khỏi tài khoản. Membership ID cố định tồn tại trước khi người đó đăng ký; User ID có thể rỗng. Bill, phần chia và công nợ tham chiếu Membership ID. Khách có link riêng được xem dữ liệu của nhóm như thành viên có tài khoản theo FR18 và BR17.
- **FR02:** Một tài khoản được tham gia nhiều nhóm. Danh sách “Nhóm của bạn” hiển thị tên, số thành viên, trạng thái tham gia, tổng nợ và tổng cần thu của chính người dùng trong từng nhóm. Chạm nhóm để đổi ngữ cảnh; tên nhóm đang xem luôn hiển thị ở đầu màn hình.
- Mỗi nhóm có thành viên, vai trò, quỹ, bill, công nợ, kỳ chốt, phản hồi và quy ước riêng. Cùng một người có thể có vai trò khác nhau trong mỗi nhóm. Không tự bù trừ nợ hoặc dùng quỹ chéo nhóm.
- Link riêng gắn chính xác Group ID và Membership ID, cho xem không cần tài khoản. Link chung chỉ tạo yêu cầu chờ; trưởng nhóm duyệt gắn vào hồ sơ chưa liên kết hoặc tạo người mới, không ghép theo tên. Tham gia nhóm mới không thay thế hoặc xóa tư cách thành viên nhóm cũ; yêu cầu tham gia lặp không tạo membership trùng.
- Đổi nhóm không mất dữ liệu đã ghi nhận; mọi truy cập và giao dịch phải kiểm tra membership của đúng nhóm trên server. Bản HTML minh họa 3 nhóm đã tham gia; chưa triển khai gia nhập nhóm thật.

**Dữ liệu đầu vào:** Thông tin đăng nhập, tên nhóm, danh sách thành viên, vai trò và lời mời.

**Luồng chính:** Link riêng → xem ngay → đăng ký sau và liên kết cùng hồ sơ; hoặc link chung → đăng nhập → gửi yêu cầu → trưởng nhóm duyệt vào hồ sơ cũ/người mới. Không yêu cầu ảnh đại diện hoặc người nhận phải biết mình đã có tên trong nhóm.

**Kết quả:** Link riêng cho xem nhóm không cần đăng ký; link chung chỉ mở dữ liệu sau phê duyệt. Đăng ký sau không tạo thành viên trùng hoặc làm mất công nợ.

**Ngoại lệ:** Ngăn truy cập trái quyền; giữ lịch sử khi có người rời nhóm; cách bàn giao thủ quỹ cần được chốt.

**Liên kết:** Quy tắc BR02, BR12. Nghiệm thu AT17, AT19. Câu hỏi Q05, Q07, Q08.

### 4.3 M02 Hóa đơn và khoản chi

**Mục tiêu:** Ghi nhận một lần ăn uống hoặc đi chơi cùng chứng từ và số tiền.

**Tình trạng phạm vi:** Thêm bill, tự đọc số tiền từ ảnh và tính phần chia ngay đã xác nhận. Phạm vi nhiều người trả cho một bill chưa chốt.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR03 | Thêm hóa đơn | Bắt buộc; chi tiết cần chốt |
| FR04 | Đọc ảnh bill và tính phần chia ngay | Bắt buộc; đã xác nhận |

**Hành vi bắt buộc:**
- **FR03:** Tên khoản chi, ngày, tổng tiền, người tham gia, nguồn tiền, ảnh, ghi chú; không mất dữ liệu khi lưu lỗi.
- **FR04:** Khi chọn ảnh hóa đơn hoặc biên lai chuyển khoản, tự đọc số tiền VND và tính phần chia theo nhóm/người đang chọn, không cần nhập lại số tiền khi tổng đã rõ. Ưu tiên dòng tổng/số tiền; không lấy số tài khoản, mã giao dịch, số dư, tiền khách đưa hay tiền thừa. Nếu nhiều tổng mâu thuẫn hoặc không rõ, để trống số tiền và cho chọn gợi ý/nhập tay. Cho sửa tiền và người tham gia; chỉ ghi sổ khi người dùng chốt, vẫn giữ quy tắc quỹ và phê duyệt. OCR không xác thực chuyển khoản ngân hàng.

**Dữ liệu đầu vào:** Tên khoản chi, ngày phát sinh, ảnh bill, tổng tiền, ghi chú và người tạo.

**Luồng chính:** Chọn ảnh trong nhóm → tự đọc tổng VND và hiện phần chia ngay → điều chỉnh người tham gia/nguồn tiền nếu cần → chốt khoản chi. Nếu tổng mơ hồ, chọn số tiền từ ảnh; nếu đọc lỗi, nhập tay. Mọi thay đổi số tiền hoặc người tham gia đều tính lại phần chia trước khi chốt.

**Kết quả:** Khoản chi có đủ dữ liệu để chia tiền; ảnh gắn đúng khoản và được các thành viên hợp lệ xem.

**Ngoại lệ:** Ảnh không đọc được thì cho nhập tay; không ghi sổ khi thiếu số tiền hoặc danh sách tham gia; giữ form nếu lưu lỗi.

**Liên kết:** Quy tắc BR01, BR02, BR10. Nghiệm thu AT14, AT20, AT45–49. Q09 đã chốt; Q10 còn mở.

### 4.4 M03 Người tham gia và chia tiền

**Mục tiêu:** Xác định ai chịu chi phí và khoản chi thuộc quỹ hay công nợ cá nhân.

**Tình trạng phạm vi:** Chọn người và điều kiện dùng quỹ đã xác nhận. Cách chia đều, chia riêng và xử lý số lẻ đang đề xuất.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR05 | Chia tiền | Bắt buộc; chi tiết cần chốt |

**Hành vi bắt buộc:**
- **FR05:** Tích người tham gia, xem từng phần và tổng trước khi chốt; áp dụng BR01–BR05.

**Dữ liệu đầu vào:** Tổng tiền, tập thành viên của sự kiện, người tham gia và nguồn tiền thực trả.

**Luồng chính:** Tích người tham gia → chọn cách ghi khoản chi (mặc định chia bill cá nhân) và người trả → xem phần tiền từng người → xác nhận phân bổ. Nếu đủ nhóm, cho thêm lựa chọn chi trực tiếp từ quỹ hoặc ứng trước cho quỹ; thay đổi số người không tự chuyển bill cá nhân sang quỹ.

**Kết quả:** Tổng phần chia bằng tổng bill. Chia bill cá nhân chuyển sang M05, dù đủ nhóm hay chỉ một phần. Chỉ lựa chọn chi/ứng cho quỹ mới chuyển sang M04.

**Ngoại lệ:** Không chọn người hoặc trùng ID thì chặn lưu; người vào nhóm sau không làm thay đổi bill cũ; khách và tiền lẻ theo quy tắc đã duyệt. Phân loại quỹ/cá nhân của bill đã lưu được giữ nguyên sau nâng cấp; sửa dữ liệu cũ phải đi qua quy trình điều chỉnh BR11, không tự chuyển đổi.

**Liên kết:** Quy tắc BR01–BR05. Nghiệm thu AT06, AT07, AT12, AT14, AT19, AT51–AT54. Câu hỏi Q03, Q07, Q10.

### 4.5 M04 Quỹ chung

**Mục tiêu:** Theo dõi tiền nộp quỹ, tiền chi, khoản ứng trước và tiền cần hoàn.

**Tình trạng phạm vi:** Nộp quỹ, điều kiện đủ nhóm để chọn dùng quỹ và cách tách chia bill cá nhân khỏi quỹ đã xác nhận. Cách duyệt độc lập và đợt đóng cần chốt chi tiết.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR06 | Quỹ chung | Bắt buộc; chi tiết cần chốt |

**Hành vi bắt buộc:**
- **FR06:** Xem tiền thực có, khoản chờ hoàn, tiền khả dụng và lịch sử; nộp và hoàn một phần.

**Dữ liệu đầu vào:** Người nộp, số tiền, khoản chi đủ nhóm, nguồn trả và yêu cầu hoàn ứng.

**Luồng chính:** Nộp quỹ → chờ xác nhận M06 → tăng tiền thực có. Bill đủ nhóm được chọn “Chi trực tiếp từ quỹ” → ghi chi quỹ; chọn “Ứng trước cho quỹ” → ghi cần hoàn. Hoàn ứng → người nhận xác nhận → giảm tiền quỹ và khoản cần hoàn. Cá nhân trả trước ở chế độ chia bill cá nhân không đi qua sổ quỹ.

**Kết quả:** Hiển thị riêng tiền thực có, tổng cần hoàn và tiền khả dụng; theo dõi tổng đóng theo người.

**Ngoại lệ:** Chi trực tiếp và hoàn ứng cần đủ tiền theo BR06; không cộng tiền chờ xác nhận; không trừ hai lần khi một thành viên ứng trước.

**Liên kết:** Quy tắc BR04–BR06, BR09, BR10. Nghiệm thu AT05, AT06, AT08, AT09, AT10, AT15, AT18. Câu hỏi Q02, Q04, Q05, Q06, Q08.

### 4.6 M05 Công nợ và bù trừ

**Mục tiêu:** Cộng dồn số dư cá nhân qua nhiều sự kiện và đề xuất chuyển tiền trong toàn nhóm.

**Tình trạng phạm vi:** Cộng dồn và bù trừ cả nhóm đã xác nhận. Cách đồng ý đổi người nhận và cách tất toán cần chốt.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR07 | Công nợ | Bắt buộc; chi tiết cần chốt |

**Hành vi bắt buộc:**
- **FR07:** Bắt buộc hiển thị hai danh sách “Bạn đang nợ ai” và “Ai đang nợ bạn”; mỗi dòng có tên và số tiền còn lại. Hiển thị riêng “Tổng nợ” và “Tổng cần thu”, bằng tổng từng danh sách; một người có thể vừa nợ vừa cần thu.
- **Công nợ với từng người trên mọi nhóm:** Có hai chế độ rõ ràng “Theo nhóm” và “Với từng người”. Chế độ cá nhân tổng hợp tất cả nhóm mà người dùng đã tham gia; mỗi người đối ứng hiển thị số nhóm chung, tổng bạn nợ họ và tổng họ nợ bạn. Đối chiếu bằng User ID ổn định, không ghép theo tên hoặc số thứ tự trong nhóm.
- Mở một người để xem hai tổng, chênh lệch và từng nhóm đóng góp vào số tiền. Ví dụ: Huy nợ bạn 50.000đ ở nhóm A và 80.000đ ở nhóm C; bạn nợ Huy 120.000đ ở nhóm B. Tổng bạn nợ 120.000đ, tổng Huy nợ bạn 130.000đ; chênh lệch Huy nợ bạn 10.000đ. Mỗi dòng dẫn về nhóm tương ứng.
- Tổng hợp xuyên nhóm là góc nhìn báo cáo, không tự ghi thanh toán hoặc trừ quỹ. Chỉ lấy công nợ cá nhân và thanh toán đã xác nhận; không tính khoản chờ hay tiền quỹ cần hoàn. Tất toán chung nhiều nhóm cần quy tắc phân bổ riêng được duyệt trước; bản mẫu vẫn ghi thanh toán theo nhóm.
- Các danh sách cộng dồn và đối trừ hai chiều giữa cùng một cặp người sau thanh toán đã xác nhận. Không gộp nợ của các đối tác khác nhau thành một số duy nhất. Quỹ theo dõi riêng.
- Số dư ròng = Tổng cần thu − Tổng nợ; đề xuất bù trừ toàn nhóm nằm riêng, có nhãn rõ và không thay thế danh sách hoặc hai tổng. Đề xuất chưa xác nhận không làm giảm nợ.
- Không có khoản phải hiển thị 0đ và trạng thái “Bạn không nợ ai” hoặc “Không ai đang nợ bạn”; không để trống gây hiểu nhầm.

**Dữ liệu đầu vào:** Phần chia cá nhân từ M03 và các khoản trả nợ đã được M06 xác nhận.

**Luồng chính:** Xem số dư → mở các khoản tạo ra số dư → xem đề xuất bù trừ → chọn trả một phần hoặc toàn bộ qua M06.

**Kết quả:** Mỗi người biết cần trả hoặc được nhận bao nhiêu; đề xuất chỉ thay đổi cách tất toán, giữ nguyên bill gốc.

**Ngoại lệ:** Không trộn nợ quỹ với nợ cá nhân; không coi đề xuất là đã thanh toán; kiểm tra số dư mới khi xác nhận.

**Liên kết:** Quy tắc BR03, BR07, BR08. Nghiệm thu AT01–AT04, AT07, AT11, AT16, AT33–AT34. Câu hỏi Q11.

### 4.7 M06 Thanh toán và xác thực

**Mục tiêu:** Ghi nhận tiền thực nhận, quản lý chứng từ và phân biệt xác nhận thủ công với đối soát ngân hàng.

**Tình trạng phạm vi:** Nhu cầu xác thực bill ngân hàng đã xác nhận. Chọn xác nhận thủ công hay đối soát tự động vẫn đang mở.

| Mã yêu cầu | Chức năng | Trạng thái |
| --- | --- | --- |
| FR08 | Chứng từ thanh toán | Bắt buộc; chi tiết cần chốt |
| FR09 | Duyệt và từ chối | Bắt buộc; chi tiết cần chốt |
| FR13 | Đối soát ngân hàng | Bắt buộc; chi tiết cần chốt |

**Hành vi bắt buộc:**
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
| FR10 | Lịch sử minh bạch | Bắt buộc; chi tiết cần chốt |
| FR11 | Điều chỉnh | Bắt buộc; chi tiết cần chốt |
| FR12 | Đồng bộ | Bắt buộc; chi tiết cần chốt |

**Hành vi bắt buộc:**
- **FR10:** Cả nhóm xem được người tạo, thời gian, người xác nhận, người tham gia, ảnh và trạng thái.
- **FR11:** Bản ghi đảo có lý do; giữ bản gốc; áp dụng BR11.
- **FR12:** Thành viên khác nhận thay đổi khi làm mới; không ghi đè giao dịch mới từ thiết bị khác.

**Dữ liệu đầu vào:** Khoản chi, đóng quỹ, thanh toán, kết quả duyệt và yêu cầu sửa sai.

**Luồng chính:** Mở tổng quan → xem lịch sử → mở chi tiết và chứng từ → yêu cầu điều chỉnh có lý do → giữ cả bản gốc và bản điều chỉnh.

**Kết quả:** Lịch sử có người tạo, người duyệt, thời gian, người tham gia và trạng thái; thiết bị khác thấy dữ liệu sau làm mới.

**Ngoại lệ:** Không xóa dấu vết khoản đã ghi sổ; không ghi đè thay đổi của người khác; lưu lỗi không được báo thành công.

**Liên kết:** Quy tắc BR10–BR12. Nghiệm thu AT13, AT17–AT20. Câu hỏi Q05.

### 4.9 M08 Chốt kỳ và nhắc thanh toán

**FR14 Chốt tiền theo kỳ — Bắt buộc.** Quản trị xem bản nháp tổng kết tuần hoặc tháng; từng người xem số dư đầu kỳ, phát sinh, thanh toán đã xác nhận và số dư cuối kỳ. Quỹ được tổng hợp riêng thành tiền thực có, khoản cần hoàn và khả dụng. Hiển thị kỳ theo khoảng thời gian và múi giờ của nhóm, không dùng bộ lọc giao diện thay cho kỳ kế toán.

**Luồng chính:** Chọn kỳ → xem danh sách bill và khoản đang chờ → xử lý phản hồi → xem giải thích và đề xuất thanh toán → xác nhận chốt → lưu bản chốt bất biến → mở kỳ kế tiếp với số dư còn lại. Chốt kỳ không chuyển tiền, không xóa nợ và không tạo thêm khoản chi. Thành viên có thể trả một phần sau khi chốt; số dư trực tiếp cập nhật, bản chốt lịch sử giữ nguyên.

**Đề xuất xử lý ngoại lệ:** Chặn chốt khi có phản hồi mở hoặc yêu cầu tiền chưa xác nhận. Hiển thị từng khoản đang chặn và đường dẫn xử lý, không tự từ chối hoặc tự duyệt thay thành viên. Bill nhập muộn hoặc sửa sau khi chốt được ghi nhận bằng điều chỉnh liên kết ở kỳ đang mở, không âm thầm sửa kỳ cũ. Quy tắc cuối cùng cần xác nhận ở Q12.

**FR19 Nhắc thanh toán — Bắt buộc.** Thành viên nhận bản tổng kết và lời nhắc theo thiết lập đã đồng ý; được tắt nhắc hoặc chọn kênh. Trước khi gửi, tính lại số dư và trạng thái thanh toán: không nhắc khoản đã trả, không thúc giục khoản đang chờ người nhận xác nhận. Nhắc lại cùng sự kiện không tạo thông báo trùng. Kênh, tần suất và người nhận được chốt tại Q15. Prototype chỉ có hộp thư trong phiên và bản xem trước; không gửi thông báo thật.

**Liên kết:** FR07, FR09–FR12, FR15–FR17; BR13, BR14, BR18; AT21–AT24, AT31–AT32.

### 4.10 M05 Giải thích công nợ

**FR15 Giải thích đến giao dịch gốc — Bắt buộc.** Mỗi số dư có đường dẫn tới bảng kê: số dư đầu kỳ + tiền đã ứng − phần phải chịu + tiền đã trả − tiền đã nhận = số dư cuối kỳ. Số dương là được nhận; số âm là cần trả. Chỉ các thanh toán đã xác nhận được cộng vào công thức; tiền quỹ không trộn vào nợ cá nhân.

Mở từng dòng để xem bill, người tham gia và phần chia. Nếu bù trừ đổi người nhận, trình bày nghĩa vụ gốc và đề xuất sau bù trừ, giải thích rằng tổng số dư của từng thành viên không thay đổi. Tắt bù trừ liên người vẫn phải cộng dồn và bù trừ hai chiều với cùng một người; lúc này có thể vừa cần trả người này vừa được nhận người khác dù số dư ròng bằng 0. Tổng cần trả và được nhận phải phản ánh danh sách chuyển tiền thực tế, không chỉ lấy phần âm/dương của số dư ròng.

**Liên kết:** FR07, FR14, FR16; BR07, BR15; AT25–AT26.

### 4.11 M09 Quy ước nhóm

**FR16 Quy ước có phiên bản — Bắt buộc.** Cả nhóm đọc được quy ước về dùng quỹ, cách chia, người duyệt, chu kỳ chốt và chế độ bù trừ. Điều kiện “đủ thành viên mới dùng quỹ” là yêu cầu nền tảng đã xác nhận; không cho vô hiệu hóa bằng một tùy chọn. Các chính sách tùy biến khác phải nằm trong tập quy tắc được sản phẩm hỗ trợ.

**Luồng đề xuất:** Quản trị soạn thay đổi → thành viên xem khác biệt và xác nhận → đủ điều kiện phê duyệt → tạo phiên bản mới và ngày hiệu lực. Prototype mô phỏng sự đồng ý của 8/8 người; đây là ngưỡng đang đề xuất, không phải quyết định sản phẩm cuối cùng. Quy ước mới áp dụng từ kỳ sau; bản chốt và hóa đơn cũ giữ quy ước đã sử dụng. Lưu người đề xuất, người duyệt và thời gian, không thay đổi tiền chỉ vì sửa cài đặt.

**Ngoại lệ:** Chưa đủ phiếu thì chưa có hiệu lực; hủy đề xuất không sửa quy ước hiện tại. Người vào/rời nhóm trong lúc biểu quyết cần kiểm tra tập người có quyền duyệt. Cách chia nâng cao, quỹ thiếu và người duyệt độc lập tham chiếu Q02–Q05; không xem các trường hợp chưa chốt là đã hỗ trợ.

**Liên kết:** BR02, BR04, BR07, BR16; AT27; Q13.

### 4.12 M10 Phản hồi khoản chia sai

**FR17 Phản hồi và xử lý sai lệch — Bắt buộc.** Thành viên hoặc khách có link đúng phạm vi được gửi phản hồi gắn với bill và phiên bản của bill; bắt buộc lý do. Trạng thái gồm Mở, Đã xử lý. Người tạo bill/quản trị có quyền xử lý theo chính sách, nhưng không được xóa nội dung phản hồi gốc.

**Luồng chính:** Xem bill → nêu khoản sai và đề xuất sửa → gửi → người phụ trách kiểm tra → sửa bằng bản điều chỉnh có lịch sử hoặc giữ nguyên với giải thích → thông báo kết quả. Gửi phản hồi tự nó không thay đổi quỹ hay công nợ. Phản hồi chưa xử lý ngăn chốt kỳ theo đề xuất BR14. Với kỳ đã chốt, giữ bản chốt và xử lý bằng giao dịch điều chỉnh ở kỳ sau.

Bản mẫu hỗ trợ gửi phản hồi và mô phỏng xử lý giữ nguyên bill kèm giải thích. Nhánh điều chỉnh tiền có kiểm tra các giao dịch liên quan thuộc yêu cầu sản phẩm, chưa được mô phỏng đầy đủ.

**Liên kết:** FR03, FR10, FR11, FR14, FR18; BR11, BR14; AT23, AT28.

### 4.13 M01 Tham gia qua đường link

**FR18 Hai luồng lời mời — Bắt buộc, đã chốt.** Không yêu cầu ảnh đại diện hoặc đối chiếu tên để nhận diện thành viên.

**Luồng A — Link riêng:** Người có quyền mời chọn hồ sơ đã tồn tại → cấp link riêng gắn Group ID và Membership ID → người nhận mở trình duyệt, không cần cài app hoặc đăng ký → xem đầy đủ dữ liệu nhóm tương đương quyền xem của thành viên thường: thành viên, bill và chi tiết chia, công nợ, quỹ, lịch sử và chứng từ được chia sẻ trong nhóm. Quyền xem không tự cấp quyền sửa, xác nhận tiền hay quản trị. Không truy cập các nhóm khác hoặc dữ liệu riêng tư của tài khoản.

Người nhận đăng ký/đăng nhập sau bằng link riêng sẽ liên kết User ID vào đúng Membership ID. Giữ nguyên bill, thanh toán, kỳ và công nợ; không sao chép giao dịch. Khi liên kết thành công, thu hồi các link khách cũ của hồ sơ và dùng phiên tài khoản. Nếu hồ sơ đã liên kết tài khoản khác, hoặc tài khoản đã có hồ sơ khác trong nhóm, chặn và chuyển xử lý trùng; không tự gộp hay đổi chủ. Thao tác liên kết phải nguyên tử, chống hai người nhận đồng thời.

**Luồng B — Link chung:** Người nhận đăng nhập → gửi yêu cầu tham gia → chưa xem dữ liệu nhóm. Trưởng nhóm duyệt và chọn hồ sơ có sẵn chưa liên kết hoặc tạo thành viên mới; cũng có thể từ chối. Không buộc người nhận tìm tên mình. Yêu cầu lặp của cùng tài khoản khi đang chờ trả lại cùng yêu cầu; duyệt lặp không thêm người hoặc cộng nợ. Người mới không được thêm vào bill cũ. Hai người trùng tên có Membership ID khác nhau.

**Quản lý link:** Có hạn dùng, thu hồi và cấp lại. Link riêng là quyền truy cập: người được chuyển tiếp link cũng có thể xem; hiển thị điều này cho người mời. Token ngẫu nhiên, không chứa tên/số tiền/chứng từ; server lưu băm và kiểm tra nhóm, hồ sơ, hiệu lực mỗi lần đọc kể cả ảnh. Thu hồi làm mất quyền của mọi phiên khách phát sinh từ link. Không ghi token vào log/phân tích. Lưu lịch sử cấp, thu hồi, liên kết và duyệt.

**Bản mẫu:** Hai luồng và tài khoản được mô phỏng trong cùng tab; hạn 7 ngày là giá trị demo. Chưa có xác thực, token server, mời thật hoặc đồng bộ nhiều máy. Không dùng link mẫu cho dữ liệu thật.

**Liên kết:** FR01, FR02, FR17; BR17; AT29–AT30, AT39–AT44.

## 5 Quy tắc nghiệp vụ dùng chung

Các mã BR được giữ từ phiên bản 0.1. Phân hệ chỉ tham chiếu quy tắc; khi thay đổi một BR cần rà soát mọi phân hệ liên quan. Những lựa chọn chưa được duyệt vẫn là đề xuất.

### BR01 Tiền và chia đều

Lưu tiền bằng số nguyên VND dương, không dùng số thực. Tổng phần chia phải bằng tổng hóa đơn. Với 100.000đ chia 3, phân bổ 33.334đ, 33.333đ, 33.333đ theo thứ tự thành viên được lưu trong nhóm. Hiển thị phần chênh 1đ trước khi lưu. Giới hạn đề xuất mỗi giao dịch là 1.000.000.000đ; server phải kiểm tra lại giới hạn.

### BR02 Xác định đủ nhóm

So sánh tập ID người tham gia với tập ID thành viên đang hoạt động tại thời điểm sự kiện, không chỉ so sánh số lượng. Lưu ảnh chụp danh sách thành viên tại thời điểm chốt. Việc có người vào hoặc rời nhóm sau này không được thay đổi hóa đơn cũ. Khi nhập lùi ngày cần chọn danh sách thành viên có hiệu lực ở ngày đó.

### BR03 Chi cá nhân

Chế độ “Chia bill cá nhân” là mặc định khi một người trả trước, áp dụng cả khi đủ nhóm và quỹ bằng 0. Nếu thiếu ít nhất một thành viên, chỉ dùng chế độ này. Người trả trước được cộng toàn bộ tiền đã trả; mỗi người tham gia bị trừ phần của mình. Nếu người trả cũng tham gia, phần của họ tự được khấu trừ. Có thể trả hộ dù không tham gia. Bản đầu hỗ trợ một người trả cho mỗi hóa đơn; nhiều người cùng trả một hóa đơn là mở rộng sau.

### BR04 Chi từ quỹ

Chỉ khi đủ nhóm và người nhập chủ động chọn “Chi trực tiếp từ quỹ”, khoản chi mới thuộc quỹ. Đủ người tham gia không tự chọn chế độ này. Khi tiền thực sự được lấy từ quỹ, giảm tiền quỹ thực có. Không tạo thêm nợ cá nhân. Chỉ thủ quỹ xác nhận tiền đã ra khỏi quỹ; các thành viên khác có thể gửi yêu cầu chờ xác nhận.

### BR05 Ứng trước cho quỹ

Chỉ khi đủ nhóm và người nhập chủ động chọn “Ứng trước cho quỹ”, tiền cá nhân thanh toán mới tăng quỹ cần hoàn cho người đó; chưa giảm tiền quỹ thực có và không tạo công nợ cá nhân. Nếu chọn “Chia bill cá nhân”, ghi nợ giữa người tham gia và người trả theo BR03, không tăng quỹ cần hoàn. Khi người nhận xác nhận quỹ hoàn tiền, giảm cả quỹ thực có và quỹ cần hoàn. Cho phép hoàn một phần. Số tiền hoàn không vượt khoản quỹ đang nợ người đó hoặc tiền thực có.

### BR06 Quỹ không đủ

Quỹ bằng 0 hoặc thiếu tiền không chặn chia bill cá nhân: người trả trước vẫn được ghi nhận công nợ với những người tham gia theo BR03, kể cả đủ nhóm. Chi trực tiếp từ quỹ không được vượt quỹ khả dụng và không tự chuyển chế độ khi thiếu tiền. Nếu người nhập đã chọn rõ “Ứng trước cho quỹ” theo BR05, vẫn ghi nhận khoản quỹ cần hoàn dù quỹ chưa đủ tiền; không trừ tiền quỹ thực có và không tạo công nợ cá nhân. Quỹ khả dụng có thể âm để thể hiện phần thiếu cần nộp thêm, còn tiền thực có không được âm. Hoàn ứng không vượt tiền thực có hoặc khoản còn phải hoàn; cho hoàn từng phần và kiểm tra lại tại lúc xác nhận. Giữ thông tin nhập nếu chi trực tiếp hoặc hoàn ứng bị từ chối.

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

### BR13 Bất biến khi chốt kỳ

Bản chốt lưu khoảng thời gian, múi giờ, phiên bản quy ước, tập thành viên, danh sách giao dịch và số dư tại thời điểm chốt. Số dư cuối kỳ bằng số dư đầu kỳ cộng phát sinh và thanh toán đã xác nhận, được chuyển một lần sang kỳ mới. Không ghi thêm khoản nợ chỉ để chuyển kỳ. Số liệu lịch sử không đổi khi có thanh toán ở kỳ sau.

### BR14 Phản hồi và trạng thái chờ

Phản hồi mở hoặc thanh toán/nộp quỹ chờ xác nhận phải được hiển thị khi chốt. Đề xuất chặn chốt cho đến khi xử lý; bản mẫu áp dụng quy tắc này. Chỉ lưu phản hồi không đảo giao dịch. Giải quyết giữ nguyên cần lý do; giải quyết bằng sửa tiền tuân thủ BR11. Người dùng được thấy phản hồi gốc, kết quả và người xử lý.

### BR15 Hai chế độ đề xuất thanh toán

Bù trừ toàn nhóm ghép người âm số dư với người dương số dư. Giữ người nhận gốc cộng nghĩa vụ theo từng cặp và khấu trừ các khoản đã trả giữa cặp đó. Hai cách phải giữ cùng số dư ròng mỗi người và tổng nhóm bằng 0. Chỉ đề xuất có thể thay đổi; các thanh toán đã ghi nhận giữ nguyên người gửi/nhận thực tế. Kiểm tra lại đề xuất hiện tại trước khi xác nhận để tránh trả vượt nghĩa vụ.

### BR16 Hiệu lực quy ước

Quy ước có phiên bản và lịch sử duyệt. Thay đổi chưa được chấp thuận không áp dụng; thay đổi đã được chấp thuận có hiệu lực từ kỳ kế tiếp theo đề xuất hiện tại. Không hồi tố hóa đơn hoặc bản chốt. Không cho tùy chỉnh bỏ điều kiện đủ thành viên mới dùng quỹ. Ngưỡng duyệt và xử lý thay đổi thành viên cần chốt ở Q13.

### BR17 Phạm vi đường link

Link riêng cấp quyền xem của thành viên thường trong đúng nhóm, không cần tài khoản; link chung không cấp quyền đọc trước khi trưởng nhóm duyệt. Không nhận diện theo tên hoặc ảnh. Mọi bill và công nợ gắn Membership ID bất biến; User ID chỉ là liên kết tài khoản. Chỉ tổng hợp xuyên nhóm theo User ID đã liên kết; các hồ sơ chưa có tài khoản vẫn tách riêng dù trùng tên. Kiểm tra quyền trên server ở mọi lần truy cập, kể cả ảnh; không coi kiểm tra frontend là phân quyền thật. Nhận hồ sơ và duyệt yêu cầu không ghi nhận thanh toán hoặc thay đổi phần chia cũ.

### BR18 Thông báo theo số dư mới nhất

Chỉ nhắc người đã đồng ý nhận thông báo và còn nghĩa vụ phù hợp tại lúc gửi. Gộp theo kỳ, giới hạn lặp; dừng nhắc sau khi thanh toán xác nhận. Khoản chờ xác nhận hiển thị chờ người nhận xử lý. Tắt thông báo không làm mất nghĩa vụ hoặc che lịch sử. Thông báo trên màn hình khóa không chứa chứng từ hay số tài khoản đầy đủ.

## 6 Dữ liệu và yêu cầu chất lượng

### 6.1 Dữ liệu tối thiểu

| Đối tượng | Trường chính |
| --- | --- |
| User | ID, tên hiển thị, danh tính đăng nhập |
| Group | ID, tên, tiền tệ VND, người tạo, thủ quỹ, phiên bản dữ liệu |
| Membership | ID bất biến, Group ID, tên hiển thị, User ID có thể rỗng, vai trò, thời điểm vào/rời, lịch sử liên kết; duy nhất Group ID + User ID khi đã liên kết |
| Expense | ID, nhóm, tên, thời điểm, số tiền nguyên, cách ghi khoản chi (cá nhân/chi quỹ/ứng cho quỹ), người trả hoặc quỹ, tập thành viên của sự kiện, người tham gia, các phần chia, người tạo |
| Payment request | ID, loại, người gửi, người nhận, số tiền, trạng thái, người và thời gian xác nhận hoặc lý do từ chối |
| Evidence | ID, bản ghi liên quan, vị trí tệp riêng tư, loại tệp, kích thước, người tải lên |
| Ledger entry | ID, nguồn phát sinh, các khoản tăng giảm, người tạo, thời gian, liên kết bản ghi đảo |
| Period snapshot | ID kỳ, thời gian, múi giờ, số dư đầu/cuối, quỹ, ID giao dịch, phiên bản quy ước, người chốt |
| Group policy | Phiên bản, nội dung, người đề xuất, phiếu duyệt, trạng thái, kỳ hiệu lực |
| Bill feedback | ID bill và phiên bản, người gửi, lý do, trạng thái, người xử lý, giải thích, liên kết điều chỉnh |
| Scoped invitation | Token băm, loại riêng/chung, Group ID, Membership ID nếu link riêng, người cấp, hạn dùng, thời điểm thu hồi |
| Join request | ID, Group ID, User ID, trạng thái chờ/duyệt/từ chối, người duyệt, Membership ID kết quả; chống yêu cầu lặp |
| Notification | Người nhận, kỳ, loại, trạng thái, mã chống trùng, tùy chọn thông báo |

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
| AT08 | Đủ nhóm, chọn “Ứng trước cho quỹ”, Bình ứng 800.000đ, quỹ thực có 4.000.000đ | Quỹ thực có 4.000.000đ; cần hoàn 800.000đ; khả dụng 3.200.000đ |
| AT09 | Quỹ hoàn Bình 300.000đ, Bình xác nhận | Quỹ thực có 3.700.000đ; cần hoàn 500.000đ; khả dụng vẫn 3.200.000đ |
| AT10 | Gửi ảnh nộp 500.000đ nhưng chưa duyệt hoặc bị từ chối | Quỹ không tăng |
| AT11 | Gửi trả nợ 150.000đ khi đang nợ 200.000đ | Chưa xác nhận vẫn nợ 200.000đ; xác nhận còn 50.000đ |
| AT12 | 100.000đ chia 3 | 33.334đ + 33.333đ + 33.333đ, không mất 1đ |
| AT13 | Nhấn xác nhận hai lần cùng yêu cầu | Lần sau không hạch toán thêm |
| AT14 | Không chọn ai, số tiền ≤0, ID lạ hoặc người trùng | Từ chối lưu, không đổi dữ liệu |
| AT15 | Quỹ khả dụng 100.000đ, chi trực tiếp từ quỹ 200.000đ | Báo thiếu 100.000đ, không âm quỹ, không tự chuyển sang nợ cá nhân |
| AT16 | Khoản trả nợ chờ duyệt đã vượt số dư hiện tại | Chặn xác nhận; không sinh thanh toán vượt nghĩa vụ |
| AT17 | Người không có quyền truy cập dữ liệu hoặc ảnh ngoài phạm vi được cấp | Bị từ chối tại server, kể cả khách có link riêng của nhóm khác |
| AT18 | Hai thiết bị đồng thời xác nhận chi quỹ | Không chi vượt quỹ và không mất giao dịch |
| AT19 | Thêm thành viên sau một hóa đơn đã chốt | Phân bổ và loại chi của hóa đơn cũ giữ nguyên |
| AT20 | Đóng và mở lại ứng dụng | Khôi phục chính xác nhóm, chứng từ, giao dịch và số dư |
| AT21 | Chốt kỳ còn nợ 200.000đ | Kỳ sau bắt đầu nợ 200.000đ, không thành 400.000đ |
| AT22 | Trả 100.000đ ở kỳ sau, được xác nhận | Số dư hiện tại còn nợ 100.000đ; bản chốt kỳ trước vẫn nợ 200.000đ |
| AT23 | Có phản hồi bill mở | Chặn chốt; chỉ rõ bill và đường dẫn xử lý; không tự đổi số dư |
| AT24 | Có yêu cầu nộp quỹ hoặc trả nợ chờ | Không chốt theo chính sách đề xuất; không tự duyệt thay người nhận |
| AT25 | Mở giải thích số dư | Tổng các dòng bằng đúng số dư; từng dòng dẫn về chứng từ gốc |
| AT26 | Bạn nợ Bình 200.000đ; An nợ Bạn 150.000đ | Bật bù trừ: Bạn trả Bình 50.000đ, An trả Bình 150.000đ; tắt: giữ hai cặp gốc; số dư ròng không đổi |
| AT27 | Đề xuất quy ước mới, chưa đủ duyệt rồi đủ duyệt | Chưa đủ: chưa áp dụng; đủ: chờ kỳ kế; bill và kỳ cũ không đổi |
| AT28 | Gửi phản hồi rồi xử lý giữ nguyên với lý do | Lưu cả nội dung gốc và trả lời; không tạo thanh toán hoặc thay đổi số dư |
| AT29 | Khách mở link riêng hợp lệ, chưa có tài khoản | Xem nhóm, bill, công nợ, quỹ và lịch sử như thành viên thường; không tự cấp quyền sửa hoặc truy cập nhóm khác |
| AT30 | Link hết hạn, thu hồi hoặc sai phạm vi | Từ chối xem và thao tác; không ghi dữ liệu |
| AT31 | Khoản đã thanh toán hoặc đang chờ nhận xác nhận | Không nhắc chuyển lần nữa; hiển thị trạng thái phù hợp |
| AT32 | Tắt nhắc tiền rồi tạo bản nhắc; gửi lặp cùng sự kiện | Không tạo thông báo khi tắt; không gửi trùng khi bật |
| AT33 | Bạn nợ Bình 200.000đ; An nợ Bạn 150.000đ | Hai danh sách ghi đúng Bình/An; Tổng nợ 200.000đ, Tổng cần thu 150.000đ, số dư ròng −50.000đ, kể cả khi bật bù trừ toàn nhóm |
| AT34 | Trả Bình 50.000đ rồi xác nhận; sau đó thanh toán hết | Khi chờ: tổng không đổi; xác nhận: nợ Bình và Tổng nợ còn 150.000đ, Tổng cần thu vẫn 150.000đ; hết khoản thì hiển thị 0đ và trạng thái rỗng phù hợp |
| AT35 | Một tài khoản tham gia 3 nhóm; đổi nhóm rồi quay lại | Hiển thị đúng tên, số thành viên và hai tổng từng nhóm; dữ liệu đã ghi nhận ở nhóm trước được giữ nguyên |
| AT36 | Cùng người có mặt ở hai nhóm; thay đổi bill/quỹ hoặc tham gia lặp | Không cộng hoặc bù trừ chéo nhóm; quyền theo membership của nhóm đích; không tạo membership trùng |
| AT37 | Bạn và Huy chung 3 nhóm với nghĩa vụ hai chiều | Hiện riêng 120.000đ bạn nợ, 130.000đ Huy nợ bạn; chênh lệch 10.000đ và nguồn từ 3 nhóm; không thay đổi sổ nhóm |
| AT38 | Hai người trùng tên hoặc một người có số thứ tự khác nhau giữa nhóm | Ghép bằng User ID; không gộp người trùng tên; khoản chờ không giảm tổng, khoản xác nhận chỉ giảm nghĩa vụ được thanh toán |
| AT39 | Hai hồ sơ cùng tên Huy; nhận link của hồ sơ thứ hai | Chỉ mở và liên kết hồ sơ thứ hai; không ghép tên, không yêu cầu ảnh |
| AT40 | Đăng ký sau khi có nhiều bill và nợ | Giữ Membership ID, số thành viên, lịch sử và các tổng tiền; thu hồi link khách cũ |
| AT41 | Vào link chung, gửi lặp và chưa được duyệt | Một yêu cầu chờ; chưa thêm thành viên, chưa đọc dữ liệu nhóm |
| AT42 | Trưởng nhóm duyệt vào hồ sơ cũ hoặc tạo mới; thử duyệt lặp | Liên kết đúng hồ sơ hoặc thêm đúng một người; bill cũ không đổi; người không có quyền bị chặn |
| AT43 | Hồ sơ đã nhận, tài khoản đã thuộc nhóm, hai người nhận đồng thời | Không đổi chủ, không tạo membership trùng; thao tác nguyên tử; chuyển xử lý trùng |
| AT44 | Thu hồi/cấp lại link hoặc từ chối yêu cầu | Link cũ và phiên khách tương ứng mất quyền; yêu cầu từ chối không tạo thành viên |
| AT45 | Ảnh có tổng VND rõ ràng | Tự điền số tiền, hiện phần chia; chưa ghi sổ cho đến khi chốt |
| AT46 | Có số tài khoản, mã giao dịch, số dư, tiền khách đưa/thừa | Không chọn các con số này làm tổng chia; không lấy số lớn nhất mặc định |
| AT47 | Hai tổng khác nhau, số lẻ không hợp lệ hoặc ngoại tệ | Không tự chọn/quy đổi; yêu cầu chọn đúng tổng hoặc nhập VND |
| AT48 | Người dùng sửa tiền khi ảnh đang đọc hoặc rời màn hình | Kết quả đến muộn không ghi đè số đã sửa, không tạo khoản và không lỗi màn hình |
| AT49 | OCR lỗi, quá thời gian, ảnh thay/bỏ hoặc đổi người tham gia | Giữ ảnh khi đọc lỗi, cho nhập tay; không dùng số cũ của ảnh đã bỏ; tính lại phần chia khi đổi người |
| AT50 | Quỹ rỗng hoặc thiếu tiền, chọn rõ “Ứng trước cho quỹ”, một thành viên trả trước cho cả nhóm | Lưu bill, ghi quỹ cần hoàn người ứng; tiền thực có giữ nguyên, phần thiếu hiện rõ; chi trực tiếp/hoàn vượt tiền bị chặn kể cả khi xác nhận muộn |
| AT51 | Nhóm An, Bình, Chi; quỹ 0đ; đủ 3 người; An trả trước 300.000đ ở chế độ mặc định | Lưu bill; Bình và Chi mỗi người nợ An 100.000đ, An cần thu 200.000đ; quỹ thực có và quỹ cần hoàn đều 0đ |
| AT52 | Nhóm 2 người, quỹ 0đ; cả hai tham gia; một người trả 100.001đ ở chế độ cá nhân | Lưu bill, chia số nguyên bảo toàn 100.001đ; người trả tự chịu phần của mình, chỉ ghi công nợ phần của người còn lại; không ghi nợ quỹ |
| AT53 | Bình nợ An 100.000đ từ bill đủ nhóm; Bình gửi trả 40.000đ rồi An xác nhận | Khi chờ vẫn nợ 100.000đ; xác nhận còn nợ 60.000đ; nợ của Chi và số tiền quỹ không đổi |
| AT54 | Bill cá nhân đang chọn một phần nhóm rồi chọn đủ nhóm; đọc lại bill cũ thuộc quỹ sau nâng cấp | Bill mới vẫn ở chế độ cá nhân khi chọn đủ nhóm; bill cũ giữ nguyên phân loại quỹ, số dư và lịch sử, không tự chuyển thành nợ cá nhân |


## 8 Câu hỏi và quyết định còn mở

Bảng Q01–Q15 giữ cả câu hỏi mở và quyết định đã chốt. Q02 và Q09 đã được xác nhận ngày 12/11/2026; các chi tiết còn lại cần chốt. Chức năng liên quan vẫn bắt buộc nếu đã được xác nhận ở mục 2.1. Khi có câu trả lời, giữ mã Q và ghi quyết định, ngày xác nhận, yêu cầu FR cùng quy tắc BR bị ảnh hưởng. Không xóa câu hỏi đã giải quyết khỏi lịch sử.

| ID | Câu hỏi cần thống nhất | Quyết định đã xác nhận hoặc đề xuất còn mở |
| --- | --- | --- |
| Q01 | Xác thực bill ngân hàng nghĩa là người nhận xác nhận hay đối soát giao dịch tự động? | Người nhận hoặc thủ quỹ xác nhận trước; tích hợp ngân hàng là yêu cầu riêng |
| Q02 | Đủ người tham gia nhưng quỹ thiếu thì xử lý thế nào? | Xác nhận lại 12/11/2026: cá nhân trả trước mặc định chia công nợ, kể cả đủ nhóm và quỹ 0đ. Chỉ chọn rõ “Ứng trước cho quỹ” mới ghi quỹ cần hoàn; chi trực tiếp cần đủ quỹ khả dụng, hoàn ứng cần đủ tiền thực có. Không tự đổi chế độ theo số người hoặc số dư quỹ (BR03–BR06, AT50–54) |
| Q03 | Mọi khoản đều chia đều hay cần phần riêng, theo món hoặc trọng số? | Chia đều trong phạm vi đầu tiên |
| Q04 | Nộp quỹ theo đợt bằng nhau hay mỗi người tự chọn số tiền? | Ghi nhận số thực nộp, chưa áp dụng hạn mức theo đợt |
| Q05 | Ai được thêm, duyệt và sửa khoản chi? Thủ quỹ tự nộp thì ai duyệt? | Thành viên thêm; thủ quỹ duyệt tiền quỹ; người nhận duyệt trả nợ; cần quy tắc duyệt độc lập cho thủ quỹ |
| Q06 | Tiền quỹ nằm ở tài khoản của một thủ quỹ hay nhiều người giữ? | Một thủ quỹ, một quỹ VND mỗi nhóm |
| Q07 | Nếu có khách hoặc người vào nhóm sau, thế nào là đủ nhóm cho sự kiện đó? | Dùng danh sách thành viên có hiệu lực ở thời điểm sự kiện; khách cần quy tắc riêng |
| Q08 | Người rời nhóm được hoàn phần quỹ còn dư thế nào? | Chưa tự hoàn; phải thống nhất cách tính trước |
| Q09 | Đưa ảnh bill vào có bắt buộc tự đọc tổng tiền ngay bản đầu không? | Đã chốt 12/11/2026: tự đọc và tính phần chia ngay; tổng mơ hồ cho chọn, đọc lỗi cho nhập tay; chốt trước khi ghi sổ |
| Q10 | Có cho nhiều người cùng ứng tiền một bill không? | Một người trả mỗi bill trong phạm vi đầu tiên |
| Q11 | Cơ chế duyệt chế độ bù trừ và có cần duyệt từng đề xuất? | Bắt buộc cho nhóm chọn chế độ; ngưỡng duyệt cụ thể tham chiếu Q13 |
| Q12 | Chốt kỳ khi có khoản chờ, nhập lùi ngày, kỳ đầu và múi giờ? | Chặn khoản chờ; mặc định tuần tại Asia/Ho_Chi_Minh; không hồi tố kỳ đã chốt |
| Q13 | Quy ước nhóm cần bao nhiêu người đồng ý và hiệu lực khi nào? | 8/8 trong mẫu; sản phẩm dùng tập thành viên có quyền, áp dụng từ kỳ tiếp theo |
| Q14 | Hạn dùng mặc định và khôi phục hồ sơ nhận nhầm? | Hai luồng đã chốt; khách link riêng không bắt đăng ký/OTP. Demo 7 ngày; hạn thật và quy trình xử lý nhầm cần chốt |
| Q15 | Kênh, thời điểm và tần suất nhắc tiền? | Trong app và push khi đồng ý; gộp theo kỳ, không gửi nhắc liên tục |

Sau khi thống nhất các câu hỏi này, cập nhật quy tắc nghiệp vụ, quyền hạn và tiêu chí nghiệm thu thành FRS được duyệt. Giao diện HTML đã được yêu cầu và đang được cập nhật để duyệt trải nghiệm. FRS không xác nhận backend, ngân hàng hoặc cơ chế phân quyền thật đã được xây dựng.

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

FR14–FR19 đã chuyển vào phạm vi bắt buộc theo xác nhận của chủ sản phẩm. Các ví dụ khảo sát như khách đến muộn, được mời và chia phần quỹ khi rời nhóm chưa được duyệt chi tiết; tiếp tục ghi nhận dưới câu hỏi và không tự triển khai như quy tắc mặc định.

## 10 Đối chiếu đặc tả và bản mẫu HTML

Bản HTML theo FRS 0.6 minh họa một tài khoản trong 3 nhóm gồm 6, 8 và 10 người; tải lại đặt lại dữ liệu. Cài đặt, biểu quyết, lời mời và thông báo đều mô phỏng trên thiết bị đang xem. Không coi các nút mô phỏng là cơ chế xác thực hoặc bằng chứng đã chuyển tiền.

| Chức năng | Điểm truy cập trong giao diện | Mức thể hiện |
| --- | --- | --- |
| FR02 Nhiều nhóm | Tên nhóm ở đầu màn hình → Nhóm của bạn | 3 nhóm đã tham gia, chuyển nhóm và giữ dữ liệu riêng trong phiên |
| FR07 Công nợ từng người | Theo nhóm → Công nợ; hoặc Với từng người → chọn người | Hai tổng riêng, tổng hợp mọi nhóm theo User ID, chi tiết nhóm và chênh lệch |
| FR14 Chốt kỳ | Tổng quan hoặc Công nợ → Chốt tiền | Tổng kết, chặn khoản chờ/phản hồi, bản chốt lịch sử, chuyển số dư |
| FR15 Giải thích | Công nợ → Vì sao có số tiền này | Bảng kê bill/thanh toán, đối chiếu bù trừ và người nhận gốc |
| FR16 Quy ước | Nhóm → Quy ước | Đề xuất, mô phỏng đồng ý, áp dụng kỳ sau, quy tắc quỹ cố định |
| FR17 Phản hồi | Chi tiết bill → Báo khoản chia sai | Gửi, xem trạng thái, xử lý giữ nguyên có giải thích; chưa sửa tiền thật |
| FR18 Link | Cả nhóm → Link riêng / Link chung / Chờ duyệt | Xem nhóm không tài khoản, liên kết hồ sơ, gửi và duyệt/từ chối yêu cầu, hết hạn/thu hồi |
| FR19 Nhắc tiền | Tổng quan → Thông báo | Tùy chọn nhận nhắc, tạo bản xem trước, lọc khoản đã trả/đang chờ |

Các chức năng ngân hàng, OCR, định danh và đồng bộ nhiều thiết bị chưa được triển khai trong HTML. Đây là giới hạn của bản mẫu, không phải loại khỏi phạm vi sản phẩm đã xác nhận.

### 10.1 Luồng đọc ảnh trong Flutter 0.3

Chọn nhóm → Thêm khoản chi → Chọn ảnh bill. Android dùng mô hình ML Kit đóng gói trong APK; iOS dùng Apple Vision; Flutter web xử lý bằng Tesseract trong trình duyệt và cần mạng tải bộ đọc/mô hình lần đầu. Ảnh không gửi tới dịch vụ OCR. Bản HTML độc lập trong frontend vẫn là bản mẫu cũ.

Tự điền tổng VND rõ ràng và tính phần chia; không suy ra người tham gia hay người trả từ tên trên ảnh. Chia bill cá nhân là mặc định, kể cả đủ nhóm hoặc quỹ 0đ. Chỉ cho chọn chi/ứng cho quỹ khi đủ thành viên; OCR không tự chọn chế độ quỹ. Nhập/sửa/chọn tổng rồi chốt là hành động ghi sổ; ảnh trả nợ/nộp quỹ vẫn cần luồng xác nhận riêng. Không hỗ trợ tự phát hiện giao dịch ngân hàng, đọc chi tiết từng món hay xác minh ngân hàng.
