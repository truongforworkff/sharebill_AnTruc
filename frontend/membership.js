// shortcut: in-memory prototype; production must enforce these checks and token revocation on the server.
const Membership = (() => {
 const fail = message => { throw Error(message); };
 function member(s,id){return s.members.find(m=>m.id===id)||fail('Không tìm thấy thành viên.');}
 function leader(s,actor){if(actor!==s.leaderId)fail('Chỉ trưởng nhóm được duyệt.');}
 function link(s,token,kind){const l=s.links.find(l=>l.token===token&&l.kind===kind);if(!l||l.revoked||l.expiresAt<=Date.now())fail('Link hết hạn hoặc đã thu hồi.');return l;}
 function issue(s,kind,memberId,token,actor){leader(s,actor);if(!['personal','general'].includes(kind)||!token||s.links.some(l=>l.token===token))fail('Link không hợp lệ.');if(kind==='personal')member(s,memberId);const l={kind,memberId:kind==='personal'?memberId:null,token,expiresAt:Date.now()+7*86400000,revoked:false};s.links.push(l);return l;}
 function read(s,token){return member(s,link(s,token,'personal').memberId);}
 function bind(s,id,accountId){if(!/^[a-zA-Z0-9_-]{1,80}$/.test(accountId||''))fail('Mã tài khoản mẫu chỉ gồm chữ, số, gạch ngang hoặc gạch dưới.');const m=member(s,id);if(m.accountId&&m.accountId!==accountId)fail('Hồ sơ đã liên kết tài khoản khác.');if(s.members.some(x=>x.id!==id&&x.accountId===accountId))fail('Tài khoản đã là thành viên; cần xử lý hồ sơ trùng, không tự gộp.');m.accountId=accountId;return m;}
 function claim(s,token,accountId){const l=link(s,token,'personal'),m=bind(s,l.memberId,accountId);s.links.filter(x=>x.kind==='personal'&&x.memberId===m.id).forEach(x=>x.revoked=true);s.audit.push({action:'claim',memberId:m.id,accountId});return m;}
 function request(s,token,accountId,name){link(s,token,'general');if(!/^[a-zA-Z0-9_-]{1,80}$/.test(accountId||'')||!name.trim()||name.trim().length>60||/[<>\x00-\x1f]/.test(name))fail('Tên hoặc mã tài khoản mẫu không hợp lệ.');if(s.members.some(m=>m.accountId===accountId))fail('Tài khoản đã là thành viên nhóm.');const old=s.requests.find(r=>r.accountId===accountId&&r.status==='pending');if(old)return old;const r={id:'request-'+(s.requests.length+1),accountId,name:name.trim(),status:'pending'};s.requests.push(r);return r;}
 function approve(s,id,targetId,actor){leader(s,actor);const r=s.requests.find(r=>r.id===id);if(!r||r.status!=='pending')fail('Yêu cầu đã được xử lý.');if(s.members.some(m=>m.accountId===r.accountId))fail('Tài khoản đã là thành viên nhóm.');let m;if(targetId){m=bind(s,targetId,r.accountId);}else{m={id:s.groupId+':member:'+s.members.length,name:r.name,accountId:r.accountId};s.members.push(m);}r.status='approved';r.memberId=m.id;s.audit.push({action:'approve',requestId:id,memberId:m.id,actor});return m;}
 function reject(s,id,actor){leader(s,actor);const r=s.requests.find(r=>r.id===id);if(!r||r.status!=='pending')fail('Yêu cầu đã được xử lý.');r.status='rejected';s.audit.push({action:'reject',requestId:id,actor});}
 function revoke(s,token,actor){leader(s,actor);const l=s.links.find(l=>l.token===token);if(!l)fail('Không tìm thấy link.');l.revoked=true;}
 return {member,issue,read,claim,request,approve,reject,revoke};
})();
if(typeof module!=='undefined')module.exports=Membership;
