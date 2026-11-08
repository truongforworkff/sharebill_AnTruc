// shortcut: nhóm và tư cách thành viên là dữ liệu mẫu trong phiên; cần backend kiểm tra membership khi dùng thật.
let activeGroupId='friends';
function captureGroup(){return {names,bills,payments,deposits,refunded,pendingContributions,fundEvents,policy,proposal,period,closedPeriods,feedback,notifications,notificationEnabled,invitation,policyHistory,feedbackSequence};}
function sampleGroup(memberNames,amount,payer,title,cash){return {names:memberNames,bills:[{id:1,title,amount,payer,ids:[0,1,2],source:'personal',date:'Hôm nay',icon:'food'}],payments:[],deposits:cash,refunded:0,pendingContributions:[],fundEvents:[],policy:{version:1,frequency:'weekly',netting:true},proposal:null,period:{number:1,start:'2026-11-02',frequency:'weekly',opening:memberNames.map(()=>0),openingFund:{cash,owed:0,available:cash}},closedPeriods:[],feedback:[],notifications:[],notificationEnabled:true,invitation:{status:'active',attendance:false},policyHistory:[],feedbackSequence:0};}
const groups=[
 {id:'friends',name:groupName,kind:'Nhóm bạn',memberIds:['me','binh','an','chi','dung','ha','linh','huy'],state:captureGroup()},
 {id:'office',name:'Ăn trưa văn phòng',kind:'Đồng nghiệp',memberIds:['me','nam','mai','huy','lan','phuc'],state:sampleGroup(['Bạn','Nam','Mai','Huy','Lan','Phúc'],360000,1,'Cơm trưa thứ Sáu',1200000)},
 {id:'travel',name:'Hội mê Đà Lạt',kind:'Du lịch',memberIds:['me','binh','an','chi','dung','ha','linh','huy','vy','tuan'],state:sampleGroup(['Bạn','Bình','An','Chi','Dũng','Hà','Linh','Huy','Vy','Tuấn'],900000,0,'Bữa tối Đà Lạt',6000000)}
];
// Một Huy có cùng ID trong ba nhóm; số thứ tự và tên hiển thị không phải định danh tài khoản.
groups[0].state.bills.push({id:5,title:'Bạn ứng phần ăn cho Huy',amount:50000,ids:[7],payer:0,source:'personal',date:'Hôm nay',icon:'food'});
groups[1].state.bills.push({id:2,title:'Huy ứng tiền ăn cho bạn',amount:120000,ids:[0],payer:3,source:'personal',date:'Hôm nay',icon:'food'});
groups[2].state.bills.push({id:2,title:'Bạn ứng vé cho Huy',amount:80000,ids:[7],payer:0,source:'personal',date:'Hôm nay',icon:'trip'});
function allContacts(){groups.find(g=>g.id===activeGroupId).state=captureGroup();return Money.contactDebts(groups,'me');}
function contactTotals(owe,receive){return `<div class="summary"><div class="stat"><span class="label">Bạn nợ</span><strong class="orange">${fmt(owe)}</strong></div><div class="stat"><span class="label">Nợ bạn</span><strong>${fmt(receive)}</strong></div></div>`;}
function contactsPage(){
 const contacts=allContacts(),owed=contacts.reduce((s,c)=>s+c.owe,0),receive=contacts.reduce((s,c)=>s+c.receive,0);
 return `<div class="page-title"><p class="section-eyebrow">TẤT CẢ ${groups.length} NHÓM ĐÃ THAM GIA</p><h2>Công nợ với từng người</h2><p class="sub">Cùng một người, xem chung mọi khoản.</p></div>${contactTotals(owed,receive)}<p class="note">Hai tổng giữ riêng chiều trả và chiều thu. Chạm một người để xem các nhóm chung và số chênh lệch.</p><div class="contact-section-label"><strong>Người có công nợ</strong><span>${contacts.filter(c=>c.owe||c.receive).length} người</span></div>${contacts.filter(c=>c.owe||c.receive).map(c=>`<button class="contact-card" data-action="contact-detail" data-id="${c.id}"><span class="contact-heading"><span class="avatar">${esc(c.name[0])}</span><span><strong>${esc(c.name)}</strong><small>${c.groups.length} nhóm chung</small></span><span class="contact-arrow">→</span></span><span class="group-money"><span>Bạn nợ <b class="orange">${fmt(c.owe)}</b></span><span>${esc(c.name)} nợ bạn <b>${fmt(c.receive)}</b></span></span></button>`).join('')||'<div class="empty">Bạn không còn công nợ với ai.</div>'}<p class="footer-note">Chỉ tổng hợp công nợ cá nhân. Quỹ và tiền ứng cho quỹ xem tại từng nhóm.</p>`;
}
function contactDetail(id){
 const c=allContacts().find(c=>c.id===id);if(!c)return;
 const net=c.receive-c.owe;
 show(`<h2 class="sheet-title">Bạn & ${esc(c.name)}</h2><p class="sheet-sub">Công nợ trên ${c.groups.length} nhóm chung</p>${contactTotals(c.owe,c.receive)}<div class="net-contact"><small>Chênh lệch tổng hợp</small><strong>${net>0?c.name+' nợ bạn':net<0?'Bạn nợ '+c.name:'Hai chiều bằng nhau'}${net?' '+fmt(Math.abs(net)):''}</strong><p>Đây là số tham khảo sau đối trừ hai chiều, chưa phải giao dịch tất toán.</p></div><h3 class="section-heading">Chi tiết theo nhóm</h3>${c.groups.map(g=>`<button class="group-option" data-action="contact-group" data-id="${g.id}"><span class="group-option-top"><strong>${esc(g.name)}</strong><span>Mở nhóm →</span></span><span class="group-money"><span>Bạn nợ <b class="orange">${fmt(g.owe)}</b></span><span>${esc(c.name)} nợ bạn <b>${fmt(g.receive)}</b></span></span></button>`).join('')}<div class="note">Tổng hợp không sửa sổ của các nhóm. Thanh toán được ghi nhận trong nhóm tương ứng để tránh trừ tiền hai lần.</div>`);
}
function groupPicker(){
 groups.find(g=>g.id===activeGroupId).state=captureGroup();
 show(`<h2 class="sheet-title">Nhóm của bạn</h2><p class="sheet-sub">Một tài khoản · Đã tham gia ${groups.length} nhóm</p>${groups.map(g=>{const s=g.state,t=Money.personalDebts(s.bills,s.payments,s.names.length,0);return `<button class="group-option ${g.id===activeGroupId?'active':''}" data-action="switch-group" data-id="${g.id}" aria-pressed="${g.id===activeGroupId}"><span class="group-option-top"><strong>${esc(g.name)}</strong><span>${g.id===activeGroupId?'✓ Đang xem':'Mở →'}</span></span><small>${s.names.length} thành viên · ${g.kind} · Đã tham gia</small><span class="group-money"><span>Nợ <b class="orange">${fmt(t.owe)}</b></span><span>Cần thu <b>${fmt(t.receive)}</b></span></span></button>`;}).join('')}<div class="note">Bill, quỹ, công nợ và quy ước được giữ riêng cho từng nhóm. Không tự bù trừ tiền giữa các nhóm, kể cả khi có cùng thành viên.</div>`);
}
function switchGroup(id){
 const next=groups.find(g=>g.id===id);if(!next)return;
 groups.find(g=>g.id===activeGroupId).state=captureGroup();
 ({names,bills,payments,deposits,refunded,pendingContributions,fundEvents,policy,proposal,period,closedPeriods,feedback,notifications,notificationEnabled,invitation,policyHistory,feedbackSequence}=next.state);
 activeGroupId=id;groupName=next.name;all=names.map((_,i)=>i);draft=null;receiptUrl=null;debtTab='mine';
 $('.group-picker strong').textContent=groupName;
 $('.group-picker small').textContent=names.length+' thành viên · Đổi nhóm ('+groups.length+')';
 close();go('home');toast('Đang xem '+groupName);
}
Object.assign(actions,{contacts:()=>go('contacts'),'contact-detail':b=>contactDetail(b.dataset.id),'contact-group':b=>{switchGroup(b.dataset.id);go('debts');},groups:groupPicker,'switch-group':b=>switchGroup(b.dataset.id)});

render();
