(function(globals){
    var editors = [];
    $('pre.markup code').each(function() {
        $(this).replaceWith('<textarea class="code perl">' + $(this).text() + '</textarea>');
    });
    $('textarea.code').each(function() {
        var editor = CodeMirror.fromTextArea(this, {readOnly: true, lineNumbers: true});
        editors.push(editor);
    });

    $('.date').each(function() {
        var time = moment.utc($(this).html().trim(), 'YYYY-MM-DD HH:mm');
        $(this).html(time.local().format('YYYY-MM-DD HH:mm'));
    });

    globals.Models  = {};
    globals.Actions = {};

    Actions.noCount = new NoCountAction;
    Actions.noCountTitle = new NoCountTitleAction;

    Models.noCount = new ValueObjectObservable({count: Actions.noCount.get()});
    Models.noCount.onchange('count', function(count) {
        Actions.noCount.update(count);
    });
    Models.noCount.onchange('count', function(count) {
        Actions.noCountTitle.update(count);
    });
})(this);
