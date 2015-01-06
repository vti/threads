% my $url = $helpers->config->config->{base_url} . $helpers->url->reset_password(token => $token);
%== loc(q{You or somebody else has requested a password reset for '[_1]' at our website. If that was you, please use the following link to confirm your action:}, $email)


    <%= $url %>

%== loc('Otherwise just ignore this email.')
