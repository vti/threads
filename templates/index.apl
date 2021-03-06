% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    <div class="index-sorting">
        <%= loc('Sort') %>
        <form class="form-inline">
        <%== $helpers->form->input('q', type => 'hidden', value => $params->{q}) %>
        <%== $helpers->form->select('by', options => [activity => loc('by activity'), popularity => loc('by popularity')]) %>
        </form>

        <a href="<%= $helpers->url->threads_rss %><%= var('params')->{tag} ? "?tag=$params->{tag}" : '' %>"><img src="/images/rss.png" /></a>
    </div>

    <div class="index-search">
        <form class="form-inline">
        <%== $helpers->form->input('q', class => 'input_xlarge') %>
        <button type="submit"><%= loc('Search') %></button>
        </form>
    </div>

    <div class="index-stats">
        <i class="fa fa-folder"></i>
        <strong><%= $helpers->thread->count %></strong>

        <i class="fa fa-comment"></i>
        <strong><%= $helpers->reply->count %></strong>

        <i class="fa fa-users"></i>
        <strong><%= $helpers->user->count %></strong>
    </div>

    <div class="clear"></div>

    % foreach my $thread ($helpers->thread->find) {
    %== $helpers->displayer->render('include/thread', thread => $thread);
    % }

    %== $helpers->displayer->render('include/pager', base_url => $helpers->url->index, query_params => ['q', 'by', 'user_id', 'tag'], total => $helpers->thread->count);
</div>
