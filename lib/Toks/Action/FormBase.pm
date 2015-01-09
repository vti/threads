package Toks::Action::FormBase;

use strict;
use warnings;

use parent 'Tu::Action';

use Tu::Validator;
use Tu::Action::FormMixin 'validate_or_submit';
use Toks::Action::TranslateMixin 'loc';

sub build_validator {
    my $self = shift;

    return Tu::Validator->new(
        namespaces => ['Toks::Validator::', 'Tu::Validator::'],
        messages   => {
            REQUIRED  => $self->loc('Required'),
            EMAIL     => $self->loc('Invalid email'),
            COMPARE   => $self->loc('Password mismatch'),
            READABLE  => $self->loc('Not readable'),
            MINLENGTH => $self->loc('Too short'),
            MAXLENGTH => $self->loc('Too long'),
            NOTDISPOSABLEEMAIL =>
              $self->loc('Disposable emails are not allowed'),
        },
        @_
    );
}

sub submit { }

sub run { shift->validate_or_submit }

1;
