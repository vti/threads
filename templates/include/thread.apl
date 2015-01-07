    <div class="thread">
        <div class="thread-header">
            <div class="thread-counters">
            <div class="thread-counters-replies"><%= $thread->{replies_count} %></div>
            <a href="">subscribe</a>
            </div>

            <h1 class="thread-title">
                <a href="<%= $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %>"><%= $thread->{title} %></a>
            </h1>
            <div class="thread-meta">
                by <%= $helpers->user->display_name($thread->{user}) %>
            </div>
            <div class="thread-date"><%= $helpers->date->format($thread->{created}) %></div>

            <div class="clear"></div>
        </div>

        <div class="thread-content">
            <%== $helpers->markdown->render($thread->{content}) %>
        </div>

    </div>
