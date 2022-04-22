
use strict;
use warnings;

use Data::Printer;
use YAML qw( Dump );

$YAML::CompressSeries = 0;


my @data = (
    {
        category => [ 'Document Tools', 'AsciiDoc' ],
        name => 'AsciiDoc Home Page',
        url => 'https://asciidoc-py.github.io/',
    },
    {
        category => [ 'Document Tools', 'AsciiDoc' ],
        name => 'AsciiDoc User Guide',
        url => 'https://asciidoc-py.github.io/userguide.html',
    },
);

my @data1 = (
    {
        name => 'AsciiDoc',
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

my $root = get_cat(undef, '');
my $stash = { links => $root };
my @category_names;
my %categories;

foreach my $link ( @data ) {
    my $link_name = $link->{name};

    my $cat = get_cat( @{ $link->{categories} } );

#FIXME for dev
    $cat = $root;
    my $items = $cat->{items} //= [];

    my $cat_name = $cat->{name};

#    push @category_names, $cat_name;

    #my @items;
#    if ( 'Perl' eq $cat_name ) {
#        push @items, {
#            name => sprintf('%s @ MetaCPAN', $link_name),
#            url => sprintf('http://metacpan.org/pod/%s', $link_name),
#        };
#    }
#    else {
        push @{ $items }, $link;
#    }

    #@items = sort { $a->{name} cmp $b->{name} } @items;
    #$cat->{references} = \@items;
    #$categories{$cat_name} = $cat;
}

#$stash->{_category_names} = [ sort @category_names ];
#$stash->{_categories} = \%categories;

$stash->{links} = $root;

print Dump($stash) . "\n";

print STDERR "stash:\n" . np($stash) . "\n";


sub get_cat {
    my $parent = shift;
    my @name   = @_;

    my $path = join '/', @name;

    if ( ! exists($categories{$path}) ) {
        $categories{$path} = {
            name  => $name[-1],
            level => ( $parent ? ( $parent->{level} + 1 ) : 0 ),
        };
    }

    return $categories{$path};
}

