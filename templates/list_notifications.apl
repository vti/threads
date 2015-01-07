% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    <h1><%= loc('Notifications') %></h1>

    % my @notifications = $helpers->notification->find;

    % if (@notifications) {
        <p>
        <form class="form-inline quick-delete-notifications" method="POST" action="<%= $helpers->url->delete_notifications %>">
        <button><%= loc('mark all read') %></button>
        </form>
        </p>
    % }

    <table width="100%">
    <tr>
    <th width="1%">&nbsp;</th>
    <th><%= loc('thread') %></th>
    <th><%= loc('author') %></th>
    <th><%= loc('reply content') %></th>
    <th width="1%">&nbsp;</th>
    </tr>
    % foreach my $notification (@notifications) {
    %    my $reply = $notification->{reply};
    %    my $thread = $reply->{thread};

    <tr>
    <td width="1%">
    <div class="no-wrap"><%= $helpers->date->format($notification->{created}) %></div>
    </td>
    <td>
    <a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>"><%= $thread->{title} %></a>
    </td>
    <td>
    <%= $helpers->user->display_name($reply->{user}) %>
    </td>
    <td>
    <%== $helpers->markdown->render($reply->{content}) %>
<a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>#comment-<%= $reply->{id}%>">go to</a>
    </td>

    <td width="1%" class="td-right">
        <form class="form-inline quick-delete-notifications" method="POST" action="<%= $helpers->url->delete_notifications %>">
        <input type="hidden" name="id" value="<%= $notification->{id} %>" />
        <button><%= loc('delete') %></button>
        </form>
    </td>
    <tr>

    % }
    </table>

</div>
