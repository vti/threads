    <div class="thread">

        <div class="thread-counters">
        <div class="thread-counters-replies"><%= $thread->{replies_count} %></div>
        <div><i class="fa fa-eye"></i> <%= $thread->{views_count} %></div>
        % if ($helpers->acl->is_user) {
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
                % my $has_editor = $thread->{editor}->{id} != $thread->{user}->{id};
                % if ($helpers->date->is_distant_update($thread) || $has_editor) {
                    <%= loc('upd.') %> <%= $helpers->date->format($thread->{updated}) %>

                    % if ($has_editor) {
                        %== $helpers->gravatar->img($thread->{editor}, 20);
                        <strong><%== $helpers->user->display_name($thread->{editor}) %></strong>
                    % }
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

        <div class="thread-tags">
        % foreach my $tag (@{$thread->{tags}}) {
            <a href="<%= $helpers->url->index %>?tag=<%= $tag->{title} %>"><span class="thread-tag"><%= $tag->{title} %></span></a>
        % }
        </div>

    </div>
