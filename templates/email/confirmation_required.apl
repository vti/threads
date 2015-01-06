% my $url = $helpers->config->config->{base_url} . $helpers->url->confirm_registration(token => $token);
%== loc(q{You or somebody else has registered '[_1]' at our website. If that was you, please use the following link to confirm your registration:}, $email)


    <%= $url %>

%== loc('Otherwise just ignore this email.')
