# sharebill_AnTruc

**Chung** — bản thiết kế mobile cho ứng dụng chia bill, công nợ và quỹ nhóm.

## Tài liệu và giao diện

- [FRS hiện tại (Markdown)](docs/FRS.md)
- [FRS 0.4 (Word)](docs/Share_Bill_FRS_v0.4.docx)
- [Giao diện HTML độc lập](frontend/Chung-Mobile.html) — tải về và mở bằng trình duyệt.
- [Gói giao diện](Chung-Mobile-Prototype.zip)
- [Hướng dẫn dùng bản mẫu](frontend/HUONG-DAN.txt)

FRS 0.4 bổ sung hai luồng mời: link riêng gắn với hồ sơ thành viên cho xem nhóm không cần tài khoản; link chung cần trưởng nhóm duyệt vào hồ sơ cũ hoặc thêm thành viên mới. Đăng ký sau giữ nguyên hồ sơ và công nợ. Không ghép theo tên.

## Chạy giao diện

```bash
python3 -m http.server 4173 --bind 127.0.0.1 --directory frontend
```

Mở http://localhost:4173/. Tại Tổng quan → Cả nhóm, thử Link riêng cạnh Chi, Link chung và Chờ duyệt. Các nút “mô phỏng” cho phép thử vai trò người nhận/trưởng nhóm trong cùng tab.

## Kiểm tra logic

```bash
node frontend/tests/money.test.cjs
node frontend/tests/flows.test.cjs
node frontend/tests/groups.test.cjs
node frontend/tests/membership.test.cjs
```

## Giới hạn

Đây là prototype HTML/CSS/JavaScript với dữ liệu mẫu trong bộ nhớ. Reload đặt lại dữ liệu. Chưa có đăng nhập thật, backend phân quyền, đồng bộ, link mời liên thiết bị, OCR hoặc kết nối ngân hàng. Không dùng cho tiền hoặc thông tin cá nhân thật. Link riêng thực tế là quyền đọc và cần kiểm tra/thu hồi trên server; người được chuyển tiếp link có thể xem.

Sổ tiền mẫu dùng chỉ số thành viên cố định và chỉ thêm người cuối danh sách; khi triển khai backend phải dùng Membership ID bất biến. Quy tắc xác thực, đồng thời và phân quyền phía server trong FRS chưa được triển khai bằng frontend.

Motion dùng hướng dẫn Animate UI qua CSS. Xem [thông báo giấy phép](frontend/ANIMATE-UI-NOTICES.txt).
