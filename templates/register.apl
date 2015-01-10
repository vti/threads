% $helpers->meta->set(title => loc('Registration'));

<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Registration') %></h1>

    <form method="POST">

    <%== $helpers->form->input('email', label => 'E-mail') %>
    <%== $helpers->form->password('password', label => loc('Password')) %>

    <input type="submit" value="<%= loc('Register') %>" />

    </form>

</div>
