use v6;

BEGIN { @*INC.push('lib') };

use Test;
plan 5;

use HTTP::Router::Blind;
ok 1, "'use HTTP::Router::Blind' worked";


my $router = HTTP::Router::Blind.new();
ok 1, "creating new router worked";


## string route
$router.get('/about', sub (%env) {
    'this-is-get'
});

my %env;
my $result;

$result = $router.dispatch('GET', '/about', %env);
if $result ~~ 'this-is-get' {
    ok 1, "basic string route worked";
};

# Regex route with named capture group
$router.get(/\/items\/$<id>=(.*)/, sub (%env) {
    %env<params><id>;
});

$result = $router.dispatch('GET', '/items/4221', %env);
if $result ~~ '4221' {
    ok 1, "regex with named capture group worked";
};

# Regex route with positional capture group
$router.get(/\/(.*)\/(.*)/, sub (%env) {
    %env<params>[0], %env<params>[1]
});

$result = $router.dispatch('GET', '/aaa/bbb', %env);
if $result[0] eq 'aaa' &&  $result[1] eq 'bbb' {
    ok 1, "regex with positional capture group worked";
};
