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
</div>
