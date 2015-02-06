QUnit.module('models/value_object');
QUnit.test("simple set/get", function(assert) {
  var valueObject = new ValueObject();

  valueObject.set('foo', 'bar');

  assert.equal(valueObject.get('foo'), 'bar');
});

QUnit.test("accept properties from constructor", function(assert) {
  var valueObject = new ValueObject({foo: 'bar'});

  assert.equal(valueObject.get('foo'), 'bar');
});
