% $helpers->assets->require('/autosize/jquery.autosize.min.js');
% $helpers->assets->require('/js/autosize.js');
% $helpers->assets->require('/js/quick-reply.js');
% $helpers->assets->require('/jquery-ui/jquery-ui.css');
% $helpers->assets->require('/jquery-ui/jquery-ui.min.js');
% $helpers->assets->require('/tagsinput/jquery.tagsinput.css');
% $helpers->assets->require('/tagsinput/jquery.tagsinput.js');
% $helpers->assets->require('/js/tags.js');
% $helpers->meta->set(title => loc('Update thread'));

<div class="grid-100">

    <h1><%= loc('Update thread') %></h1>

    <form method="POST" id="update-thread">

    <%== $helpers->form->input('title', label => loc('Title'), default => $thread->{title}, class => 'input_xlarge') %>
    <%== $helpers->form->input('tags', label => loc('Tags'), help => loc('Comma separated'), default => $thread->{tags_list}) %>

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
                <%== $helpers->form->textarea('content', default => $thread->{content}) %>
            </li>
            <li class="tab-preview" data-post-content=".tab-content textarea" data-post-action="<%= $helpers->url->preview %>">
            </li>
        </ul>

    </div>


    <div class="form-submit">
        <input type="submit" value="<%= loc('Update') %>" />
        %== $helpers->displayer->render('include/markup-help-button');
    </div>

    </form>

    %== $helpers->displayer->render('include/markup-help');

</div>
