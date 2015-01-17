% $helpers->meta->set(title => loc('Profile'));

<div class="grid-100">

    <h1><%= loc('Profile') %></h1>

    <p>
        <i class="fa fa-folder"></i> <a href="<%= $helpers->url->index %>?user_id=<%= $helpers->acl->user->{id} %>"><%= loc('Threads') %></a><br >
        <i class="fa fa-bell"></i> <a href="<%= $helpers->url->list_subscriptions %>"><%= loc('Subscriptions') %></a><br />
        <i class="fa fa-envelope"></i> <a href="<%= $helpers->url->list_notifications %>"><%= loc('Notifications') %></a>
    </p>

    <p>
        <i class="fa fa-gears"></i> <a href="<%= $helpers->url->settings %>"><%= loc('Settings') %></a><br />
        <i class="fa fa-key"></i> <a href="<%= $helpers->url->change_password %>"><%= loc('Change password') %></a>
    </p>

    <p>
        <i class="fa fa-trash"></i> <a href="<%= $helpers->url->deregister %>" class="status-danger"><%= loc('Remove account') %></a>
    </p>

</div>
