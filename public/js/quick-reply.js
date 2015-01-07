(function(){

    $('.quick-reply-form, .quick-edit-form').submit(function() {
        var textarea = $(this).find('textarea');
        var val = textarea.val().replace(/^\s+|\s+$/g, '');

        if (val.length) {
            return true;
        }
        else {
            textarea.addClass('error');
            return false;
        }
    });

    $('.quick-reply-form textarea, .quick-edit-form textarea').focus(function() {
       $(this).removeClass('error');
    });

    $('.quick-reply-button').click(function() {
        var form = $(this).parent().find('.quick-reply-form');

        if (!form.css('display') || form.css('display') == 'none') {
            form.show();
            form.find('textarea').focus();

            form.find('textarea').keydown(function (e) {
              if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
                  e.preventDefault();

                  $(this).parent().parent().submit();
              }
            });
        }
        else {
            form.find('textarea').off('keydown');
            form.hide();
        }

        return false;
    });

    $('.quick-edit-button').click(function() {
        var form = $(this).parent().find('.quick-edit-form');

        if (!form.css('display') || form.css('display') == 'none') {
            form.show();
            form.find('textarea').focus();

            form.find('textarea').keydown(function (e) {
              if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
                  e.preventDefault();

                  $(this).parent().parent().submit();
              }
            });
        }
        else {
            form.find('textarea').off('keydown');
            form.hide();
        }

        return false;
    });

    $('.quick-thank-form').submit(function() {
        var form = $(this);
        $.ajax({
            type: 'POST',
            url: $(this).attr('action'),
            success: function(data) {
                var count = data.count;

                form.find('.quick-thank-counter').html(count);
            },
            failure: function(errMsg) {}
        });

        return false;
    });

    $('.quick-subscribe-form').submit(function() {
        var form = $(this);
        $.ajax({
            type: 'POST',
            url: $(this).attr('action'),
            success: function(data) {
                var state = data.state;

                form.find('.quick-subscribe-button').html(state);
            },
            failure: function(errMsg) {}
        });

        return false;
    });

    $('.quick-delete-subscriptions').submit(function() {
        var form = $(this);
        $.ajax({
            type: 'POST',
            url: $(this).attr('action'),
            success: function(data) {
                var redirect = data.redirect;

                if (redirect) {
                    window.location = redirect;
                }
            },
            failure: function(errMsg) {}
        });

        return false;
    });

    $('.quick-delete-notifications').submit(function() {
        var form = $(this);
        var formData = $(this).serializeArray();

        $.ajax({
            type: 'POST',
            url: $(this).attr('action'),
            data: formData,
            success: function(data) {
                var redirect = data.redirect;

                if (redirect) {
                    window.location = redirect;
                }
            },
            failure: function(errMsg) {}
        });

        return false;
    });

    $('.index-sorting select').change(function() {
        $('.index-sorting form').submit();
        return false;
    });

})();
