        <div class="reply-controls">
            <form class="form-inline ajax" method="POST" action="<%= $helpers->url->thank_reply(id => $reply->{id}) %>">
            <input type="hidden" name="update" value=".quick-thank-counter=count" />
            % my $disabled = '';
            % if (var('user') && var('user')->{id} == $reply->{user_id}) {
            %    $disabled = ' disabled="disabled"';
            % }
            <button<%= $disabled %>>
                <i class="fa fa-thumbs-up"></i>
                <span class="quick-thank-counter">
                % if ($reply->{thanks_count}) {
                <%= $reply->{thanks_count} %>
                % }
                </span>
            </button>
            </form>
            <button class="quick-reply-button"><i class="fa fa-reply"></i> <%= loc('reply') %></button>

            % if ($helpers->acl->is_allowed('update_reply', $reply)) {
            <button class="quick-edit-button"><i class="fa fa-edit"></i> <%= loc('edit') %></button>
            % }
            % if ($helpers->acl->is_allowed('delete_reply', $reply)) {
            <form class="form-inline" method="POST" action="<%= $helpers->url->delete_reply(id => $reply->{id}) %>">
            <button type="submit"><i class="fa fa-remove"></i> <%= loc('delete') %></button>
            </form>
            % }

            %== $helpers->displayer->render('include/quick-reply-form', thread => $thread, reply => var('reply'));
            %== $helpers->displayer->render('include/quick-edit-form', reply => var('reply'));
        </div>

