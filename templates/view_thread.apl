% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    %== $helpers->displayer->render('include/thread', thread => $thread, quick_reply => 1);

    % foreach my $reply ($helpers->reply->find_by_thread($thread)) {
        <div class="reply">
            <div class="reply-meta">
                <div class="reply-author"><%= $reply->{user}->{name} || 'User' . $reply->{user_id} %></div>
                <div class="reply-date"><%= $helpers->date->format($reply->{created}) %></div>
            </div>

            <div class="reply-content">
                <%== $helpers->markdown->render($reply->{content}) %>
            </div>

            %== $helpers->displayer->render('include/quick-reply', thread => $thread, to => $reply->{id});
        </div>
    % }

</div>
