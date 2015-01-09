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

    <tr>
    <td width="1%">
        <form class="form-inline ajax" method="POST" action="<%= $helpers->url->delete_notifications %>">
        <input type="hidden" name="id" value="<%= $notification->{id} %>" />
        <button class="no-wrap"><i class="fa fa-check"></i></button>
        </form>
    </td>
    <td>
        <strong>
            <a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>">
                <%= $thread->{title} %>
            </a>
        </strong>

        <br />
        <br />

        %== $helpers->displayer->render('include/reply-meta', reply => $reply, thread => $thread);

        <div class="reply-content">
            <%== $helpers->markup->render($reply->{content}) %>
        </div>
    </td>
    </tr>
    % }
    </table>

    %== $helpers->displayer->render('include/pager', base_url => $helpers->url->list_notifications, total => $helpers->notification->count);
</div>
