#!/usr/bin/env perl

use strict;
use warnings;

use Test::Spec;
use Data::YADV::Structure;

describe 'Data::YADV::Structure' => sub {
    my $structure;

    before each => sub {
        $structure = Data::YADV::Structure->new(
            [{key1 => {key2 => ['array1', 'array2']}}, 'scalar1']);
    };

    it 'should return child element' => sub {
        is $structure->get_child(qw([0] {key1} {key2} [1]))->get_structure,
          'array2';
    };

    it 'should return undef if path not exists' => sub {
        is $structure->get_child('[2]'), undef;
        is $structure->get_child(qw([0] {key3})), undef;
    };

    it 'should return stringified path' => sub {
        is $structure->get_child(qw([0] {key1}))->get_path_string(qw({key2} [1])),
          '[0]->{key1}->{key2}->[1]';
    };

    it 'should return parent node' => sub {
        is $structure->get_child(qw([0] {key1}))
          ->get_parent->get_parent, $structure;
      }
};

runtests unless caller;
