(function(){

    $('.quick-reply .outer').click(function() {
        $(this).hide();
        $(this).parent().find('.inner').show();

        return false;
    });

    $('.quick-reply-close').click(function() {
        $(this).parent().parent().parent().find('.outer').show();
        $(this).parent().parent().parent().find('.inner').hide();

        return false;
    });


})();
