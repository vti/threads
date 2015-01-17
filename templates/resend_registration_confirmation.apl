% $helpers->meta->set(title => loc('Resend registration confirmation'));

<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Resend registration confirmation') %></h1>

    <form method="POST" id="resend_registration_confirmation">

    <%== $helpers->form->input('email', label => 'E-mail') %>
    <%== $helpers->form->password('password', label => loc('Password')) %>

    <div class="form-submit">
        <input type="submit" value="<%= loc('Resend') %>" />
    </div>

    </form>

</div>
