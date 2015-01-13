<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Change password') %></h1>

    <form method="POST" id="change-password">

    <%== $helpers->form->password('old_password', label => loc('Current password')) %>
    <%== $helpers->form->password('new_password', label => loc('New password')) %>
    <%== $helpers->form->password('new_password_confirmation', label => loc('Repeat new password')) %>

    <div class="form-submit">
        <input type="submit" value="<%= loc('Save') %>" />
    </div>

    </form>

</div>
