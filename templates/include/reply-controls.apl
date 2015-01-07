        <div class="reply-controls">
            <form class="form-inline quick-thank-form" method="POST" action="<%= $helpers->url->thank_reply(id => $reply->{id}) %>">
            <button><%= loc('thank') %> (<span class="quick-thank-counter"><%= $reply->{thanks_count} %></span>)</button>
            </form>
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

