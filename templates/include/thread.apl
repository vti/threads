    <div class="thread">
        <div class="thread-header">
            <div class="thread-counters">
            <div class="thread-counters-replies"><%= $thread->{replies_count} %></div>
            <a href="">subscribe</a>
            </div>

            <h1 class="thread-title">
                <a href="<%= $helpers->url->view_thread(id => $thread->{id}) %>"><%= $thread->{title} %></a>
            </h1>
            <div class="thread-meta">
                by <%= $helpers->user->display_name($thread->{user}) %>
            </div>
            <div class="thread-date"><%= $helpers->date->format($thread->{created}) %></div>

            <div class="clear"></div>
        </div>

        <div class="thread-content">
            <%== $helpers->markdown->render($thread->{content}) %>
        </div>

        % if ($quick_reply && var('user')) {
        <div class="thread-controls">
        Thread actions:
            % if ($helpers->acl->is_allowed('update_thread', $thread)) {
            <form class="form-inline" action="<%= $helpers->url->update_thread(id => $thread->{id}) %>">
            <input type="submit" value="edit" />
            </form>
            % }
            % if ($helpers->acl->is_allowed('delete_thread', $thread)) {
            <form class="form-inline" method="POST" action="<%= $helpers->url->delete_thread(id => $thread->{id}) %>">
            <input type="submit" value="delete" />
            </form>
            % }
        </div>
        % }
    </div>

% if ($quick_reply) {
    %== $helpers->displayer->render('include/quick-reply', thread => $thread);
% }
