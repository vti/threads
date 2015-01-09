            <div class="quick-edit-form">
                <form method="POST" class="ajax" action="<%= $helpers->url->update_reply(id => $reply->{id}) %>">

                <%== $helpers->form->textarea('content', default => $reply->{content}) %>

                <input type="submit" value="<%= loc('Send') %>" /> <em><%= loc('or') %></em> CTRL+Enter

                %== $helpers->displayer->render('include/markup-help-button');

                </form>
            </div>

