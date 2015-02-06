package Threads::UserLoader;

use strict;
use warnings;

use Threads::DB::User;
use Threads::DB::Nonce;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{finalize} = $params{finalize};
    $self->{finalize} = 1 unless defined $self->{finalize};

    return $self;
}

sub load {
    my $self = shift;
    my ($options) = @_;

    return
      unless my $nonce = Threads::DB::Nonce->new(id => $options->{id})->load;

    my $latest_nonce = Threads::DB::Nonce->find(
        first    => 1,
        where    => [user_id => $nonce->user_id],
        order_by => [id => 'DESC']
    );

    if (time - $nonce->created > 2 && $nonce->id ne $latest_nonce->id) {
        return;
    }

    my $user = Threads::DB::User->new(id => $nonce->user_id)->load;
    return unless $user && $user->status eq 'active';

    return $user;
}

sub finalize {
    my $self = shift;
    my ($options) = @_;

    return unless $self->{finalize};

    my $nonce = Threads::DB::Nonce->new(id => $options->{id})->load;
    return unless $nonce;

    Threads::DB::Nonce->table->delete(
        where => [
            user_id => $nonce->user_id,
            id      => {'!=' => $nonce->id},
            created => {'<' => time - 2}
        ]
    );

    if (time - $nonce->created > 2) {
        my $user_id = $nonce->user_id;
        $nonce->delete;

        my $new_nonce = Threads::DB::Nonce->new(user_id => $user_id)->create;
        $options->{id} = $new_nonce->id;
    }

    return;
}

1;
