use strict;
use warnings;
use Pod::Select 'podselect';

print "Generating README.pod\n";

podselect {-output => 'README.pod'}, 'lib/SkewHeap.pm';

exit 0;
