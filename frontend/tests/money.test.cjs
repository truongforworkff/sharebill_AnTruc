const assert = require('node:assert/strict');
const {split,balances,transfers} = require('../money.js');
assert.deepEqual(split(100,[0,1,2]).map(s=>s.amount),[34,33,33]);
assert.throws(()=>split(10,[]));assert.throws(()=>split(-1,[0]));assert.throws(()=>split(1.5,[0]));
const bills=[{amount:1000000,ids:[0,1,2,3,4],payer:1,source:'personal'},{amount:400000,ids:[0,1,2,3,4,5,6,7],payer:2,source:'advance'}];
let b=balances(bills,[],8);assert.deepEqual(b,[-200000,800000,-200000,-200000,-200000,0,0,0]);
assert.deepEqual(balances(bills,[{from:0,to:1,amount:100000,status:'pending'}],8),b);
b=balances(bills,[{from:0,to:1,amount:100000,status:'confirmed'}],8);assert.equal(b[0],-100000);assert.equal(b[1],700000);
bills.push({amount:400000,ids:[0,1],payer:0,source:'personal'});b=balances(bills,[],8);assert.equal(b[0],0);assert.equal(b.reduce((s,n)=>s+n,0),0);
for(const t of transfers(b)){b[t.from]+=t.amount;b[t.to]-=t.amount;}assert(b.every(n=>n===0));
console.log('Passed: split, rounding, validation, pending/confirmed payment, offset, group settlement.');
const {directTransfers,explanation,canClose}=require('../money.js');
const cycle=[{id:1,amount:200000,ids:[0],payer:1,source:'personal'},{id:2,amount:150000,ids:[2],payer:0,source:'personal'}];
assert.deepEqual(directTransfers(cycle,[],3),[{from:0,to:1,amount:200000},{from:2,to:0,amount:150000}]);
const expected=balances(cycle,[],3);assert.deepEqual(expected,[-50000,200000,-150000]);
for(let id=0;id<3;id++)assert.equal(explanation(cycle,[],id).reduce((s,r)=>s+r.amount,0),expected[id]);
const confirmed=[{from:0,to:1,amount:50000,status:'confirmed'}];
const after=balances(cycle,confirmed,3);assert.equal(explanation(cycle,confirmed,0).reduce((s,r)=>s+r.amount,0),after[0]);
const residual=[...after];for(const t of directTransfers(cycle,confirmed,3)){residual[t.from]+=t.amount;residual[t.to]-=t.amount;}assert(residual.every(n=>n===0));
assert(canClose(0,0,0));assert(!canClose(1,0,0));assert(!canClose(0,1,0));assert(!canClose(0,0,1));
console.log('Passed: original-recipient mode, explanation totals, confirmed payment consistency, close blockers.');
const {personalDebts}=require('../money.js');
let personal=personalDebts(cycle,[],3,0);
assert.equal(personal.owe,200000);assert.equal(personal.receive,150000);
assert.equal(personal.owed[0].to,1);assert.equal(personal.receivable[0].from,2);
assert.deepEqual(personalDebts(cycle,[{...confirmed[0],status:'pending'}],3,0),personal);
personal=personalDebts(cycle,confirmed,3,0);
assert.equal(personal.owe,150000);assert.equal(personal.receive,150000);
assert.equal(personal.receive-personal.owe,balances(cycle,confirmed,3)[0]);
const settled=[{from:0,to:1,amount:200000,status:'confirmed'},{from:2,to:0,amount:150000,status:'confirmed'}];
assert.deepEqual(personalDebts(cycle,settled,3,0),{owed:[],receivable:[],owe:0,receive:0});
console.log('Passed: named counterparties, separate debt/receivable totals, pending/partial/full settlement.');
const {contactDebts}=require('../money.js');
const shared=[
 {id:'a',name:'A',memberIds:['me','huy'],state:{names:['Bạn','Huy'],bills:[{amount:50000,ids:[1],payer:0,source:'personal'}],payments:[]}},
 {id:'b',name:'B',memberIds:['huy','me'],state:{names:['Huy','Bạn'],bills:[{amount:120000,ids:[1],payer:0,source:'personal'}],payments:[]}},
 {id:'c',name:'C',memberIds:['me','huy','other-huy'],state:{names:['Bạn','Huy','Huy'],bills:[{amount:80000,ids:[1],payer:0,source:'personal'},{amount:10000,ids:[2],payer:0,source:'personal'}],payments:[]}}
];
const original=JSON.stringify(shared);let contacts=contactDebts(shared,'me');
let huy=contacts.find(c=>c.id==='huy');assert.equal(huy.groups.length,3);assert.equal(huy.owe,120000);assert.equal(huy.receive,130000);assert.equal(huy.receive-huy.owe,10000);
assert.equal(contacts.find(c=>c.id==='other-huy').receive,10000);assert.equal(JSON.stringify(shared),original);
shared[1].state.payments.push({from:1,to:0,amount:20000,status:'pending'});
assert.equal(contactDebts(shared,'me').find(c=>c.id==='huy').owe,120000);
shared[1].state.payments[0].status='confirmed';huy=contactDebts(shared,'me').find(c=>c.id==='huy');assert.equal(huy.owe,100000);assert.equal(huy.receive,130000);
assert.deepEqual(contactDebts(shared,'unknown'),[]);
console.log('Passed: cross-group person identity, distinct namesakes, both totals, pending/confirmed payments, no ledger mutation.');
