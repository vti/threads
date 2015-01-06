<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Reset password') %></h1>

    <form method="POST">

    <%== $helpers->form->password('new_password', label => loc('New password')) %>
    <%== $helpers->form->password('new_password_confirmation', label => loc('Repeat new password')) %>

    <input type="submit" value="<%= loc('Reset') %>" />

    </form>

</div>
