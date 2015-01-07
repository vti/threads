<div class="grid-100">

    <h1><%= loc('Settings') %></h1>

    <form method="POST">

    <%== $helpers->form->input('name', label => 'Name') %>

    <input type="submit" value="<%= loc('Update') %>" />

    </form>


    <a href="<%= $helpers->url->deregister %>"><%= loc('Remove account') %></a>

</div>
