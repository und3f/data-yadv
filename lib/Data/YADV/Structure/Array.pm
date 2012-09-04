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

1;
