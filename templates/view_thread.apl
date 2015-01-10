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

    % if (!var('user')) {
    <div class="not-user-notice">
        <%== loc('To reply to this thread login or register') %>.

        <div>
            <a href="<%= $helpers->url->login %>"><%= loc('Login') %></a> <%= loc('or') %> <a href="<%= $helpers->url->register %>"><%= loc('Sign up') %></a>
        </div>

    </div>
    % }

    %== $helpers->displayer->render('include/markup-help');
</div>
