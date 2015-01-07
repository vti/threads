        <div class="reply-controls">
            <button class="quick-reply-button"><%= loc('reply') %></button>

            % if ($helpers->acl->is_allowed('update_reply', $reply)) {
            <button class="quick-edit-button"><%= loc('edit') %></button>
            % }
            % if ($helpers->acl->is_allowed('delete_reply', $reply)) {
            <form class="form-inline" method="POST" action="<%= $helpers->url->delete_reply(id => $reply->{id}) %>">
            <input type="submit" value="<%= loc('delete') %>" />
            </form>
            % }

            %== $helpers->displayer->render('include/quick-reply-form', thread => $thread, reply => var('reply'));
            %== $helpers->displayer->render('include/quick-edit-form', reply => var('reply'));
        </div>

