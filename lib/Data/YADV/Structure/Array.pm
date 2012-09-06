package Data::YADV::Structure::Array;

use strict;
use warnings;

use base 'Data::YADV::Structure::Base';

sub get_child {
    my ($self, @path) = @_;

    return $self unless @path;

    my $structure = $self->get_structure;
    my $entry = shift @path;

    $self->die(qq(Wrong array index), $entry) unless $entry =~ /^\[(.+)\]$/;
    my $index = $1;

    return undef unless $index >= 0 && $index < scalar @$structure;

    $self->_build_node($entry, $structure->[$index])->get_child(@path);
};

sub get_size { scalar @{$_[0]->get_structure} }

sub each {
    my ($self, $cb) = @_;

    my $size = $self->get_size;
    for (my $i = 0; $i < $size; ++$i) {
        $cb->($self->get_child("[$i]"), $i);
    }
}

1;
