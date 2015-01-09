            <div class="quick-reply-form">
                <form method="POST" class="ajax" action="<%= $helpers->url->create_reply(id => $thread->{id}) %>">

                % if (my $reply = var('reply')) {
                    <input type="hidden" name="to" value="<%= $reply->{id} %>" />
                % }

                <%== $helpers->form->textarea('content') %>

                <input type="submit" name="reply" value="<%= loc('Send') %>" /> <em><%= loc('or') %></em> CTRL+Enter

                %== $helpers->displayer->render('include/markup-help-button');

                </form>
            </div>

