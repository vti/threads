var Models = {};

(function(){
    var editors = [];
    $('pre.markup code').each(function() {
        $(this).replaceWith('<textarea class="code perl">' + $(this).text() + '</textarea>');
    });
    $('textarea.code').each(function() {
        var editor = CodeMirror.fromTextArea(this, {readOnly: true, lineNumbers: true});
        editors.push(editor);
    });

    var notificationCountObserver = new Observer();
    notificationCountObserver.on('set:count', function(count) {
        if (count) {
            var counter = $('.notification-count');
            if (!counter.length) {
                $('.notification-count-outer').append('<a class="notification-count"></a>');
            }

            $('.notification-count').text(count);
        }
        else {
            $('.notification-count').remove();
        }
    });

    var notificationCount = new NotificationCount();
    var counter = $('.notification-count');
    if (counter.length) {
        notificationCount.set('count', counter.text());
    }
    notificationCount.observe(notificationCountObserver);

    Models.notificationCount = notificationCount;
})();
