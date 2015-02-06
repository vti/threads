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
                $('.notification-count-outer').append('<a href="/notifications" class="notification-count"></a>');
            }

            $('.notification-count').text(count);
        }
        else {
            $('.notification-count').remove();
        }

        var old_title = document.title;
        var new_title = old_title.replace(/^\(\d+\)\s+/, '');

        if (count) {
            new_title = '(' + count + ') ' + new_title;
        }

        document.title = new_title;
    });

    var notificationCount = new NotificationCount();
    var counter = $('.notification-count');
    if (counter.length) {
        notificationCount.set('count', counter.text());
    }
    notificationCount.observe(notificationCountObserver);

    Models.notificationCount = notificationCount;
})();
