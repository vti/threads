% $helpers->meta->set(title => loc('Settings'));

<div class="grid-100">

    <h1><%= loc('Settings') %></h1>

    <form method="POST">

    <div><label>Email</label></div>
    <div class="form-input"><input value="<%= $user->{email} %>" disabled="disabled"/></div>

    <%== $helpers->form->input('email_notifications', type => 'checkbox', label => loc('Email notifications'), default => $user->{email_notifications}) %>

    <div class="form-submit">
        <input type="submit" value="<%= loc('Update') %>" />
    </div>

    </form>

</div>
