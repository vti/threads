% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    <div class="index-sorting">

        <%= loc('Sort') %>
        <form class="form-inline">
        <%== $helpers->form->select('by', options => [activity => loc('by activity'), popularity => loc('by popularity')]) %>
        </form>
    </div>

    <div class="index-stats">
        <i class="fa fa-folder"></i>
        <strong><%= $helpers->thread->count %></strong>

        <i class="fa fa-comment"></i>
        <strong><%= $helpers->reply->count %></strong>

        <i class="fa fa-user"></i>
        <strong><%= $helpers->user->count %></strong>
    </div>

    <div class="clear"></div>

    % foreach my $thread ($helpers->thread->find) {
    %== $helpers->displayer->render('include/thread', thread => $thread);
    % }

    %== $helpers->displayer->render('include/pager', base_url => $helpers->url->index, query_params => ['by', 'user_id'], total => $helpers->thread->count);
</div>
