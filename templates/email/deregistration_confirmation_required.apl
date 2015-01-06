% my $url = $helpers->config->config->{base_url} . $helpers->url->confirm_deregistration(token => $token);
%== loc(q{You or somebody else has deregistered '[_1]' at our website. If that was you, please use the following link to confirm your account removal}, $email)


    <%= $url %>

%== loc('Otherwise just ignore this email.')
