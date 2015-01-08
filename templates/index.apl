% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    <div class="index-sorting">
        <%= loc('Sort') %>
        <form class="form-inline">
        <%== $helpers->form->select('by', options => [activity => loc('by activity'), popularity => loc('by popularity')]) %>
        </form>
    </div>

    % foreach my $thread ($helpers->thread->find) {
    %== $helpers->displayer->render('include/thread', thread => $thread);
    % }

    % my $pager = $helpers->pager->build(base_url => $helpers->url->index, query_params => ['by'], total => $helpers->thread->count);
    % if (%$pager) {
    <div class="pager">
    % if (my $first_page = $pager->{first_page}) {
        <a href="<%== $pager->{first_page_url} %>" class="button"><i class="fa fa-chevron-left"></i><i class="fa fa-chevron-left"></i></a>
    % } else {
        <button disabled="disabled"><i class="fa fa-chevron-left"></i><i class="fa fa-chevron-left"></i></button>
    % }

    % if (my $prev_page = $pager->{prev_page}) {
        <a href="<%== $pager->{prev_page_url}%>" class="button"><i class="fa fa-chevron-left"></i></a>
    % } else {
        <button disabled="disabled"><i class="fa fa-chevron-left"></i></button>
    % }

    % if (my $next_page = $pager->{next_page}) {
        <a href="<%== $pager->{next_page_url} %>" class="button"><i class="fa fa-chevron-right"></i></a>
    % } else {
        <button disabled="disabled"><i class="fa fa-chevron-right"></i></button>
    % }

    % if (my $last_page = $pager->{last_page}) {
        <a href="<%== $pager->{last_page_url} %>" class="button"><i class="fa fa-chevron-right"></i><i class="fa fa-chevron-right"></i></a>
    % } else {
        <button disabled="disabled"><i class="fa fa-chevron-right"></i><i class="fa fa-chevron-right"></i></button>
    % }
    </div>
    % }
</div>
