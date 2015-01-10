            <div class="reply-meta">
                <div class="reply-author">
                    <a name="reply-<%= $reply->{id} %>"></a>
                    <div class="reply-gravatar">
                    %== $helpers->gravatar->img($reply->{user});
                    </div>
                    <span class="<%= $helpers->thread->is_author($thread, $reply->{user}) ? 'status-bg-highlight' : '' %>"><%== $helpers->user->display_name($reply->{user}) %></span>
                    % if ($reply->{parent}) {
                        → <span class="<%= $helpers->thread->is_author($thread, $reply->{parent}->{user}) ? 'status-bg-highlight' : ''%>"><%== $helpers->user->display_name($reply->{parent}->{user}) %></span>
                    % }
                </div>
                <div class="reply-date"><a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>#reply-<%= $reply->{id} %>"><%= $helpers->date->format($reply->{created}) %></a></div>
            </div>


