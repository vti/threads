(function(){

    $(document).ready(function() {
        $('input[name=tags]').tagsInput({
            //autocomplete_url:'/tags/autocomplete',
            width:'243px',
            height:'auto',
            maxChars: 32,
            defaultText:''
        });

        $('div.tagsinput input').focus(function() {
            $(this).closest('div.tagsinput').addClass('glow');
        }).focusout(function() {
            $(this).closest('div.tagsinput').removeClass('glow');
        });
    });
})();
