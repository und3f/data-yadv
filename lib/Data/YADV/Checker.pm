package Data::YADV::Checker;

use strict;
use warnings;

use Try::Tiny;
use Data::YADV::CheckerASub;

sub new {
    my ($class, $structure, %args) = @_;

    bless {structure => $structure, %args}, $class;
}

sub structure { $_[0]->{structure} }
sub schema { $_[0]->{schema} }

sub get_child {
    my ($self, @path) = @_;

    my $child = try {
        $self->structure->get_child(@path);
    } catch {
        $self->error($_, @path);
    };

    $self->error('element not found', @path) unless defined $child;

    $child;
}

sub check {
    my ($self, $schema, @path) = @_;
    
    $self->schema->check($schema, (@{$self->structure->get_path}, @path));
}

sub check_value {
    my ($self, @path) = @_;
    my $cb = pop @path;

    my $child = $self->get_child(@path) or return;

    $self->schema->build_checker('Data::YADV::CheckerASub', $cb => $child)
      ->verify();
}

sub check_defined {
    my ($self, @path) = @_;

    my $structure = $self->get_child(@path) or return;
    
    if (not defined $structure->get_structure) {
        $self->error('element not defined', @path);
    }
}

sub error {
    my ($self, $message, @path) = @_;

    my $prefix = $self->structure->get_path_string(@path);

    $self->{error_cb}->("\$structure->$prefix", $message);
}

1;
