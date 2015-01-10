% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    %== $helpers->displayer->render('include/thread', thread => $thread, view => 1);

    % if (var('user')) {
    %== $helpers->displayer->render('include/thread-controls', thread => $thread);
    % }

    <div class="replies">
    % foreach my $reply ($helpers->reply->find_by_thread($thread)) {
        % my $padding = $reply->{level} * 10;
        % $padding = 100 if $padding > 100;
        <div class="reply" style="padding-left:<%= $padding %>px">

            %== $helpers->displayer->render('include/reply-meta', reply => $reply, thread => $thread);

            <div class="reply-content">
                <%== $helpers->markup->render($reply->{content}) %>
            </div>

            %== $helpers->displayer->render('include/reply-controls', thread => $thread, reply => $reply);
        </div>
    % }
    </div>

    %== $helpers->displayer->render('include/markup-help');
</div>
