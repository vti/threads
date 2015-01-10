% $helpers->meta->set(title => loc('Profile'));

<div class="grid-100">

    <h1><%= loc('Profile') %></h1>

    <p>
        <a href="<%= $helpers->url->index %>?user_id=<%= var('user')->{id} %>"><%= loc('Threads') %></a><br >
        <a href="<%= $helpers->url->list_subscriptions %>"><%= loc('Subscriptions') %></a>
    </p>

    <p>
        <a href="<%= $helpers->url->settings %>"><%= loc('Settings') %></a><br />
        <a href="<%= $helpers->url->change_password %>"><%= loc('Change password') %></a>
    </p>

    <p>
        <a href="<%= $helpers->url->deregister %>" class="status-danger"><%= loc('Remove account') %></a>
    </p>

</div>
