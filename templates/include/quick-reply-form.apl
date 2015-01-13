            <div class="quick-reply-form tabs-outer">

                <form method="POST" class="ajax" action="<%= $helpers->url->create_reply(id => $thread->{id}) %>">

                <ul class="tabs-topics">
                    <li class="active">
                        <a href="#" class="topic" name="tab-content">
                        <%= loc('Content') %>
                        </a>
                    </li>
                    <li>
                        <a href="#" class="topic" name="tab-preview">
                        <%= loc('Preview') %>
                        </a>
                    </li>
                </ul>

                <ul class="tabs-content">
                    <li class="active tab-content">

                        % if (my $reply = var('reply')) {
                            <input type="hidden" name="to" value="<%= $reply->{id} %>" />
                        % }

                        <%== $helpers->form->textarea('content') %>

                    </li>
                    <li class="tab-preview" data-post-content=".tab-content textarea" data-post-action="<%= $helpers->url->preview %>">
                    </li>
                </ul>

                    <input type="submit" name="reply" value="<%= loc('Send') %>" /> <em><%= loc('or') %></em> CTRL+Enter

                    %== $helpers->displayer->render('include/markup-help-button');

                </form>

            </div>

