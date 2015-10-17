unit class HTTP::Router::Blind;

has %!routes = GET => @[],
               POST => @[],
               PUT => @[],
               DELETE => @[],
               ANY => @[];
has &!on-not-found = sub (%env) {
    [404, ['Content-Type' => 'text/plain'], 'Not found']
};

method get ($path, &handler) {
    %!routes<GET>.push(@($path, &handler));
}

method post ($path, &handler) {
    %!routes<POST>.push(@($path, &handler));
}

method put ($path, &handler) {
    %!routes<PUT>.push(@($path, &handler));
}

method delete ($path, &handler) {
    %!routes<DELETE>.push(@($path, &handler));
}

method anymethod ($path, &handler) {
    %!routes<ANY>.push(@($path, &handler));
}

method dispatch ($method, $uri, %env) {
    my &handler;
    my @potential-matches;
    @potential-matches.append(@( %!routes<ANY> ));
    @potential-matches.append(@( %!routes{$method} ));
    for @potential-matches -> ($path, &func) {
        if $path ~~ Str {
            if $uri ~~ $path {
                &handler = &func;
            }
        }
        if $path ~~ Regex {
            my $match = $uri ~~ $path;
            if $match {
                &handler = &func;
                %env<params> = $match;
            }
        }
    }
    if not &handler {
        return &!on-not-found(%env);
    }
    my $result = &handler(%env);
    return $result;
}
