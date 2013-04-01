use strict;
use Test::More;

use Acme::Bool;


{
    package Scalar::Bool;
    use parent qw(Exporter);
    use Scalar::Util ();
 
    BEGIN { our @EXPORT_OK = qw(true false is_bool) }
 
    use overload (
        q{bool} => \&_invert,
        fallback => 1,
    );
 
    my $true = bless(
        \(
            do { my $v = 1 }
        ), "Scalar::Bool::True"
    );
    sub true () { $true }
 
    my $false = bless(
        \(
            do { my $v = 0 }
        ), "Scalar::Bool::False"
    );
    sub false () { $false }
 
    sub is_bool {
        my $value = shift;
        return 0 unless Scalar::Util::reftype($value) eq 'SCALAR';
        return 0 unless overload::Method($value, 'bool');
        return 1;
    }
 
    package Scalar::Bool::True;
    our @ISA = qw(Scalar::Bool);
    package Scalar::Bool::False;
    our @ISA = qw(Scalar::Bool);
}

{
    package Overloaded::But::Not::Bool;
    use overload (
        q{""} => sub { "Gah" }
    );
    sub new { my $n = 0; bless \$n, __PACKAGE__ }
}
 
BEGIN { Scalar::Bool->import(qw(true false is_bool)); }

ok(Acme::Bool::is_bool(true));
ok(Acme::Bool::is_bool(false));
ok(!Acme::Bool::is_bool(bless(\(do {my $n=0}), 'NonBool')));
ok(!Acme::Bool::is_bool(Overloaded::But::Not::Bool->new));
ok(!Acme::Bool::is_bool(0));

done_testing;

