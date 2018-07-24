use ExtUtils::testlib;
use Test2::V0;
use Test::LeakTrace qw(no_leaks_ok);
use List::Util qw(shuffle);
use SkewHeap;

my $cmp = sub{ $a <=> $b };
my @values = 0 .. 20;
my @shuffled = shuffle @values;

subtest 'basics' => sub{
  ok(SkewHeap->new($cmp), 'ctor');
  ok(SkewHeap->new(sub{ $a <=> $b }), 'ctor w/ anon sub');

  ok my $heap = skewheap{ $a <=> $b }, 'sugar ctor';

  is $heap->put(@shuffled), scalar(@shuffled), "put";

  foreach my $v (@values) {
    is my $got = $heap->take, $v, "take $v";

    if ($heap->size == 0) {
      is $heap->top, U, 'top';
    } else {
      ok $got < $heap->top, 'top';
    }
  }
};

subtest 'merge' => sub{
  my $h1 = SkewHeap->new($cmp);
  my $h2 = SkewHeap->new($cmp);

  foreach (1 .. 10) {
    if ($_ % 2 == 0) {
      $h1->put($_);
    } else {
      $h2->put($_);
    }
  }

  is $h1->merge($h2), 10, 'merge';
  is $h1->size, 10, 'size';

  foreach my $i (1 .. 10) {
    is $h1->take, $i, "take $i";
  }

  is $h2->size, 0, 'merged heap is empty';
};

subtest 'leaks' => sub{
  no_leaks_ok { my $heap = SkewHeap->new($cmp) } 'ctor';

  no_leaks_ok {
    my $heap = SkewHeap->new($cmp);
    $heap->put(@shuffled);
  } 'put';

  no_leaks_ok {
    my $heap = SkewHeap->new($cmp);
    $heap->put(@shuffled);
    local $_ = $heap->take while $heap->size > 0;
  } 'take';

  no_leaks_ok {
    my $heap = SkewHeap->new($cmp);
    $heap->put(42);
    my $v = $heap->top;
  } 'top';

  no_leaks_ok {
    my $heap = SkewHeap->new($cmp);
    $heap->put(42);
    my $i = $heap->size;
  } 'size';

  no_leaks_ok {
    my $heap = skewheap{ $a <=> $b };
    $heap->put(@shuffled);

    foreach (@shuffled) {
      my $item = $heap->take;
      my $top  = $heap->top;
      my $size = $heap->size;
    }
  } 'combined';
};

done_testing;
