% $helpers->meta->set(title => loc('Settings'));

<div class="grid-100">

    <h1><%= loc('Settings') %></h1>

    <form method="POST">

    <div><label>Email</label></div>
    <div class="form-input"><input value="<%= $user->{email} %>" disabled="disabled"/></div>

    <%== $helpers->form->input('name', label => loc('Name'), default => $user->{name}) %>

    <%== $helpers->form->input('email_notifications', type => 'checkbox', label => loc('Email notifications'), default => $user->{email_notifications}) %>

    <input type="submit" value="<%= loc('Update') %>" />

    </form>

</div>
