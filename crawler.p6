#!/usr/bin/env perl6

use v6;

use DOM::Tiny;
use HTTP::UserAgent;

sub MAIN(Str :$seed = "http://perl6.org", Str :$file = "test.links", Int :$depth = 2) {
	crawl($seed, $file, $depth);
}

# TODO Clear @links before reusing

sub crawl($url, $file, $depth) {
	return if $depth ≤ 0;
	my $ua = HTTP::UserAgent.new;
	my @links;
	react {
		whenever $ua.get($url) -> $response {
			my $dom = DOM::Tiny.parse(~$response);
			for $dom.find('a[href]') -> $e {
				say "Getting $e<href>";
				if $e<href> ~~ /http/ {
					@links.push($e<href>);
				}
				else {
					@links.push("$url$e<href>");
				}
			}
			my $fh = open $file, :a;
			$fh.say(@links.unique.join("\n"));
			$fh.close;
			for @links -> $link {
				crawl($link, $file, $depth - 1);
			}
		}
	}
}
