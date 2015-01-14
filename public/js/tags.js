(function(){

    $(document).ready(function() {
        $('input[name=tags]').tagsInput({
            width:'243px',
            height:'auto',
            defaultText:''
        });

        $('div.tagsinput input').focus(function() {
            $(this).closest('div.tagsinput').addClass('glow');
        }).focusout(function() {
            $(this).closest('div.tagsinput').removeClass('glow');
        });
    });
})();
