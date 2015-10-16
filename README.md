# HTTP::Router::Blind

A simple, framework-agnostic HTTP Router for Perl6


## Example

With the HTTP::Easy server:
```perl6
use v6;
use HTTP::Easy::PSGI;
use HTTP::Router::Blind;

my $http = HTTP::Easy::PSGI.new(:port(8080));
my $router = HTTP::Router::Blind.new();

# simple string-match route
$router.get("/", sub (%env) {
    [200, ['Content-Type' => 'text/plain'], ["Home is where the heart is"]]
});

$router.get("/about", sub (%env) {
    [200, ['Content-Type' => 'text/plain'], ["About this site"]]
});

# regex match, with named capture-group,
# will match a request like '/items/42253',
# the regex match results are available as %env<params>;
$router.get(/\/items\/$<id>=(.*)/, sub (%env) {
    my $id = %env<params><id>;
    [200, ['Content-Type' => 'text/plain'], ["got request for item $id"]]
});

# in our app function, we just call $router.dispatch
my $app = sub (%env) {
    $router.dispatch(%env<REQUEST\_METHOD>, %env<REQUEST\_URI>, %env);
};

$http.handle($app);
```
