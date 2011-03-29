use strict;
use warnings;

use Test::More;

{
  package Some::Carrier;
  use Moose;

  with 'Role::HasPayload::Auto::Reversible';

  has size => (
    is   => 'rw',
    isa  => 'Int',
    lazy => 1,
    traits  => [ 'Role::HasPayload::Meta::Attribute::Payload' ],
    default => 36,
  );

  has private_thing => (
    is      => 'rw',
    isa     => 'Int',
    default => 13,
  );
}

{
  my $obj = Some::Carrier->new;

  isa_ok($obj, 'Some::Carrier', 'we got our object');

  is_deeply(
    $obj->payload,
    {
      size => 36,
    },
    "...and the payload is correct",
  );

  $obj->payload({ size => 42, private_thing => 55 });

  is($obj->size, 42, 'payload set size');
  is($obj->private_thing, 13, 'payload does not set private_thing');

  is_deeply(
    $obj->payload,
    {
      size => 42,
    },
    "...and the payload is still correct",
  );
}

done_testing;
