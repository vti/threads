% $helpers->assets->require('/autosize/jquery.autosize.min.js');
% $helpers->assets->require('/js/autosize.js');
% $helpers->assets->require('/js/quick-reply.js');
% $helpers->meta->set(title => loc('Create thread'));

<div class="grid-100">

    <h1><%= loc('Create thread') %></h1>

    <form method="POST" id="create-thread">

    <%== $helpers->form->input('title', label => loc('Title')) %>
    <%== $helpers->form->input('tags', label => loc('Tags'), help => loc('Comma separated')) %>

    <div class="tabs-outer">
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
                <%== $helpers->form->textarea('content') %>
            </li>
            <li class="tab-preview" data-post-content=".tab-content textarea" data-post-action="<%= $helpers->url->preview %>">
            </li>
        </ul>

    </div>

    <div class="form-submit">
        <input type="submit" value="<%= loc('Create new thread') %>" />
        %== $helpers->displayer->render('include/markup-help-button');
    </div>

    </form>

    %== $helpers->displayer->render('include/markup-help');

</div>
