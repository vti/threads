QUnit.module('actions/no_count');
QUnit.test("return 0 when no element", function(assert) {
  var action = new NoCountAction();

  var count = action.get();

  assert.equal(count, 0);
});

QUnit.test("return current value", function(assert) {
  var action = new NoCountAction();

  $('<span class="notification-count-outer">'
      + '<a class="notification-count" href="/notifications">6<a>'
      + '</span>').appendTo('#qunit-fixture');

  var count = action.get();

  assert.equal(count, 6);
});

QUnit.test("insert new value", function(assert) {
  var action = new NoCountAction();

  $('<span class="notification-count-outer">'
      + '</span>').appendTo('#qunit-fixture');

  action.update(10);

  assert.ok($('.notification-count').length);
  assert.equal(action.get(), 10);
});

QUnit.test("update to new value", function(assert) {
  var action = new NoCountAction();

  $('<span class="notification-count-outer">'
      + '<a class="notification-count" href="/notifications">6<a>'
      + '</span>').appendTo('#qunit-fixture');

  action.update(10);

  assert.equal(action.get(), 10);
});

QUnit.test("remove when zero", function(assert) {
  var action = new NoCountAction();

  $('<span class="notification-count-outer">'
      + '<a class="notification-count" href="/notifications">6<a>'
      + '</span>').appendTo('#qunit-fixture');

  action.update(0);

  var el = $('.notification-count');

  assert.equal(el.length, 0);
});
