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

sub check_each {
    my ($self, @path) = @_;
    my $schema = pop @path;

    my $node = $self->get_child(@path) or return;

    return $self->error($node->get_type . ' is not iterable', @path)
      unless $node->can('each');

    my $factory = $self->_checker_factory($schema);
    $node->each(
        sub {
            my ($node, $key) = @_;
            $factory->($node)->verify($key);
        }
    );
}

sub _checker_factory {
    my ($self, $schema) = @_;

    if (ref $schema eq 'CODE') {
        return sub {
            $self->schema->build_checker('Data::YADV::CheckerASub', $schema,
                @_);
          }
    }

    return sub {
        my $module = $self->schema->schema_to_module($schema);
        $self->schema->build_checker($module, @_);
    };
}

sub error {
    my ($self, $message, @path) = @_;

    my $prefix = $self->structure->get_path_string(@path);
    $prefix = '$structure' . ($prefix ? '->' : '') . $prefix;

    $self->{error_cb}->($prefix, $message);
}

1;
