            <div class="quick-edit-form">
                <form method="POST" action="<%= $helpers->url->update_reply(id => $reply->{id}) %>">

                <%== $helpers->form->textarea('content', default => $reply->{content}) %>

                <input type="submit" value="<%= loc('Send') %>" /> <em>or</em> CTRL+Enter

                (<a href="http://en.wikipedia.org/wiki/Markdown">Markdown</a>)

                </form>
            </div>

