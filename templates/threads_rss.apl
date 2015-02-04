% my $config = $helpers->config->config;
% my $base_url = $config->{base_url};
% my @threads = $helpers->thread->find;
% my $pub_date = @threads ? $threads[0]->{created} : 0;
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xml:base="<%= $base_url %>" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
        <title><%= loc('Threads') %> | <%= $config->{meta}->{title} %></title>
        <link><%= $base_url . $helpers->url->threads_rss %></link>
        <atom:link href="<%= $base_url . $helpers->url->threads_rss %>" rel="self" type="application/rss+xml" />
        <description><%= $config->{meta}->{description} %></description>
        <pubDate><%= $helpers->date->format_rss($pub_date) %></pubDate>
        <generator>threads</generator>
        % foreach my $thread (@threads) {
        <item>
          <title><%= $thread->{title} %></title>
          <author><%= $helpers->user->display_name($thread->{user}) %></author>
          <link><%= $base_url . $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %></link>
          <description><![CDATA[
              <%= $helpers->truncate->truncate($thread->{content}) %>
          ]]></description>
          % foreach my $tag (@{$thread->{tags}}) {
          <category><%= $tag->{title} %></category>
          % }
          <pubDate><%== $helpers->date->format_rss($thread->{created}) %></pubDate>
          <comments><%= $base_url . $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %></comments>
          <guid><%= $base_url . $helpers->url->view_thread(id => $thread->{id}, slug => $thread->{slug}) %></guid>
        </item>
        % }
    </channel>
</rss>
