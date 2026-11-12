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
      files: [], textContent: '', style: {}, addEventListener() {},
      setAttribute() {}, showModal() {}, close() {}, focus() {},
    });
    return elements.get(selector);
  },
};
const context = vm.createContext({
  assert, document, Money: require('../money.js'),
  setTimeout: () => 0, clearTimeout() {},
});
for (const file of ['flows.js', 'app.js']) {
  vm.runInContext(fs.readFileSync(require.resolve('../' + file), 'utf8'), context);
}
vm.runInContext(`
  bills=[]; deposits=0; refunded=0;
  const form={
    querySelectorAll: () => names.map((_, i) => ({value:String(i)})),
    elements:{namedItem:()=>({value:'Cả nhóm ăn tối'})},
    amount:{value:'300000'}, source:{value:'advance'}, payer:{value:'1'},
  };
  const submit=()=>reviewBill({preventDefault(){}, target:form});
  submit();
  assert.equal(draft.amount,300000);
  actions['save-bill']();
  assert.equal(fund().cash,0);
  assert.equal(fund().owed,300000);
  assert.equal(fund().available,-300000);
  assert.ok(balances().every(amount=>amount===0));
  const refundButton={dataset:{id:String(bills[0].id)}};
  actions['approve-refund'](refundButton);
  assert.equal(refunded,0);
  assert.equal(bills[0].refunded,undefined);
  form.source.value='fund'; submit();
  assert.equal(draft,null);
  assert.match(document.querySelector('#bill-error').textContent,/Quỹ khả dụng/);
  deposits=300000;
  actions['approve-refund'](refundButton);
  assert.equal(fund().cash,0);
  assert.equal(fund().owed,0);
  actions['approve-refund'](refundButton);
  assert.equal(refunded,300000);
`, context);
console.log('Passed: personal advances with empty fund, direct cash guard, refund cash guard and duplicate protection.');
