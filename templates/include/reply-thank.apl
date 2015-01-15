            <div class="reply-thank">

            % if ($helpers->acl->is_anon) {
                <span class="quick-thank-counter"><%= $reply->{thanks_count} ? $reply->{thanks_count} : '' %></span>
                <i class="fa fa-star-o"></i>
            % } elsif ($helpers->acl->is_author($reply)) {
                <span class="quick-thank-counter"><%= $reply->{thanks_count} ? $reply->{thanks_count} : '' %></span>
                <i class="fa fa-star-o opacity"></i>
            % } else {
            % my $is_thanked = $helpers->reply->is_thanked($reply);
            <form class="form-inline ajax" method="POST" action="<%= $helpers->url->thank_reply(id => $reply->{id}) %>">
            <input type="hidden" name="update" value=".quick-thank-counter=count" />
            <button class="link quick-thank-button" title="<%= loc('thank you') %>">
                <span class="quick-thank-counter">
                % if ($reply->{thanks_count}) {
                <%= $reply->{thanks_count} %>
                % }
                </span>
                <i class="fa fa-star<%= $is_thanked ? '' : '-o' %>" data-switch-class="fa-star,fa-star-o"></i>
            </button>
            </form>
            % }

            </div>


