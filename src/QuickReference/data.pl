
use strict;
use warnings;

use Data::Printer;
use YAML qw( Dump );

$YAML::CompressSeries = 0;

my %data = (
    Generic => [
        {
            name => 'AsciiDoc',
            url => 'https://asciidoc-py.github.io/',
        },
        {
            name => 'AsciiDoc User Guide',
            url => 'https://asciidoc-py.github.io/userguide.html',
        },
    ],
    Perl => [ qw(
        App::cpanminus
        Dist-Zilla
        Moose
        Template
        YAML
    ) ],
);

my $stash = {};

foreach my $cat ( keys %data ) {
    my @items;

    if ( 'Perl' eq $cat ) {
        foreach my $package ( @{ $data{$cat} } ) {
            push @items, {
                name => sprintf('%s @ MetaCPAN', $package),
                url => sprintf('http://metacpan.org/pod/%s', $package),
            };
        }
    }
    else {
        foreach my $ref ( @{ $data{$cat} } ) {
            push @items, $ref;
        }
    }

    @items = sort { $a->{name} cmp $b->{name} } @items;
    $stash->{$cat} = \@items;
}

print Dump($stash) . "\n";

print STDERR "stash:\n" . np($stash) . "\n";

