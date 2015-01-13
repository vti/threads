<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Password reset') %></h1>

    <form method="POST">

    <%== $helpers->form->input('email', label => 'E-mail') %>

    <div class="form-submit">
        <input type="submit" value="<%= loc('Reset password') %>" />
    </div>

    </form>

</div>
