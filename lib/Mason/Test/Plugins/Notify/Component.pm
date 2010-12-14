package Mason::Test::Plugins::Notify::Component;
use Moose::Role;
use strict;
use warnings;

before 'render' => sub {
    my ($self) = @_;
    print STDERR "starting component render - " . $self->comp_path . "\n";
};

1;
