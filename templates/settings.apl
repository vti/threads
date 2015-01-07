<div class="grid-100">

    <h1><%= loc('Settings') %></h1>

    <form method="POST">

    <%== $helpers->form->input('name', label => 'Name', default => $user->{name}) %>

    <input type="submit" value="<%= loc('Update') %>" />

    </form>

    <div style="padding-top:2em">
        <a href="<%= $helpers->url->deregister %>"><%= loc('Remove account') %></a>
    </div>

</div>
