use v6;

BEGIN { @*INC.unshift('lib') };

use Test;
plan 2;

use HTTP::Router::Blind;

my %env;
my $result;
my $router = HTTP::Router::Blind.new();

# simple, one keyword
$router.get: '/one/:name', -> %env, $params {
    $params<name>;
};

$result = $router.dispatch: 'GET', '/one/jim', %env;
ok $result eq 'jim', 'basic keyword match works';

# multi-handlers with keyword params
sub checker (%env, $params) {
    if $params<thing> eq "yes" {
        %env<checked> = True;
    }
    %env;
}
$router.get: '/othercheck/:thing', &checker, -> %env, $params {
    %env;
};

$result = $router.dispatch('GET', '/othercheck/yes', %env);
ok $result<checked> == True, 'multi-handler with keyword params works';
