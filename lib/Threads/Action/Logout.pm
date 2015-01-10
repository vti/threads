package Threads::Action::Logout;

use strict;
use warnings;

use parent 'Tu::Action';

use Threads::DB::Nonce;

sub run {
    my $self = shift;

    my $auth = $self->scope->auth;

    Threads::DB::Nonce->table->delete(
        where => [id => $auth->session($self->env)->{id}]);

    $auth->logout($self->env);

    return $self->redirect('index');
}

1;
