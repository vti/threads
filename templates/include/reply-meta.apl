            <div class="reply-meta">
                <div class="reply-author">
                    <a name="reply-<%= $reply->{id} %>"></a>
                    <div class="reply-gravatar">
                    %== $helpers->gravatar->img($reply->{user});
                    </div>
                    <%== $helpers->user->display_name($reply->{user}) %>
                    % if ($reply->{parent}) {
                        → <%== $helpers->user->display_name($reply->{parent}->{user}) %>
                    % }
                </div>
                <div class="reply-date"><a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>#reply-<%= $reply->{id} %>"><%= $helpers->date->format($reply->{created}) %></a></div>
            </div>


