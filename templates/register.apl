% $helpers->meta->set(title => loc('Registration'));

<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Registration') %></h1>

    <form method="POST">

    <%== $helpers->form->input('name', label => loc('Username'), help => loc('Only [_1]', 'a-z, A-Z, 0-9, -, _')) %>
    <%== $helpers->form->input('email', label => 'E-mail') %>
    <%== $helpers->form->password('password', label => loc('Password')) %>

    % if (my $captcha = $helpers->antibot->captcha) {
        <%== $helpers->form->input($captcha->{field_name}, label => $captcha->{text}) %>
    % }

    %== $helpers->antibot->fake_field;

    <div class="form-submit">
        <input type="submit" value="<%= loc('Register') %>" />
    </div>

    </form>

</div>

%== $helpers->antibot->static;
