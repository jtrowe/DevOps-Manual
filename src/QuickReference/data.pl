
use strict;
use warnings;

use Data::Printer;
use YAML qw( Dump );

$YAML::CompressSeries = 0;

my @data = (
    {
        name => 'Generic',
        references => [
            {
                name => 'AsciiDoc',
                url => 'https://asciidoc-py.github.io/',
            },
            {
                name => 'AsciiDoc User Guide',
                url => 'https://asciidoc-py.github.io/userguide.html',
            },
        ],
    },
    {
        name => 'Perl',
        references => [ qw(
            App::cpanminus
            Dist-Zilla
            Moose
            Template
            YAML
        ) ],
    },
);

my $stash = {};
my @category_names;
my %categories;

foreach my $cat ( @data ) {
    my $cat_name = $cat->{name};

    push @category_names, $cat_name;

    my @items;
    foreach my $ref ( @{ $cat->{references} } ) {
        if ( 'Perl' eq $cat_name ) {
            push @items, {
                name => sprintf('%s @ MetaCPAN', $ref),
                url => sprintf('http://metacpan.org/pod/%s', $ref),
            };
        }
        else {
            push @items, $ref;
        }
    }

    @items = sort { $a->{name} cmp $b->{name} } @items;
    $cat->{references} = \@items;
    $categories{$cat_name} = $cat;
}

$stash->{_category_names} = [ sort @category_names ];
$stash->{_categories} = \%categories;

print Dump($stash) . "\n";

print STDERR "stash:\n" . np($stash) . "\n";

