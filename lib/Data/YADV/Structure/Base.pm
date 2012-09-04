package Data::YADV::Structure::Base;

use strict;
use warnings;

use Data::YADV::Structure;

sub new {
    my ($class, $structure, $path, $parent) = @_;

    bless {
        structure => $structure,
        path      => $path || [],
        parent    => $parent
    }, $class;
}

sub get_structure { $_[0]->{structure} }
sub get_parent { $_[0]->{parent} }
sub get_path { $_[0]->{path} }

sub get_path_string {
    my ($self, @path) = @_;
    _stringify_path(@{$self->{path}}, @path);
}

sub _build_node {
    my ($self, $path, $value) = @_;

    Data::YADV::Structure->new($value, [@{$self->{path}}, $path], $self);
}

sub _stringify_path {
    join '->', @_;
}

sub die {
    my ($self, $message, $path) = @_;

    my @path = @{$self->{path}};
    push @path, $path if defined $path;

    die _stringify_path('$structure', @path) . ': ' .$message;
}

1;
