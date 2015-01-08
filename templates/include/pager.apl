    % my $pager = $helpers->pager->build(base_url => $base_url, query_params => var('query_params'), total => $total);
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

