package Mojo::Collection;
use Mojo::Base -base;
use overload
  'bool'   => sub {1},
  '""'     => sub { shift->join("\n") },
  fallback => 1;

use Mojo::ByteStream;

sub import {
  my $class = shift;
  return unless @_ > 0;
  no strict 'refs';
  no warnings 'redefine';
  my $caller = caller;
  *{"${caller}::c"} = sub { $class->new(@_) };
}

sub new {
  my $class = shift;
  bless [@_], ref $class || $class;
}

sub each {
  my ($self, $cb) = @_;
  return @$self unless $cb;
  my $i = 1;
  $_->$cb($i++) for @$self;
  return $self;
}

# "All right, let's not panic.
#  I'll make the money by selling one of my livers.
#  I can get by with one."
sub grep {
  my ($self, $cb) = @_;
  return $self->new(grep { $_->$cb } @$self);
}

sub join {
  my ($self, $chunk) = @_;
  return Mojo::ByteStream->new(join $chunk, map({"$_"} @$self));
}

sub map {
  my ($self, $cb) = @_;
  return $self->new(map { $_->$cb } @$self);
}

sub size { scalar @{$_[0]} }

1;
__END__

=head1 NAME

Mojo::Collection - Collection

=head1 SYNOPSIS

  # Manipulate collections
  use Mojo::Collection;
  my $collection = Mojo::Collection->new(qw/just works/);
  $collection->map(sub { ucfirst })->each(sub {
    my ($word, $count) = @_;
    print "$count: $word\n";
  });

  # Use the alternative constructor
  use Mojo::Collection 'c';
  c(qw/a b c/)->join('/')->url_escape->say;

=head1 DESCRIPTION

L<Mojo::Collection> is a container for collections.
Note that this module is EXPERIMENTAL and might change without warning!

=head1 METHODS

L<Mojo::Collection> inherits all methods from L<Mojo::Base> and implements
the following new ones.

=head2 C<new>

  my $collection = Mojo::Collection->new(1, 2, 3);

Construct a new L<Mojo::Collection> object.

=head2 C<each>

  my @elements = $collection->each;
  $collection  = $collection->each(sub {...});

Evaluate closure for each element in collection.

  $collection->each(sub {
    my ($e, $count) = @_;
    print "$count: $e\n";
  });

=head2 C<grep>

  my $new = $collection->grep(sub {...});

Evaluate closure for each element in collection and create a new collection
with all elements for which the closure returned true.

  my $fiveplus = $collection->grep(sub { $_ >= 5 });

=head2 C<join>

  my $stream = $collection->join("\n");

Turn collection into L<Mojo::ByteStream>.

  $collection->join("\n")->say;

=head2 C<map>

  my $new = $collection->map(sub {...});

Evaluate closure for each element in collection and create a new collection
from the results.

  my $doubled = $collection->map(sub { $_ * 2 });

=head2 C<size>

  my $size = $collection->size;

Number of elements in collection.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
