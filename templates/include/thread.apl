    <div class="thread">
        <div class="thread-header">
            <div class="thread-counters">
            <div class="thread-counters-replies"><%= $thread->{replies_count} %></div>
            <div><i class="fa fa-eye"></i> <%= $thread->{views_count} %></div>
            % if (var('view') && var('user')) {
            <form class="form-inline quick-subscribe-form" action="<%= $helpers->url->toggle_subscription(id => $thread->{id}) %>">
                <button class="quick-subscribe-button"><%= $helpers->subscription->is_subscribed($thread) ? loc('unsubscribe') : loc('subscribe') %></button>
            </form>
            % }
            </div>

            <h1 class="thread-title">
                <a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>"><%= $thread->{title} %></a>
            </h1>
            <div class="thread-meta">
                <%= loc('by') %> <%== $helpers->user->display_name($thread->{user}) %>
            </div>
            <div class="thread-date"><%= $helpers->date->format($thread->{created}) %></div>

            <div class="clear"></div>
        </div>

        % if (!var('no_content')) {
        <div class="thread-content">
            <%== $helpers->markdown->render($thread->{content}) %>
        </div>
        % }

    </div>
