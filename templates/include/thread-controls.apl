        <div class="thread-controls">
            <button class="quick-reply-button">reply to thread</button>

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

            %== $helpers->displayer->render('include/quick-reply-form', thread => $thread, reply => var('reply'));
        </div>

