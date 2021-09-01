#!perl -T
use Modern::Perl;
use warnings FATAL => 'all';
use Test::More;
use Module::Load::Conditional qw/check_install/;
use Koha::Notice::Messages;
use Koha::Libraries;

plan tests => 2;

use_ok('Koha::Notice::Messages');
use_ok('Koha::Libraries');
