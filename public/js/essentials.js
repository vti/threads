(function(){
    var editors = [];
    $('pre.markup code').each(function() {
        $(this).replaceWith('<textarea class="code perl">' + $(this).text() + '</textarea>');
    });
    $('textarea.code').each(function() {
        var editor = CodeMirror.fromTextArea(this, {readOnly: true, lineNumbers: true});
        editors.push(editor);
    });
})();
