package Threads::Action::FormBase;

use strict;
use warnings;

use parent 'Threads::Action';

use Tu::Validator;
use Tu::Action::FormMixin 'validate_or_submit';
use Threads::Action::TranslateMixin 'loc';

sub build_validator {
    my $self = shift;

    return Tu::Validator->new(
        namespaces => ['Threads::Validator::', 'Tu::Validator::'],
        messages   => {
            REQUIRED  => $self->loc('Required'),
            EMAIL     => $self->loc('Invalid email'),
            COMPARE   => $self->loc('Password mismatch'),
            READABLE  => $self->loc('Not readable'),
            MINLENGTH => $self->loc('Too short'),
            MAXLENGTH => $self->loc('Too long'),
            TAGS      => $self->loc('Wrong tags'),
            NOTDISPOSABLEEMAIL =>
              $self->loc('Disposable emails are not allowed'),
        },
        @_
    );
}

sub show        { }
sub show_errors { }
sub submit      { }

sub run { shift->validate_or_submit }

1;
