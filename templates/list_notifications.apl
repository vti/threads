% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    <h1><%= loc('Notifications') %> (<%= $helpers->notification->count %>)</h1>

    % my @notifications = $helpers->notification->find;

    % if (@notifications) {
        <p>
        <form class="form-inline ajax" method="POST" action="<%= $helpers->url->delete_notifications %>">
        <button><i class="fa fa-check"></i> <%= loc('mark all read') %></button>
        </form>
        </p>
    % }

    <table width="100%">
    % foreach my $notification (@notifications) {
    %    my $reply  = $notification->{reply};
    %    my $thread = $reply->{thread};

    <tr class="border-bottom">
    <td width="20%">

        <div class="thread-title">
            <%= loc('Thread') %>: <a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>">
                <%= $thread->{title} %>
            </a>
        </div>

        <div class="reply-meta">
            <div class="reply-author">
                <div class="reply-gravatar">
                %== $helpers->gravatar->img($reply->{user2});
                </div>
                <%== $helpers->user->display_name($reply->{user2}) %>
            </div>
            <div class="reply-date"><a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>#reply-<%= $reply->{id} %>"><%= $helpers->date->format($reply->{created}) %></a></div>
        </div>

    </td>
    <td>
            <div class="reply-content">
                <%== $helpers->markup->render($reply->{content}) %>
            </div>

    </td>
    <td>
        <form class="form-inline quick-delete-notifications" method="POST" action="<%= $helpers->url->delete_notifications %>">
        <input type="hidden" name="id" value="<%= $notification->{id} %>" />
        <button class="no-wrap"><i class="fa fa-remove"></i> <%= loc('delete') %></button>
        </form>
    </td>
    </tr>
    % }
    </table>

    %== $helpers->displayer->render('include/pager', base_url => $helpers->url->list_notifications, total => $helpers->notification->count);
</div>
