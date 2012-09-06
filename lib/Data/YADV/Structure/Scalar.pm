package Data::YADV::Structure::Scalar;

use strict;
use warnings;

use base 'Data::YADV::Structure::Base';

sub get_child {
    my ($self, @path) = @_;
    return $self unless @path;

    die "scalar element have no child elements";
}

sub get_size { length $_[0]->get_structure }

1;
