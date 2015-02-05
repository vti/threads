(function(){

    $('.quick-reply-form textarea, .quick-edit-form textarea').focus(function() {
       $(this).removeClass('error');
       $(this).next('div.error').hide();
    });

    $('.quick-reply-button').click(function() {
        var form = $(this).parent().find('.quick-reply-form');

        if (!form.css('display') || form.css('display') == 'none') {
            form.addClass('visible');
            form.show();

            var textarea = form.find('textarea');

            var selection = window.getSelection().toString();
            if (selection) {
                selection = selection.replace(/^/gm, '> ');
                selection += "\n\n";
                textarea.val(selection);
            }

            textarea.focus();
            textarea.autosize();

            textarea.keydown(function (e) {
              if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
                  e.preventDefault();

                  $(this).closest('form').submit();
              }
            });
        }
        else {
            form.removeClass('visible');
            form.find('textarea').off('keydown');
            form.hide();
        }

        return false;
    });

    $('.quick-edit-button').click(function() {
        var form = $(this).parent().find('.quick-edit-form');

        if (!form.css('display') || form.css('display') == 'none') {
            form.addClass('visible');
            form.show();

            var textarea = form.find('textarea');
            textarea.focus();
            textarea.autosize();

            textarea.keydown(function (e) {
              if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
                  e.preventDefault();

                  $(this).closest('form').submit();
              }
            });
        }
        else {
            form.removeClass('visible');
            form.find('textarea').off('keydown');
            form.hide();
        }

        return false;
    });

    $('.index-sorting select').change(function() {
        $('.index-sorting form').submit();
        return false;
    });

    $('.markup-help-button').click(function() {
        var help = $(this).parent().find('.markup-help');
        if (!help.html().length) {
            var el = $('.markup-help-template').clone();
            help.html(el.html());
        }

        help.find('.markup-help-instance').toggle();
        return false;
    });

    function highightReply() {
        var hash = window.location.hash;
        if (hash) {
            var re = /reply-\d+/;
            var match = re.exec(hash);

            if (match && match.length) {
                var el = $('a[name=' + match[0] + ']').closest('.reply');

                el.addClass('reply-highlighted');
                setTimeout(function() {
                    el.removeClass('reply-highlighted');
                }, 500);
            }
        }
    }

    highightReply();
    $(window).bind('hashchange', function() {
        highightReply();
    });

    $('form.ajax').submit(function() {
        var form = $(this);
        var formData = form.serializeArray();
        $.ajax({
            type: 'POST',
            url: form.attr('action'),
            data: formData,
            success: function(data) {
                if (data.redirect) {
                    window.location = data.redirect;
                }
                else if (data.errors) {
                    for (var key in data.errors) {
                        var field = form.find('textarea[name='+key+']');

                        if (field.length) {
                            field.addClass('error');
                            if (!field.next('div.error').length) {
                                field.after('<div class="error"></div>');
                            }
                            field.next('div.error').html(data.errors[key]).show();
                        }
                    }
                }
                else {
                    form.find('input[name=update]').each(function() {
                        var value = $(this).attr('value');
                        var arr = value.split('=');

                        form.find(arr[0]).html(data[arr[1]]);
                    });

                    form.find('[data-switch-class]').each(function() {
                        var values = $(this).data('switch-class').split(',');

                        var from = data.state ? values[1] : values[0];
                        var to = data.state ? values[0] : values[1];

                        $(this).removeClass(from).addClass(to);
                    });

                    form.find('[data-switch-attr]').each(function() {
                        var arr = $(this).data('switch-attr').split('=');
                        var attr = arr[0];
                        var values = arr[1].split(',');

                        var to = data.state ? values[0] : values[1];

                        $(this).attr(attr, to);
                    });
                }
            },
            failure: function(errMsg) {}
        });

        return false;
    });

    $('.reply').mouseover(function() {
        $(this).find('.reply-controls').removeClass('invisible-on-desktop').parent().addClass('reply-over');

        var unread = $(this).find('.unread');
        if (unread.length) {
            unread.removeClass('unread');

            var action = unread.data('read-reply');

            if (action) {
                $.ajax({type: 'POST', url: action, success: function(data) {
                    var unread_count = data.count;

                    if (unread_count) {
                        $('.notification-count').text(unread_count);
                    }
                    else {
                        $('.notification-count').remove();
                    }
                }});
            }
        }
    });

    $('.reply').mouseout(function() {
        if (!$(this).find('.visible').length) {
            $(this).find('.reply-controls').addClass('invisible-on-desktop').parent().removeClass('reply-over');
        }
    });

    $('.tabs-topics a.topic').click(function() {
        var a = $(this);
        var li = $(this).closest('li');

        if (!li.hasClass('active')) {
            var name = a.attr('name');

            //var height = 0;
            //li.closest('.tabs-outer').find('.tabs-content li').each(function() {
            //    var el = $(this);
            //    if (el.outerHeight() > height) {
            //        height = el.outerHeight();
            //    }
            //});

            li.closest('.tabs-topics').find('li.active').removeClass('active');
            li.closest('.tabs-topics').find('li a[name=' + name + ']').closest('li').addClass('active');

            li.closest('.tabs-outer').find('.tabs-content li.active').removeClass('active');

            var content_li = li.closest('.tabs-outer').find('.tabs-content li.' + name);
            content_li.addClass('active');

            var action = content_li.data('post-action');
            var action_content = li.closest('.tabs-outer').find(content_li.data('post-content'));
            if (action && action_content) {
                $.ajax({
                    type: 'POST',
                    url: action,
                    data: {content:action_content.val()},
                    success: function(data) {
                        content_li.html(data.content);
                    },
                    failure: function(errMsg) {}
                });
            }
        }

        return false;
    });

})();
