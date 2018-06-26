#!/usr/bin/env perl6

use v6;

use DOM::Tiny;
use HTTP::UserAgent;

sub MAIN(Str :$seed = "http://perl6.org", Str :$file = "perl6.links") {
	print-urls($seed, $file);
}

sub get-urls($url) {
	my $ua = HTTP::UserAgent.new;
	$ua.timeout = 10;
	my $response = $ua.get($url);
	my $dom = DOM::Tiny.parse("$response");
	return $dom.find('a[href]');
}

sub print-urls($seed, $file?) {
	await do for get-urls($seed) -> $e {
		start {
			say $e<href>;
			if $file {
				my $fh = open "$file", :a;
				$fh.say("$e<href>", ':', $e.text);
				$fh.close;
			}
		}
	}
}
