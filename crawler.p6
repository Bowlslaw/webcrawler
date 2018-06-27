#!/usr/bin/env perl6

use v6;

use DOM::Tiny;
use HTTP::UserAgent;

sub MAIN(Str :$seed = "http://perl6.org", Str :$file = "perl6.links") {
	get-urls($seed);
}

# DONE TODO Get actual string value of <href>.
# DONE TODO Find way to normalize urls
# TODO Set up a thread-safe Channel. The threads will send stuff to Channel.
# TODO Read about Supply
# DONE TODO Use array to hold links
sub get-urls($url) {
	my $ua = HTTP::UserAgent.new;
	$ua.timeout = 10;
	my $response = $ua.get($url);
	my $dom = DOM::Tiny.parse(~$response);
	my @links;
	race for $dom.find('a[href]') -> $e {
		start {
			#print-urls2($e<href>) if $e<href> ~~ /http/;
			@links.push($e<href>) if $e<href> ~~ /http/;
			@links.push("$url$e<href>") if $e<href> !~~ /http/;
		}
	}
	say @links.unique.join("\n");
	#return $dom.find('a[href]')>><href>>>.&get-urls if $_ ~~ /http/;
}

sub print-urls2($url) { say $url; }

sub print-urls($seed, $file?) {
	race for get-urls($seed) -> $e {
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
