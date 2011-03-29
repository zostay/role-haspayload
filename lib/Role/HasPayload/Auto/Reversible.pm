package Role::HasPayload::Auto::Reversible;
use Moose::Role;
# ABSTRACT: automatically computes payload based on attributes, but settable

use Scalar::Util ();

with qw(Role::HasPayload::Auto);

=head1 SYNOPSIS

  package Example;
  use Moose;

  with qw(Role::HasPayload::Auto::Reversible);

  has height => (
    is => 'ro',
    traits => [ Payload ],
  );
   
  has width => (
    is => 'ro',
    traits   => [ Payload ],
  );

  has color => (
    is => 'ro',
  );

...then...

  my $example = Example->new({
    height => 10,
    width  => 20,
    color  => 'blue',
  });

  $example->payload; # { height => 10, width => 20 }

  $example->payload({ height => 30, width => 50 });

  $example->height; # height => 30
  $example->width;  # width  => 50

=head1 DESCRIPTION

This is just like L<Role::HasPayload::Auto>, except that the single method, C<payload>, can now be used as a setter. It will set any attributes with a name matching a key in the hash. It is not strict, so passing extra keys that have no matching attribute will only cause a warning.

=cut

use Role::HasPayload::Meta::Attribute::Payload;

before payload => sub {
    my $self = shift;

    # If nothing is passed, do nothing...
    return unless @_;

    Carp::croak("only a single HASH parameter may be passed to this method")
        if @_ != 1 or Scalar::Util::reftype($_[0]) ne 'HASH';

    my %payload = %{ $_[0] };
    KEY: for my $key (keys %payload) {
        my $attr = $self->meta->find_attribute_by_name($key);

        unless ($attr) {
            Carp::carp("no such attribute as $key while setting payload");
            next KEY;
        }

        unless ($attr->does('Role::HasPayload::Meta::Attribute::Payload')) {
            Carp::carp("declining to set non-payload attribute $key");
            next KEY;
        }

        my $method = $attr->get_write_method;
        $self->$method($payload{ $key });
    }
};

no Moose::Role;
1;
