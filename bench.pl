#!/usr/bin/perl
use strict;
use warnings;

use Benchmark ':hireswallclock';
use CGI::Deurl 'NOTCGI';
use CGI::Deurl::XS qw/parse_query_string parse_decode_query_string/;

use open qw/ :std :utf8 /;

use Data::Dumper;
use YAML::Syck;

#use encoding 'utf8';

my @chars = ('A'..'Z', 'a'..'z', '+');
sub spew { return join '', map { $chars[rand @chars] } 1..shift }

#my $string = shift || 'foo=bar';
my %stuff = (
    'foo' =>  'bar',
    'blah' => 'baz',
    'eep'  => 'anima',
    spew(5) => spew(10000),
);
my $simple = 'f=1';
my $random = join '&', map { "$_=$stuff{$_}" } keys %stuff;
my $russian = 'http://ads1.dev.sixapart.com/js/?p=lj&id=id&f=insertAd&country=&width=160&language=en&interests=%D0%BC%D1%83%D0%B7%D1%8B%D0%BA%D0%B0,madonna,%D0%BD%D0%BE%D1%87%D1%8C,80%27s,%D1%81%D0%BD%D1%8B,%D0%B4%D0%B8%D0%B7%D0%B0%D0%B9%D0%BD,%D0%BB%D1%8E%D0%B4%D0%B8,%D1%8E%D0%BC%D0%BE%D1%80,%D0%B4%D0%B5%D0%BD%D1%8C%D0%B3%D0%B8,%D1%80%D0%B5%D0%BA%D0%BB%D0%B0%D0%BC%D0%B0,%D0%BB%D1%83%D0%BD%D0%B0,skin,%D1%81%D0%B2%D0%B5%D1%87%D0%B8,abba,%D0%B3%D0%BB%D0%B8%D0%BD%D1%82%D0%B2%D0%B5%D0%B9%D0%BD,%D0%B9%D0%BE%D0%B3%D0%B0,%D0%BC%D0%B5%D1%87%D1%82%D1%8B,%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%B8%D0%B2,%D0%B4%D0%B6%D0%B8%D0%BD%D1%81%D1%8B,%D0%B7%D0%B0%D0%BF%D0%B0%D1%85%D0%B8,%D0%9A%D0%92%D0%9D,%D0%BB%D0%B5%D0%BD%D1%8C,%D0%BA%D0%BE%D1%82%D1%8B,%D0%B3%D0%B0%D1%80%D0%BC%D0%BE%D0%BD%D0%B8%D1%8F,%D1%8F%D0%B7%D1%8B%D0%BA%D0%B8,%D0%B3%D0%BE%D1%80%D0%BE%D0%B4%D0%B0,%D0%BA%D1%80%D0%B0%D1%81%D0%BD%D0%BE%D0%B5+%D0%B2%D0%B8%D0%BD%D0%BE,%D0%BC%D1%8F%D1%81%D0%BE,%D0%BF%D0%B0%D1%80%D0%BD%D0%B8,%D1%87%D1%83%D0%B4%D0%B5%D1%81%D0%B0,%D1%80%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9+%D1%8F%D0%B7%D1%8B%D0%BA,%D0%B3%D1%80%D0%B8%D0%B1%D1%8B,%D1%88%D0%BE%D0%BF%D0%BF%D0%B8%D0%BD%D0%B3,%D0%94%D0%B0%D0%BB%D0%B8,%D0%BD%D0%B5+%D1%81%D0%BF%D0%B0%D1%82%D1%8C,%D0%BA%D0%B0%D0%BC%D0%BD%D0%B8,%D0%B3%D0%B5%D0%B8,%D0%B4%D0%B0%D1%80%D0%B8%D1%82%D1%8C,%D0%B2%D0%BE%D0%BB%D0%BE%D1%81%D1%8B,tina+turner,%D0%BB%D0%B5%D0%B4,sea+food,%D0%B3%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D1%8F,%D1%81%D0%BB%D0%BE%D0%BD%D1%8B,%D0%A8%D0%B2%D0%B5%D1%86%D0%B8%D1%8F,%D1%84%D1%8D%D0%BD-%D1%88%D1%83%D0%B9,%D0%90%D0%BB%D0%B8%D1%81%D0%B0+%D0%B2+%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B5+%D1%87%D1%83%D0%B4%D0%B5%D1%81,%D0%A2%D0%92,%D1%81%D0%BB%D0%BE%D0%B2%D0%B0%D1%80%D0%B8,%D1%82%D0%B5%D0%BC%D0%BD%D0%BE%D0%B5+%D0%BF%D0%B8%D0%B2%D0%BE,%D0%91%D0%B5%D1%80%D0%BB%D0%B8%D0%BD,%D0%B3%D0%B0%D1%88%D0%B8%D1%88,%D0%BA%D0%BB%D0%B8%D0%BF%D1%8B,%D0%BA%D1%80%D0%B0%D1%81%D0%B8%D0%B2%D1%8B%D0%B5+%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D1%8B,%D0%91%D0%B5%D1%80%D1%80%D0%BE%D1%83%D0%B7,%D0%96%D0%B0%D0%BD%D0%BD%D0%B0+%D0%90%D0%B3%D1%83%D0%B7%D0%B0%D1%80%D0%BE%D0%B2%D0%B0,%D0%91%D0%BE%D1%80%D0%B8%D1%81+%D0%92%D0%B8%D0%B0%D0%BD,%D0%B1%D0%B8%D1%80%D0%B6%D0%B0,%D0%BC%D0%BE%D0%BB%D0%BE%D1%87%D0%BD%D1%8B%D0%B5+%D0%BA%D0%BE%D0%BA%D1%82%D0%B5%D0%B9%D0%BB%D0%B8,%D0%BF%D0%B0%D1%81%D1%82%D0%B0,%D1%88%D1%82%D1%83%D1%87%D0%BA%D0%B8,%D0%B0%D0%BD%D0%B4%D0%B5%D1%80%D0%B3%D1%80%D0%B0%D1%83%D0%BD%D0%B4,%D1%81%D0%B8%D0%B4%D0%B5%D1%82%D1%8C+%D0%BD%D0%B0+%D0%BE%D0%BA%D0%BD%D0%B5,%D1%81%D1%8B%D1%80%D1%8B,%D0%98%D0%BB%D1%8C%D1%8F+%D0%9B%D0%B0%D0%B3%D1%83%D1%82%D0%B5%D0%BD%D0%BA%D0%BE,%D0%A1%D0%B8%D0%BD%D0%B0%D0%B9,%D0%9D%D0%B0%D1%82%D0%B0%D0%BB%D0%B8%D1%8F+%D0%9C%D0%B5%D0%B4%D0%B2%D0%B5%D0%B4%D0%B5%D0%B2%D0%B0,%D0%BC%D0%BD%D0%BE%D0%B3%D0%BE%D0%BE%D0%B1%D1%80%D0%B0%D0%B7%D0%B8%D0%B5,%D0%B8%D0%B3%D1%80%D0%B0%D1%82%D1%8C+%D0%B2+%D0%BC%D0%B0%D1%84%D0%B8%D1%8E,%D0%91%D0%B0%D1%80%D0%B1%D0%B0%D1%80%D0%B0+%D0%A1%D1%82%D1%80%D0%B5%D0%B9%D0%B7%D0%B0%D0%BD%D0%B4,%D0%BF%D0%BE%D0%BE%D1%80%D0%B0%D1%82%D1%8C,%D0%B4%D1%80%D0%B5%D0%B2%D0%BD%D0%B8%D0%B5+%D0%B3%D1%80%D0%B5%D0%BA%D0%B8,%D0%9C%D0%B0%D1%80%D0%B8%D0%B0%D0%BD%D0%BD%D0%B0,%D1%85%D0%B8%D1%82%D1%8B,%D0%BC%D0%B0%D1%82%D0%B5%D1%80%D0%BD%D1%8B%D0%B5+%D1%81%D0%BB%D0%BE%D0%B2%D0%B0,%D0%BF%D1%81%D0%B5%D0%B2%D0%B4%D0%BE%D0%BD%D0%B8%D0%BC%D1%8B,%D7%90%D7%A8%D7%A5+%D7%A0%D7%94%D7%93%D7%A8%D7%AA,%D0%94%D0%B6%D0%B5%D0%B9%D0%BC%D1%81,%D0%B7%D0%B0%D0%BF%D0%B8%D1%81%D0%BA%D0%B8+%D0%BD%D0%B0+%D1%85%D0%BE%D0%BB%D0%BE%D0%B4%D0%B8%D0%BB%D1%8C%D0%BD%D0%B8%D0%BA%D0%B5,%D0%BF%D1%80%D0%B8%D0%BA%D0%BE%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F+%D0%BE%D0%B1%D1%83%D0%B2%D1%8C,%D0%B2%D0%BE%D0%B7%D0%B2%D1%80%D0%B0%D1%89%D0%B0%D1%82%D1%8C%D1%81%D1%8F+%D0%BF%D0%BE%D0%B4+%D1%83%D1%82%D1%80%D0%BE,%D0%96%D0%B0%D0%BD,%D1%87%D1%83%D0%B6%D0%B8%D0%B5+%D0%B2%D0%BE%D1%81%D0%BF%D0%BE%D0%BC%D0%B8%D0%BD%D0%B0%D0%BD%D0%B8%D1%8F,%D0%A0%D0%B0%D0%BC%D0%B0%D1%82-%D0%93%D0%B0%D0%BD,%D0%B4%D1%80%D1%83%D0%B6%D0%B5%D1%81%D0%BA%D0%B8%D0%B5+%D0%BF%D1%8C%D1%8F%D0%BD%D0%BA%D0%B8,%D0%BA%D1%80%D0%B0%D1%81%D0%B8%D0%B2%D1%8B%D0%B5+%D0%B4%D0%B5%D1%80%D0%B5%D0%B2%D1%8C%D1%8F,%22%D0%BD%D0%B5%D1%80%D0%B5%D1%81%D1%82%22,dolce+pontes,%D0%B3%D0%BB%D1%8F%D0%BD%D1%86%D0%B5%D0%B2%D1%8B%D0%B5+%D0%B0%D0%BB%D1%8C%D0%B1%D0%BE%D0%BC%D1%8B,%D0%B8%D1%86%D0%B7%D1%8B%D0%BD,%D1%80%D0%B0%D0%B7%D0%BD%D0%B0%D1%8F+%D1%87%D1%83%D1%88%D1%8C,%D1%80%D0%BE%D1%8F%D0%BB%D0%B8+%D0%B8+%D0%BF%D0%B8%D0%B0%D0%BD%D0%B8%D0%BD%D0%BE,%D7%A1%D7%95%D7%A4%D7%A8%D7%A4%D7%90%D7%A8%D7%9D,%D7%A2%D7%95%D7%A4%D7%A8+%D7%A0%D7%99%D7%A1%D7%99%D7%9D&contents=&categories=TRAV,DATE,SHOP,ARTS,MUSIC,FUN&channel=Journal-Skyscraper&adunit=skyscraper&accttype=ADS&age=36&height=600&url=http://ilyush.livejournal.com/&type=content&gender=';
my $english = 'http://ads1.dev.sixapart.com/js/?p=lj&id=id&f=insertAd&country=&width=728&language=en&interests=&contents=I+don%27t+love+you+as+if+you+were+the+salt-rose,+topazor+arrow+of+carnations+that+propagate+fire:I+love+you+as+certain+dark+things+are+loved,secretly,+between+the+shadow+and+the+soul.I+love+you+as+the+plant+that+doesn%27t+bloom+and+carrieshidden+within+itself+the+light+of+those+flowers,and+thanks+to+your+love,+darkly+in+my+bodylives+the+dense+fragrance+that+rises+from+the+earth.I+love+you+without+knowing+how,+or+when,+or+from+where,I+love+you+simply,+without+problems+or+pride:I+love+you+in+this+way+because+I+don%27t+know+any+other+way+of+lovingbut+this,+in+which+there+is+no+I+or+you,so+intimate+that+your+hand+upon+my+chest+is+my+hand,so+intimate+that+when+I+fall+asleep+it+is+your+eyes+that+close.Sonnet+XVII:+Love+pablo+nerudaI+would+really+love+to+stop+feeling+this+jaded,+I+wander+how+much+more+I+could+take.+Migraine+seems+to+be+a+package+with+jaded-ness%3FOn+a+really+happier+note,+thank+goodness+nothing+happened+to+Wanni%27s+Grandpa.+And+I+am+really+glad+for+Ame%27s+existence.+:%29Yesterday+was+the&categories=&channel=Journal-Leaderboard-Bottom&adunit=leaderboard-bottom&accttype=ADS&age=36&height=90&url=http://of_unspoken.livejournal.com/&type=content&gender=';

for my $string ($simple, $random, $english, $russian) {
    printf "String length: %d\n", length $string;
    {
        my $nonxs = {};
        CGI::Deurl::deurl($string, $nonxs);
        my $xs = parse_query_string($string);
        my $xsdec = parse_decode_query_string($string);
        my %parsed = (nonxs => $nonxs, xs => $xs, xsdec => $xsdec);
        print Data::Dumper->Dump([$nonxs, $xs, $xsdec], [qw/ nonxs xs xsdec /]), "\n";
        print YAML::Syck::Dump(\%parsed), "\n";
        for my $thing (sort keys %parsed) {
            my $d = $parsed{$thing};
            print "$thing\n";
            for my $key (sort keys %$d) {
                print "  $key=$d->{$key}\n";
            }
        }
        print "\n";
    }
    my $params = {};
    timethese(-5, {
        'CGI::Deurl::deurl' => sub {
            $params = {};
            CGI::Deurl::deurl($string, $params);
        },
        'CGI::Deurl::XS::parse_query_string' => sub {
            parse_query_string($string)
        },
        'CGI::Deurl::XS::parse_decode_query_string' => sub {
            parse_decode_query_string($string)
        },
    });
}
