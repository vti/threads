% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    %== $helpers->displayer->render('include/thread', thread => $thread, view => 1);

    %== $helpers->displayer->render('include/thread-controls', thread => $thread);

    % foreach my $reply ($helpers->reply->find_by_thread($thread)) {
        % my $padding = $reply->{level} * 10;
        % $padding = 100 if $padding > 100;
        <div class="reply" style="padding-left:<%= $padding %>px">
            <div class="reply-meta">
                <div class="reply-author">
                    <a name="comment-<%= $reply->{id} %>"></a>
                    <div class="reply-gravatar">
                    %== $helpers->gravatar->img($reply->{user}->{email});
                    </div>
                    <%= $helpers->user->display_name($reply->{user}) %>
                    % if ($reply->{parent}) {
                        → <%= $helpers->user->display_name($reply->{parent}->{user2}) %>
                    % }
                </div>
                <div class="reply-date"><a href="#comment-<%= $reply->{id} %>"><%= $helpers->date->format($reply->{created}) %></a></div>
            </div>

            <div class="reply-content">
                <%== $helpers->markdown->render($reply->{content}) %>
            </div>

            %== $helpers->displayer->render('include/reply-controls', thread => $thread, reply => $reply);
        </div>
    % }

</div>
