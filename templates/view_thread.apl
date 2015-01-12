% $helpers->assets->require('/js/quick-reply.js');
% $helpers->meta->set(title => $thread->{title});

<div class="grid-100">

    %== $helpers->displayer->render('include/thread', thread => $thread, view => 1);

    % if ($helpers->acl->is_user) {
    %== $helpers->displayer->render('include/thread-controls', thread => $thread);
    % }

    <div class="thread-similar">
    % my @similar = $helpers->thread->similar($thread);
    % if (@similar) {
        <strong><%= loc('Similar threads') %></strong>
    <ul>
    % foreach my $similar_thread (@similar) {
        <li><a href=""><%= $similar_thread->{title} %></a></li>
    % }
    </ul>
    % }
    </div>

    <div class="replies">
    % foreach my $reply ($helpers->reply->find_by_thread($thread)) {
        <div class="grid-container grid-parent">
        <div class="grid-5 mobile-grid-10 grid-parent">

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


        </div>
        <div class="grid-95 mobile-grid-80 grid-parent">

        % my $padding = $reply->{level} * 40 + 10;
        % $padding = 100 if $padding > 100;
        <div class="reply" style="margin-left:<%= $padding %>px">

            %== $helpers->displayer->render('include/reply-meta', reply => $reply, thread => $thread);
            <div class="reply-content">
                <%== $helpers->markup->render($reply->{content}) %>
            </div>

            %== $helpers->displayer->render('include/reply-controls', thread => $thread, reply => $reply);
        </div>

        </div>
        </div>
    % }
    </div>

    % if ($helpers->acl->is_anon) {
    <div class="not-user-notice">
        <%== loc('To reply to this thread login or register') %>.

        <div>
            <a href="<%= $helpers->url->login %>"><%= loc('Login') %></a> <%= loc('or') %> <a href="<%= $helpers->url->register %>"><%= loc('Sign up') %></a>
        </div>

    </div>
    % }

    %== $helpers->displayer->render('include/markup-help');
</div>
