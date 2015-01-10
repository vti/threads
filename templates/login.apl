% $helpers->meta->set(title => loc('Authorization'));

<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Authorization') %></h1>

    <form method="POST" id="login">

    <%== $helpers->form->input('email', label => 'E-mail') %>
    <%== $helpers->form->password('password', label => loc('Password')) %>
    <div class="form-input"><a href="<%= $helpers->url->request_password_reset %>"><%= loc('Reset password') %></a></div>

    <input type="submit" value="<%= loc('Login') %>" />
    </form>

</div>
