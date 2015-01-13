            <div class="quick-edit-form tabs-outer">

                <form method="POST" class="ajax" action="<%= $helpers->url->update_reply(id => $reply->{id}) %>">

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

                    <%== $helpers->form->textarea('content', default => $reply->{content}) %>

                    </li>
                    <li class="tab-preview" data-post-content=".tab-content textarea" data-post-action="<%= $helpers->url->preview %>">
                    </li>
                </ul>

                <input type="submit" value="<%= loc('Save') %>" /> <em><%= loc('or') %></em> CTRL+Enter

                %== $helpers->displayer->render('include/markup-help-button');

                </form>

            </div>

