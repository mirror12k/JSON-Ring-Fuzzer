#!/usr/bin/env perl
use strict;
use warnings;

use feature 'say';

use IO::File;
use List::Util qw/ shuffle /;


# utility functions
sub slurp_file { local $/; return IO::File->new(shift, 'r')->getline; }
sub dump_file { local $/; return IO::File->new(shift, 'w')->write(shift); }
sub rand_choice { return @_[int rand @_] }

# mutators
sub mutate_byte {
	my ($data) = @_;

	my $from_p = int rand -1 + length $data;
	my $to_p = int rand length $data;

	my $replace_length = int rand 3;

	substr($data, $to_p, $replace_length) = substr $data, $from_p, 1;

	return $data;
}

my @insertions = (
	'[],',
	'[[]],',
	'[{}],',
	'"asdf",',
	'"yes":"no",',
	'\0\/\\\\',
	'\b\r\n\t',
	'\u00aa\u0000\u1234',
	'1e1,',
);


# mutators
sub mutate_insert {
	my ($data) = @_;

	my $to_p = int rand length $data;

	substr($data, $to_p, 0) = rand_choice(@insertions);

	return $data;
}

sub mutate_substitution {
	my ($data) = @_;

	my $from_p = int rand -1 + length $data;
	my $from_length = 1 + int rand -$from_p -1 + length $data;
	$from_length = $from_length > 64 ? 64 : $from_length;
	my $to_p = 1 + int rand length $data;
	my $to_length = int rand -$to_p + length $data;
	$to_length = $to_length > 16 ? 16 : $to_length;

	my $from = quotemeta substr $data, $from_p, $from_length;
	my $to = substr $data, $to_p, $to_length;

	$data =~ s/$from/$to/gs;

	return $data;
}

sub mutate_bitflip {
	my ($data) = @_;

	my $c = chr(0x1 << int rand 8) ^ chr(0x1 << int rand 8);

	my $to_p = 1 + int rand length $data;
	my $to_length = int rand -$to_p + length $data;
	$to_length = $to_length > 16 ? 16 : $to_length;

	my $to = substr $data, $to_p, $to_length;
	substr ($data, $to_p, $to_length) = $to ^ ($c x $to_length);

	return $data;
}

my %pair_map = (
	'(' => ')',
	'{' => '}',
	'[' => ']',
	'"' => '"',
	'\'' => '\'',
);

sub mutate_swap {
	my ($data) = @_;

	my @start_positions;
	push @start_positions, $-[0] while $data =~ /[\(\{\["']/g;

	my $from_p = rand_choice(@start_positions);
	my $c = substr($data, $from_p, 1);
	my $quoted_c = quotemeta $c;
	my $pair_c = quotemeta $pair_map{$c};

	my @end_positions;
	push @end_positions, $-[0] while $data =~ /$pair_c/g;
	@end_positions = grep $_ > $from_p, @end_positions;

	my $from_p_end = (shift @end_positions) // $from_p + 1;
	my $from_length = 1 + $from_p_end - $from_p;

	my @to_positions;
	push @to_positions, $-[0] while $data =~ /$quoted_c/g;

	my $to_p = rand_choice(@to_positions);

	my @to_end_positions;
	push @to_end_positions, $-[0] while $data =~ /$pair_c/g;
	@to_end_positions = grep $_ > $to_p, @to_end_positions;

	my $to_p_end = (shift @to_end_positions) // $to_p + 1;
	my $to_length = 1 + $to_p_end - $to_p;

	my $from = substr($data, $from_p, $from_length);
	my $to = substr($data, $to_p, $to_length);

	if ($from_p < $to_p) {
		substr($data, $to_p, $to_length) = $from;
		substr($data, $from_p, $from_length) = $to;
	} else {
		substr($data, $from_p, $from_length) = $to;
		substr($data, $to_p, $to_length) = $from;
	}


	# say "from: $from => to: $to";



	return $data;
}

sub mutate_multiply {
	my ($data) = @_;

	my $from_p = int rand -1 + length $data;
	my $from_length = 1 + int rand -$from_p -1 + length $data;

	my $count = int rand 3;

	substr($data, $from_p, $from_length) = substr ($data, $from_p, $from_length) x $count;

	return $data;
}

sub mutate {
	my ($data) = @_;

	# my @funs = (\&mutate_byte, \&mutate_substitution, \&mutate_bitflip, \&mutate_swap, \&mutate_multiply);
	my @funs = (\&mutate_byte, \&mutate_insert, \&mutate_bitflip, \&mutate_swap, \&mutate_multiply);

	return rand_choice(@funs)->($data);
}


my @processors = (
	# './misc/perl_xs.pl',
	'./misc/perl_pp.pl',
	'./misc/php.php',
	'./misc/python.py',
	'./misc/javascript.js',

	'cd json-java && java -cp .:json-java.jar ProcessJSON > ../data.json.new; cd ..; cat data.json.new > data.json; rm data.json.new',
	'mono newtonsoft-csharp/newtonsoft-run.exe',
);

my $ground_truth = './misc/perl_xs.pl';


# inputs
my $test_file = shift // die "target file required";
my $save_file = "$test_file.save";
my $data = slurp_file($test_file);
dump_file($save_file, $data);


# these fuctions are for configuring the harnessed application itself
# execute_file performs the test operations. Use as many flags and as many runs as necessary to test the full breadth of the application
sub execute_file {
	my $i = 0;
	foreach my $proc (shuffle @processors) {
		my $bak = slurp_file($test_file);
		$i++;
		dump_file("$test_file.bak.$i", $bak);
		my $res = `$proc`;
		say "status: ", $? >> 8 if (($? >> 8) != 0);
		return $proc if (($? >> 8) != 0 or slurp_file($test_file) eq '' or slurp_file($test_file) =~ /\A\w+\Z/s);

		`$ground_truth`;
		return $proc if (($? >> 8) != 0 or slurp_file($test_file) eq '' or slurp_file($test_file) =~ /\A\w+\Z/s);
	}
}
# reduce_file performs cleaning operation, in this case removing all comments (modify as necessary to your language)
sub reduce_file { dump_file($test_file, $_[0]); my $res = `$ground_truth`; return slurp_file($test_file); }
# a strict size limit to prevent bloating (mutators have a habit of increasing dead weight)
sub limit_file { return length $_[0] > 5000 ? substr $_[0], 0, 5000 : $_[0] }


foreach my $i (1 .. 100000) {
	# stop if we're out of processors to use
	last unless @processors;

	# mutate the file
	my $mutated_data = reduce_file(limit_file(mutate($data)));
	# mutate the file until ground-truth accepts it
	$mutated_data = reduce_file(limit_file(mutate($data))) while (($? >> 8) != 0 or $mutated_data eq '' or $mutated_data =~ /\A\w+\Z/s);
	say "mutated_data: $mutated_data";

	# process it through our processors
	dump_file($test_file, $mutated_data);
	my $res = execute_file($test_file);
	# whobrokeit?
	if ($res) {
		say "$res broke from input";
		# remove this processor from the list
		@processors = grep $_ ne $res, @processors;

		# record data on this processor break
		my $name = $res =~ s/\>[^\0]*?\Z|[^a-zA-Z0-9_]+//grs;
		$name = substr ($name, 0, 16) if 16 < length $name;
		mkdir "broke_$name";
		`mv $test_file.bak.* broke_$name`;
	} else {
		# no one broke, accept changes and move on
		say "test passed";
		$data = $mutated_data;
	}
	# clean up
	`rm -f $test_file.bak.*`;
}

# # mutate 100000 times or until user tired
# foreach my $i (1 .. 100000) {
# 	my $mutated_data = limit_file(reduce_file(mutate($data)));
# 	dump_file($test_file, $mutated_data);

# 	my $res = execute_file($test_file);

# 	if ($source_res ne $res) {
# 		say "test failed";
# 	} else {
# 		say "test_succeeded";
# 		$data = $mutated_data;
# 		dump_file($save_file, $data);
# 		# dump_file("$test_file." . sprintf("%06d", $i), $data);
# 	}
# }


# # output result
# say dump_file($test_file, $data);







