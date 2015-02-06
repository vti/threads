(function(){

    this.NoCountAction = function() {};
    NoCountAction.prototype.get = function() {
        var counter = $('.notification-count');
        if (counter.length)
            return counter.text();
        else
            return 0;
    };
    NoCountAction.prototype.update = function(count) {
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
    };

    this.NoCountTitleAction = function() {};
    NoCountTitleAction.prototype.get = function() {
        var title = document.title;

        var re = /^\((\d+)\)\s+/;
        var match = re.exec(title);
        if (match && match.length) {
            return match[1];
        }

        return 0;
    };

    NoCountTitleAction.prototype.update = function(count) {
        var old_title = document.title;
        var new_title = old_title.replace(/^\(\d+\)\s+/, '');

        if (count) {
            new_title = '(' + count + ') ' + new_title;
        }

        document.title = new_title;
    };

})();
