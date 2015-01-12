            <div class="reply-thank">

            % if ($helpers->acl->is_anon || $helpers->acl->is_author($reply)) {
                <button disabled="disabled">
                <span class="quick-thank-counter"><%= $reply->{thanks_count} ? $reply->{thanks_counter} : '' %></span>
                <i class="fa fa-thumbs-o-up"></i>
                </button>
            % } else {
            % my $is_thanked = $helpers->reply->is_thanked($reply);
            <form class="form-inline ajax" method="POST" action="<%= $helpers->url->thank_reply(id => $reply->{id}) %>">
            <input type="hidden" name="update" value=".quick-thank-counter=count" />
            <input type="hidden" name="replace-class" value=".quick-thank-button i=fa-thumbs-up,fa-thumbs-o-up" />
            <button class="quick-thank-button" title="<%= loc('thank you') %>">
                <span class="quick-thank-counter">
                % if ($reply->{thanks_count}) {
                <%= $reply->{thanks_count} %>
                % }
                </span>
                <i class="fa fa-thumbs<%= $is_thanked ? '' : '-o' %>-up"></i>
            </button>
            </form>
            % }

            </div>


