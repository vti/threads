QUnit.module('actions/no_count_title', {
    beforeEach: function() {
        this.old_title = document.title;
    },
    afterEach: function() {
        document.title = this.old_title;
    }
});
QUnit.test("return 0 when nothing in title", function(assert) {
  var action = new NoCountTitleAction();

  var count = action.get();

  assert.equal(count, 0);
});

QUnit.test("return current count", function(assert) {
  var action = new NoCountTitleAction();

  document.title = '(123) hello';
  var count = action.get();

  assert.equal(count, 123);
});

QUnit.test("update count", function(assert) {
  var action = new NoCountTitleAction();

  document.title = '(123) hello';

  action.update(7);

  assert.equal(document.title, '(7) hello');
});

QUnit.test("insert count", function(assert) {
  var action = new NoCountTitleAction();

  document.title = 'hello';

  action.update(7);

  assert.equal(document.title, '(7) hello');
});
