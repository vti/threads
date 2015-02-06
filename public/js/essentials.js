var Models  = {};
var Actions = {};

(function(){
    var editors = [];
    $('pre.markup code').each(function() {
        $(this).replaceWith('<textarea class="code perl">' + $(this).text() + '</textarea>');
    });
    $('textarea.code').each(function() {
        var editor = CodeMirror.fromTextArea(this, {readOnly: true, lineNumbers: true});
        editors.push(editor);
    });

    Actions.noCount = new NoCountAction;
    Actions.noCountTitle = new NoCountTitleAction;

    Models.noCount = new ValueObjectObservable({count: Actions.noCount.get()});
    Models.noCount.onchange('count', function(count) {
        Actions.noCount.update(count);
    });
    Models.noCount.onchange('count', function(count) {
        Actions.noCountTitle.update(count);
    });
})();
