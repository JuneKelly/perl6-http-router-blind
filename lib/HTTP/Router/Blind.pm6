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
    my @potential-matches;
    @potential-matches.append(@( %!routes<ANY> ));
    @potential-matches.append(@( %!routes{$method} ));
    for @potential-matches -> ($path, &func) {
        if $path ~~ Str {
            if $uri eq $path {
                return &func(%env);
            }
            if $path.contains(':') {
                my @p = $path.split('/');
                my @u =  $uri.split('/');
                # TODO: check the rest of the uri matches, not just count
                if @p.elems == @u.elems {
                    my @indexes = @p.grep-index: { .starts-with: ':' };
                    my @keys = @p[@indexes].map: { .substr(1) };
                    my @vals = @u[@indexes];
                    my %params = zip(@keys, @vals).map: { $^a[0] => $^a[1] };
                    %env<params> = %params;
                    return &func(%env);
                }
            }
        }
        if $path ~~ Regex {
            my $match = $uri ~~ $path;
            if $match {
                %env<params> = $match;
                return &func(%env);
            }
        }
    }
    return &!on-not-found(%env);
}
