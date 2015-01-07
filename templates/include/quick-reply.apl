        <div class="quick-reply">
            <div class="quick-reply-button outer">
            <button>+ reply</button>
            </div>
            <div class="inner">
                <form method="POST" action="<%= $helpers->url->create_reply(id => $thread->{id}) %>">

                % if (my $to = var('to')) {
                    <input type="hidden" name="to" value="<%= $to %>" />
                % }

                <%== $helpers->form->textarea('content') %>

                <input type="submit" value="<%= loc('Reply') %>" />

                </form>
            </div>
        </div>

