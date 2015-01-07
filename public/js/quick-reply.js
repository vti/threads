(function(){

    $('.quick-reply .inner').hide();

    $('.quick-reply .outer').click(function() {
        $(this).hide();
        $(this).parent().find('.inner').show();

        return false;
    });


})();
