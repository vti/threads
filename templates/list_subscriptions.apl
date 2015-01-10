% $helpers->assets->require('/js/quick-reply.js');

<div class="grid-100">

    <h1><%= loc('Subscriptions') %></h1>

    % my @subscriptions = $helpers->subscription->find;

    % if (@subscriptions) {
        <p>
        <form class="form-inline ajax" method="POST" action="<%= $helpers->url->delete_subscriptions %>">
        <button><i class="fa fa-remove"></i> <%= loc('delete subscriptions') %></button>
        </form>
        </p>
    % }

    % foreach my $subscription (@subscriptions) {
    %    my $thread = $subscription->{thread};
    %== $helpers->displayer->render('include/thread', thread => $thread, view => 1, no_content => 1);
    <br />
    % }

    %== $helpers->displayer->render('include/pager', base_url => $helpers->url->list_subscriptions, total => $helpers->subscription->count);

</div>
