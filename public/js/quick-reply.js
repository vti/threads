(function(){

    $('.quick-reply-button').click(function() {
        var form = $(this).parent().find('.quick-reply-form');

        if (form.css('display') == 'none') {
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
            form.find('textarea').val('');
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
            //form.find('textarea').val('');
            form.find('textarea').off('keydown');
            form.hide();
        }

        return false;
    });

})();
