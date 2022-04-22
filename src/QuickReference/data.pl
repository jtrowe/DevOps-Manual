
use strict;
use warnings;

use Data::Printer;
use Log::Log4perl qw( :easy get_logger );
use YAML qw( Dump );

$YAML::CompressSeries = 0;

Log::Log4perl->easy_init($DEBUG);
my $log = get_logger('data.pl');


my @data = (
    {
        category => [ 'AsciiDoc' ],
        name => 'AsciiDoc Home Page',
        url => 'https://asciidoc-py.github.io/',
    },
    {
        category => [ 'AsciiDoc' ],
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

my $cache = {
    '_' => { name => 'root', }, # root
};
my $root = $cache->{_};
my $stash = { links => $root };
my @category_names;
my %categories;

foreach my $link ( @data ) {
    my $link_name = $link->{name};

    my $cat = get_cat($cache, $link->{category});

    my $items = $cat->{items} //= [];

    my $cat_name = $cat->{name};

    delete $link->{category};
    push @{ $items }, $link;

}

$stash = $root;


print Dump($stash) . "\n";

$log->info("stash:\n" . np($stash));


sub get_cat {
    my $c = shift;
    my $i = shift;

    my @path = @{ $i };
    my $path = join '/', @path;

    unless ( @path ) {
        return $c->{_};
    }

    my @par = @{ \@path };
    pop @par;
    my $par_path = join '/', @par;
    #$log->debug("get_node: path=$path ; par_path=$par_path");
    my $parent = get_cat($c, \@par);

    my $n = $c->{$path};
    unless ( $n ) {
        my @par = @{ \@path };
        pop @par;

        $n = $c->{$path} = {
            category => $path[-1],
            parent => $parent,
            items => [],
        };
        if ( $parent ) {
            push @{ $parent->{items} //= [] }, $n;
        }
    }

    #$log->debug("get_node: path=$path ; return " . np($n));

    return $n;
}

