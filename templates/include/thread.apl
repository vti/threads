    <div class="thread">

        <div class="thread-counters">
        <div class="thread-counters-replies"><%= $thread->{replies_count} %></div>
        <div><i class="fa fa-eye"></i> <%= $thread->{views_count} %></div>
        % if (var('user')) {
        <form class="form-inline ajax" action="<%= $helpers->url->toggle_subscription(id => $thread->{id}) %>">
            % my $is_sub = $helpers->subscription->is_subscribed($thread);
            % my $current_class = $is_sub ? 'fa-bell' : 'fa-bell-slash';
            <input type="hidden" name="replace-class" value=".quick-subscribe-button i=fa-bell,fa-bell-slash" />
            <button class="quick-subscribe-button"><i class="fa <%= $current_class %>" title="<%= $is_sub ? loc('unsubscribe') : loc('subscribe') %>"></i></button>
        </form>
        % }
        </div>


        <div class="thread-header">
            <h1 class="thread-title">
                <a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>"><%= $thread->{title} %></a>
            </h1>
            <div class="thread-meta">
                %== $helpers->gravatar->img($thread->{user}, 20);
                <strong><%== $helpers->user->display_name($thread->{user}) %></strong>
            </div>
            <div class="thread-date">
                <%= $helpers->date->format($thread->{created}) %>
                % if ($thread->{updated}) {
                    <%= loc('upd.') %> <%= $helpers->date->format($thread->{updated}) %>
                % }
            </div>
        </div>

        <div class="clear"></div>

        % if (!var('no_content')) {
        <div class="thread-content">
            % my $thread_content = $helpers->markup->render($thread->{content});
            % if (!var('view')) {
            %     $thread_content = $helpers->truncate->truncate($thread_content);
            % }
            <%== $thread_content %>
        </div>
        % }

    </div>
