QUnit.module('models/value_object_observable');
QUnit.test("set/get still works", function(assert) {
  var valueObjectObservable = new ValueObjectObservable();

  valueObjectObservable.set('foo', 'bar');

  assert.equal(valueObjectObservable.get('foo'), 'bar');
});

QUnit.test("observe change", function(assert) {
  var valueObjectObservable = new ValueObjectObservable();
  var got;
  valueObjectObservable.onchange('foo', function(newValue) {
      got = newValue;
  });

  valueObjectObservable.set('foo', 'bar');

  assert.equal(got, 'bar');
});

QUnit.test("not observe when value not changed", function(assert) {
  var valueObjectObservable = new ValueObjectObservable();
  valueObjectObservable.set('foo', 'bar');

  var got;
  valueObjectObservable.onchange('foo', function(newValue) {
      got = newValue;
  });

  valueObjectObservable.set('foo', 'bar');

  assert.ok(!got);
});
