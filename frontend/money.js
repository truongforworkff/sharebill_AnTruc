(function (root) {
  function split(amount, ids) {
    if (!Number.isSafeInteger(amount) || amount <= 0 || !ids.length || new Set(ids).size !== ids.length) throw Error('Nhập số tiền nguyên dương và chọn ít nhất một người.');
    return ids.map((id, i) => ({ id, amount: Math.floor(amount / ids.length) + (i < amount % ids.length ? 1 : 0) }));
  }
  function balances(bills, payments, count) {
    const result = Array(count).fill(0);
    bills.filter(b => b.source === 'personal').forEach(b => { result[b.payer] += b.amount; split(b.amount, b.ids).forEach(s => result[s.id] -= s.amount); });
    payments.filter(p => p.status === 'confirmed').forEach(p => { result[p.from] += p.amount; result[p.to] -= p.amount; });
    return result;
  }
  function transfers(balance) {
    const debtors = balance.map((n,id) => ({id, amount: -n})).filter(x => x.amount > 0);
    const creditors = balance.map((n,id) => ({id, amount: n})).filter(x => x.amount > 0);
    const result = []; let i=0, j=0;
    while (i < debtors.length && j < creditors.length) { const amount=Math.min(debtors[i].amount,creditors[j].amount); result.push({from:debtors[i].id,to:creditors[j].id,amount}); debtors[i].amount-=amount; creditors[j].amount-=amount; if(!debtors[i].amount)i++; if(!creditors[j].amount)j++; }
    return result;
  }
  function directTransfers(bills, payments, count) {
    const pairs = Array.from({length:count}, () => Array(count).fill(0));
    bills.filter(b => b.source === 'personal').forEach(b => {
      split(b.amount,b.ids).forEach(s => { if(s.id !== b.payer){pairs[s.id][b.payer]+=s.amount;pairs[b.payer][s.id]-=s.amount;} });
    });
    payments.filter(p=>p.status==='confirmed').forEach(p=>{pairs[p.from][p.to]-=p.amount;pairs[p.to][p.from]+=p.amount;});
    const result=[];
    for(let i=0;i<count;i++)for(let j=i+1;j<count;j++){
      const n=pairs[i][j];if(n)result.push({from:n>0?i:j,to:n>0?j:i,amount:Math.abs(n)});
    }
    return result;
  }
  function personalDebts(bills, payments, count, id) {
    const pairs=directTransfers(bills,payments,count);
    const owed=pairs.filter(t=>t.from===id), receivable=pairs.filter(t=>t.to===id);
    return {owed,receivable,owe:owed.reduce((sum,t)=>sum+t.amount,0),receive:receivable.reduce((sum,t)=>sum+t.amount,0)};
  }
  function contactDebts(groups, userId) {
    const contacts=new Map();
    for(const g of groups){
      const me=g.memberIds.indexOf(userId);if(me<0)continue;
      const pairs=directTransfers(g.state.bills,g.state.payments,g.memberIds.length);
      g.memberIds.forEach((id,index)=>{
        if(id===userId)return;
        if(!contacts.has(id))contacts.set(id,{id,name:g.state.names[index],owe:0,receive:0,groups:[]});
        const c=contacts.get(id),owe=pairs.find(t=>t.from===me&&t.to===index)?.amount||0,receive=pairs.find(t=>t.from===index&&t.to===me)?.amount||0;
        c.owe+=owe;c.receive+=receive;c.groups.push({id:g.id,name:g.name,owe,receive});
      });
    }
    return [...contacts.values()].sort((a,b)=>(b.owe+b.receive)-(a.owe+a.receive));
  }
  function explanation(bills,payments,id) {
    const rows=[];
    bills.filter(b=>b.source==='personal').forEach(b=>{
      const share=split(b.amount,b.ids).find(s=>s.id===id)?.amount||0;
      const paid=b.payer===id?b.amount:0;
      if(share||paid)rows.push({kind:'bill',id:b.id,paid,share,amount:paid-share});
    });
    payments.forEach((p,index)=>{if(p.status==='confirmed'&&(p.from===id||p.to===id))rows.push({kind:'payment',id:index,amount:p.from===id?p.amount:-p.amount});});
    return rows;
  }
  function canClose(openFeedback,pendingPayments,pendingContributions){return openFeedback===0&&pendingPayments===0&&pendingContributions===0;}
  root.Money = { split, balances, transfers, directTransfers, personalDebts, contactDebts, explanation, canClose };
  if (typeof module !== 'undefined') module.exports = root.Money;
})(globalThis);
