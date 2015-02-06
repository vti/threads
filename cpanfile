requires 'DBD::SQLite';
requires 'Digest::SHA';
requires 'Email::MIME';
requires 'Email::Valid';
requires 'HTML::Truncate';
requires 'I18N::AcceptLanguage';
requires 'JSON';
requires 'Locale::Maketext::Extract::Run';
requires 'Math::Random::ISAAC';
requires 'Net::Domain::TLD';
requires 'ObjectDB';
requires 'Plack';
requires 'Plack::Middleware::ReverseProxy';
requires 'Plack::Session';
requires 'Routes::Tiny';
requires 'String::CamelCase';
requires 'Text::APL';
requires 'YAML::Tiny';
requires 'Text::Unidecode';

requires 'AnyEvent';

on 'test' => sub {
    requires 'Test::More';
    requires 'Test::WWW::Mechanize::PSGI';
    requires 'Test::MonkeyMock';
};
