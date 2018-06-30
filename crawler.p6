#!/usr/bin/env perl6

use v6;

use DOM::Tiny;
use HTTP::UserAgent;

sub MAIN(Str :$seed = "http://perl6.org", Str :$file = "$seed.links") {
	get-links($seed);
}

# TODO urls into hash with url => depth

sub get-links($url, :$limit = 4) {
	my $ua = HTTP::UserAgent.new;
	my %links;
	my $depth = 0;
	react {
		whenever $ua.get($url) -> $response {
			my $dom = DOM::Tiny.parse(~$response);
			race for $dom.find('a[href]') -> $e {
				while $depth ≤ $limit {
					if $e<href> ~~ /http/ {
						%links.push("$e<href>" => $depth++);
					}
					else {
						%links.push("$url$e<href>" => $depth++);
					}
					QUIT {
						default {
							note "$url failed: " ~ .message;
						}
					}
				}
			}
		}
	}
	say %links;
}


#`[
sub crawl($url) {
	react {
		my %seen;
		my $ua = HTTP::UserAgent.new;
		my $dom = DOM::Tiny.new;
		crawl-url(~$url);

		sub crawl-url($url) {
			return if %seen{$url}++;
			say "Getting $url";
			whenever $ua.get($url) -> $response {
				if $response.content-type ~~ /text\/html/ {
					get-links($response, $url);
				}
				QUIT {
					default {
						note "$url failed: " ~ .message;
					}
				}
			}
		}

		sub get-links($response, $base) {
			my $dom = DOM::Tiny.parse(~$response);
			say $dom;
		}
	}
}
]
#`[
sub crawl($seed) {
	react {
		my %seen;
		my $client = Cro::HTTP::Client.new;
		crawl-url(Cro::Uri.parse($seed));

		sub crawl-url(Cro::Uri $url) {
			return if %seen{$url}++;
			say "Getting $url";
			whenever $client.get($url) -> $response {
				if $response.content-type.type-and-subtype eq 'text/html' {
					get-links($response, $url);
				}
				QUIT {
					default {
						note "$url failed: " ~ .message;
					}
				}
			}
		}

		sub get-links($response, $base) {
			whenever $response.body-text -> $text {
				for $text.match(/'href="' <!before \w+':'> <( <-["]>/, :g) {
					crawl-url $base.add(~$_);
				}
			}
		}
	}
}

	my $ua = HTTP::UserAgent.new;
	$ua.timeout = 10;
	my $response = $ua.get($url);
	my $dom = DOM::Tiny.parse(~$response);
	my @links;
	race for $dom.find('a[href]') -> $e {
		if $e<href> ~~ /http/ {
			@links.push($e<href>);
		}
		else {
			@links.push("$url$e<href>");
		}
	}
	#return $dom.find('a[href]')>><href>>>.&get-urls if $_ ~~ /http/;

sub print-urls(@links, $file?) {
	race for get-urls(@links) -> $e {
		say @links;
	}
}
]
