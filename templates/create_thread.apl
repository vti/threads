% $helpers->assets->require('/autosize/jquery.autosize.min.js');
% $helpers->assets->require('/js/autosize.js');
% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    <h1><%= loc('Create thread') %></h1>

    <form method="POST" id="create-thread">

    <%== $helpers->form->input('title', label => loc('Title')) %>
    <%== $helpers->form->textarea('content', label => loc('Content')) %>

    <input type="submit" value="<%= loc('Create new thread') %>" />

    (<a href="#" class="markup-help-button"><%= loc('markup help') %></a>)

    <div class="markup-help"></div>

    </form>

    %== $helpers->displayer->render('include/markup-help');

</div>
