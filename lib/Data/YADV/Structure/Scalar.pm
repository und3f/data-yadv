package Data::YADV::Structure::Scalar;

use strict;
use warnings;

use base 'Data::YADV::Structure::Base';

sub get_child {
    my ($self, @path) = @_;
    return $self unless @path;

    die "scalar element have no child elements";
}

1;
