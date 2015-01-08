        <div class="thread-controls">
            <button class="quick-reply-button"><i class="fa fa-reply"></i> <%= loc('reply to thread') %></button>

            % if ($helpers->acl->is_allowed('update_thread', $thread)) {
            <form class="form-inline" action="<%= $helpers->url->update_thread(id => $thread->{id}) %>">
            <button type="submit"><i class="fa fa-edit"></i> <%= loc('edit') %></button>
            </form>
            % }
            % if ($helpers->acl->is_allowed('delete_thread', $thread)) {
            <form class="form-inline" method="POST" action="<%= $helpers->url->delete_thread(id => $thread->{id}) %>">
            <button type="submit"><i class="fa fa-remove"></i> <%= loc('delete') %></button>
            </form>
            % }

            %== $helpers->displayer->render('include/quick-reply-form', thread => $thread, reply => var('reply'));
        </div>

