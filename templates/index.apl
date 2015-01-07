<div class="grid-100">
    % foreach my $thread ($helpers->thread->find) {

    %== $helpers->displayer->render('include/thread', thread => $thread, quick_reply => 0);

    % }
</div>
