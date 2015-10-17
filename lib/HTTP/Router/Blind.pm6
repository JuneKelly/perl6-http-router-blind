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


method !keyword-match ($path, $uri) {
    my @p = $path.split('/');
    my @u =  $uri.split('/');
    if @p.elems != @u.elems {
        return;
    }
    my @pairs = zip(@p, @u);
    my %params;
    for @pairs -> @pair {
        my $p = @pair[0];
        my $u = @pair[1];
        if $p ne $u && !$p.starts-with(":") {
            return;
        }
        %params{$p.substr(1)} = $u;
    }
    return %params;
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
                my $params = self!keyword-match($path, $uri);
                if $params {
                    %env<params> = %($params);
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
