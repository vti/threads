        <div class="quick-reply">
            <div class="quick-reply-button outer">
            % if (var('to')) {
            <button>↳ reply</button>
            % } else {
            <button>reply to thread</button>
            % }
            </div>
            <div class="inner">
                <form method="POST" action="<%= $helpers->url->create_reply(id => $thread->{id}) %>">

                % if (my $to = var('to')) {
                    <input type="hidden" name="to" value="<%= $to %>" />
                % }

                <%== $helpers->form->textarea('content') %>

                <div><a href="http://en.wikipedia.org/wiki/Markdown">Markdown</a></div>

                <button class="quick-reply-close"><%= loc('Close') %></button>
                <input type="submit" value="<%= loc('Reply') %>" />

                </form>
            </div>
        </div>

