    <div class="thread">
        <div class="thread-header">
            <div class="thread-counters">
            <div class="thread-counters-replies">0</div>
            Views: 567<br />
            <a href="">subscribe</a>
            </div>

            <h1 class="thread-title"><a href="<%= $helpers->url->view_thread(id => $thread->{id}) %>"><%= $thread->{title} %></a></h1>
            <div class="thread-meta">by <%= $thread->{user}->{email} %></div>

            <div class="clear"></div>
        </div>

        <div class="thread-content">
            <%== $helpers->markdown->render($thread->{content}) %>
        </div>

% if ($quick_reply) {
    %== $helpers->displayer->render('include/quick-reply', thread => $thread);
% }
    </div>
