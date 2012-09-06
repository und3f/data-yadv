#!/usr/bin/env perl

use strict;
use warnings;

use Test::Spec;
use Data::YADV;

describe 'Data::YADV' => sub {
    my @errors;
    my $error_handler = sub {
        push @errors, [@_];
    };
    my @opts = (error_handler => $error_handler);

    before each => sub {
        @errors = ();
    };

    describe 'check_defined' => sub {
        it "should pass with correct data" => sub {
            Data::YADV->new({key => 'ok'}, @opts)->check('check_defined');
            ok !@errors;
        };

        it "should fail on undefined element" => sub {
            Data::YADV->new({key => undef}, @opts)->check('check_defined');
            is @errors, 1;
            my ($path, $message) = @{pop @errors};

            is $path,    '$structure->{key}';
            is $message, 'element not defined';
        };

        it "should fail on non existence element" => sub {
            Data::YADV->new({}, @opts)->check('check_defined');
            is @errors, 1;
            my ($path, $message) = @{pop @errors};

            is $path,    '$structure->{key}';
            is $message, 'element not found';
        };
    };

    describe "check_value" => sub {
        it "should call proper callback" => sub {
            Data::YADV->new({result => 'secret'}, @opts)
              ->check('check_value');

            is @errors, 1;
            my ($path, $message) = @{pop @errors};
            is $path,    '$structure->{result}';
            is $message, 'secret';
        };
    };


    describe "check" => sub {
        it "should check schema" => sub {
            Data::YADV->new([{key => 'ok'}, {result => 'another secret'}],
                @opts)->check('check');

            is @errors, 1;
            my ($path, $message) = @{pop @errors};

            is $path,    '$structure->[1]->{result}';
            is $message, 'another secret';
        };
    };
};

runtests unless caller;

{

    package Schema::CheckDefined;
    use base 'Data::YADV::Checker';

    sub verify {
        my $self = shift;

        $self->check_defined('{key}');
    }
};

{

    package Schema::CheckValue;
    use base 'Data::YADV::Checker';

    sub verify {
        my $self = shift;

        $self->check_value(
            '{result}' => sub {
                my ($self, $value) = @_;

                $self->error($value);
            }
        );
    }
}

{

    package Schema::Check;
    use base 'Data::YADV::Checker';

    sub verify {
        my $self = shift;

        $self->check(check_defined => '[0]');
        $self->check(check_value   => '[1]');
    }
}
