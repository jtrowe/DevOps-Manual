
use strict;
use warnings;

use Data::Printer;
use Log::Log4perl qw( :easy get_logger );
use YAML qw( Dump LoadFile );

$YAML::CompressSeries = 0;

Log::Log4perl->easy_init($DEBUG);
my $log = get_logger('data.pl');

my $data_file = shift @ARGV;

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

my @perl_packages = qw(
    App::cpanminus
    Dist-Zilla
    Moose
    Template
    YAML
);

foreach my $package ( @perl_packages ) {
    push @data, {
        category => [ 'Perl' ],
        name => $package,
        url => '@',
    },
}

$log->info("middle:\n" . Dump(\@data));

my $d = LoadFile($data_file);
@data = @{ $d };

#@data = sort { $a->{name} cmp $b->{name} } @data;
@data = sort cmp_data @data;

$log->info("middle2:\n" . Dump(\@data));

foreach my $info ( @data ) {
    if ( 'Perl' eq $info->{category}->[0] ) {
        $info->{url} = sprintf('http://metacpan.org/pod/%s', $info->{name});
        $info->{name} = sprintf('%s @ MetaCPAN', $info->{name});
    }
}

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

#sort_struct($root);

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
            level    => scalar(@path),
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


sub cmp_data {
    my $cat_a = join '/', @{ $a->{category} // [] };
    my $cat_b = join '/', @{ $b->{category} // [] };

    my $rv = $cat_a cmp $cat_b;

    if ( 0 == $rv ) {
        return $a->{name} cmp $b->{name};
    }

    return $rv;
}


