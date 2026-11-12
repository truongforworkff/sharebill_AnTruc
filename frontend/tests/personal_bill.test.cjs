const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
const elements = new Map();
const document = {
  body: { dataset: {}, classList: { remove() {} } },
  addEventListener() {},
  querySelectorAll: () => [],
  querySelector(selector) {
    if (!elements.has(selector)) elements.set(selector, {
      files: [], textContent: '', style: {}, dataset: {},
      classList: { toggle() {} }, addEventListener() {},
      setAttribute() {}, showModal() {}, close() {}, focus() {},
    });
    return elements.get(selector);
  },
};
const context = vm.createContext({
  assert, document, elements, Money: require('../money.js'),
  setTimeout: () => 0, clearTimeout() {},
});
for (const file of ['flows.js', 'app.js']) {
  vm.runInContext(fs.readFileSync(require.resolve('../' + file), 'utf8'), context);
}
vm.runInContext(`
  names=['An','Bình','Chi']; all=names.map((_,i)=>i);
  render=()=>{};
  bills=[]; payments=[]; deposits=0; refunded=0;
  let selected=[0,1];
  const form={
    querySelectorAll: () => selected.map(i => ({value:String(i)})),
    elements:{namedItem:()=>({value:'Cả nhóm ăn tối'})},
    amount:{value:'300000'}, source:{value:'personal',dataset:{}}, payer:{value:'0'},
  };
  elements.set('#bill-form',form);
  updateSplit();
  assert.equal(form.source.value,'personal');
  selected=[0,1,2]; updateSplit();
  assert.equal(form.source.value,'personal');
  assert.match(form.source.innerHTML,/value="personal"/);
  assert.match(form.source.innerHTML,/value="fund"/);
  assert.match(form.source.innerHTML,/value="advance"/);
  reviewBill({preventDefault(){},target:form});
  assert.equal(draft.source,'personal');
  actions['save-bill']();
  assert.equal(fund().cash,0);
  assert.equal(fund().owed,0);
  assert.equal(fund().available,0);
  assert.equal(JSON.stringify(balances()),JSON.stringify([200000,-100000,-100000]));
  const transfers=Money.directTransfers(bills,payments,3);
  assert.equal(JSON.stringify(transfers),JSON.stringify([
    {from:1,to:0,amount:100000},{from:2,to:0,amount:100000},
  ]));
  payments.push({from:1,to:0,amount:40000,status:'pending'});
  assert.equal(Money.personalDebts(bills,payments,3,1).owe,100000);
  actions['approve-payment']({dataset:{id:'0'}});
  assert.equal(Money.personalDebts(bills,payments,3,1).owe,60000);
  assert.equal(Money.personalDebts(bills,payments,3,0).receive,160000);
  assert.equal(fund().available,0);

  // A nonempty fund must not silently take over a personally paid bill either.
  deposits=500000; updateSplit();
  assert.equal(form.source.value,'personal');
  assert.equal(fund().available,500000);

  // Fund choices are explicit and are removed if attendance becomes partial.
  form.source.value='advance'; updateSplit();
  assert.equal(form.source.value,'advance');
  selected=[0,1]; updateSplit();
  assert.equal(form.source.value,'personal');
  selected=[0,1,2]; updateSplit();
  assert.equal(form.source.value,'personal');
  selected=[0,1]; form.source.value='advance';
  reviewBill({preventDefault(){},target:form});
  assert.equal(draft,null);
  assert.match(document.querySelector('#bill-error').textContent,/đủ tất cả thành viên/);
`, context);
console.log('Passed: all-member personal bill with zero fund, distinct debts, partial payment, explicit funding and attendance changes.');
