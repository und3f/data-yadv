package Data::YADV::Structure::Hash;

use strict;
use warnings;

use base 'Data::YADV::Structure::Base';

sub get_child {
    my ($self, @path) = @_;

    return $self unless @path;

    my $structure = $self->get_structure;
    my $entry = shift @path;

    die qq(Wrong hash key format "$entry")
      unless $entry =~ /^\{(.+)\}$/;
    my $key = $1;

    return undef unless exists $structure->{$key};

    $self->_build_node($entry, $structure->{$key})->get_child(@path);
};

sub get_size { keys %{$_[0]->get_structure} }

sub each {
    my ($self, $cb) = @_;

    foreach my $key (keys %{$self->get_structure}) {
        $cb->($self->get_child("{$key}"), $key);
    }
}

1;
