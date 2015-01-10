        <div class="reply-controls">
            % if (var('user')) {
            <button class="quick-reply-button"><i class="fa fa-reply"></i> <%= loc('reply') %></button>
            % }

            % if ($helpers->acl->is_allowed('update_reply', $reply)) {
            <button class="quick-edit-button"><i class="fa fa-edit"></i> <%= loc('edit') %></button>
            % }
            % if ($helpers->acl->is_allowed('delete_reply', $reply)) {
            <form class="form-inline" method="POST" action="<%= $helpers->url->delete_reply(id => $reply->{id}) %>">
            <button type="submit"><i class="fa fa-remove"></i> <%= loc('delete') %></button>
            </form>
            % }

            % if (0) {
            % if (var('user') && var('user')->{id} != $reply->{user_id}) {
            % my $is_flagged = $helpers->reply->is_flagged($reply);
            % my $current_class = $is_flagged ? 'fa-flag' : 'fa-flag-o';

            <form class="ajax form-inline" method="POST" action="<%= $helpers->url->toggle_report(id => $reply->{id}) %>">
            <input type="hidden" name="replace-class" value=".quick-flag-button i=fa-flag,fa-flag-o" />
            <button class="quick-flag-button" type="submit" title="<%= loc('report') %>"><i class="fa <%= $current_class %>"></i></button>
            </form>
            % }
            % }

            %== $helpers->displayer->render('include/quick-reply-form', thread => $thread, reply => var('reply'));
            %== $helpers->displayer->render('include/quick-edit-form', reply => var('reply'));
        </div>

