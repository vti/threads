<div class="grid-100">

    <div>Sort by activity</div>

    % foreach my $thread ($helpers->thread->find) {
    %== $helpers->displayer->render('include/thread', thread => $thread);
    % }
</div>
