package Threads::Action::Register::FakeField;

use strict;
use warnings;

use parent 'Tu::Observer::Base';

sub _init {
    my $self = shift;

    $self->_register(
        'AFTER:build_validator' => sub {
            my $self = shift;
            my ($validator) = @_;

            $validator->add_optional_field('website');
            $validator->add_rule('website', 'FakeField');
        }
    );
}

1;
