            <div class="quick-reply-form">
                <form method="POST" action="<%= $helpers->url->create_reply(id => $thread->{id}) %>">

                % if (my $reply = var('reply')) {
                    <input type="hidden" name="to" value="<%= $reply->{id} %>" />
                % }

                <%== $helpers->form->textarea('content') %>

                <input type="submit" name="reply" value="<%= loc('Send') %>" /> <em><%= loc('or') %></em> CTRL+Enter

                (<a href="#" class="markup-help-button"><%= loc('markup help') %></a>)

                <div class="markup-help"></div>

                </form>
            </div>

