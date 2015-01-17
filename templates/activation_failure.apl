<div class="grid-100 mobile-grid-100">

    <p><%= loc('Your confirmation token has expired') %></p>

    <p><a href="<%= $helpers->url->resend_registration_confirmation %>"><%= loc('Resend registration confirmation') %></a></p>

</div>
