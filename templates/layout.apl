<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta http-equiv="x-ua-compatible" content="ie=edge" />
<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1" />
% my $base_title = $helpers->config->config->{meta}->{title} || loc('Forum');
<title><% if ($helpers->acl->is_user && (my $notification_count = $helpers->notification->count)) { %>(<%= $notification_count %>) <% } %><%= $helpers->meta->get('title') ? $helpers->meta->get('title') . ' | ' : '' %><%= $base_title %></title>
% my $description = $helpers->meta->get('description') || $helpers->config->config->{meta}->{description};
% if ($description) {
<meta name="description" content="<%= $description %>" />
% }
<!--[if lt IE 9]>
  <script src="/unsemantic/js/html5.js"></script>
<![endif]-->
<link rel="stylesheet" href="/unsemantic/css/reset.css" />
<!--[if (gt IE 8) | (IEMobile)]><!-->
  <link rel="stylesheet" href="/unsemantic/css/unsemantic-grid-responsive.css" />
<!--<![endif]-->
<!--[if (lt IE 9) & (!IEMobile)]>
  <link rel="stylesheet" href="/unsemantic/css/ie.css" />
<![endif]-->
  <link rel="stylesheet" href="/formalize/css/formalize.css" />
  <link rel="stylesheet" href="/font-awesome/css/font-awesome.min.css" />
  <link rel="stylesheet" href="/codemirror/codemirror.css" />
% $helpers->assets->require('/css/styles.css');
%== $helpers->assets->include(type => 'css');
</head>
<body>
    <div id="wrapper">
        <div class="grid-container">
            <div class="grid-10">
                &nbsp;
            </div>
            <div class="grid-80 mobile-grid-100">
            <div id="header" class="grid-100 mobile-grid-100">
                % if (my $header = $helpers->config->config->{theme}->{header}) {
                    <%== $header %>
                % }

                <a href="<%= $helpers->url->index %>"><%= loc('Threads') %></a> |
                % if ($helpers->acl->is_user) {
                <a href="<%= $helpers->url->create_thread %>">+ <%= loc('Create thread') %></a> |
                % if ($helpers->acl->is_admin) {
                <a href="<%= $helpers->url->admin_index %>" class="status-bg-danger"><%= loc('Admin') %></a> |
                % }

                <i class="fa fa-user"></i> <a href="<%= $helpers->url->profile %>"><%= $helpers->user->display_name($helpers->acl->user) %></a>
                <span class="notification-count-outer">
                % my $notification_count = $helpers->notification->count;
                % if ($notification_count) {
                <a href="<%= $helpers->url->list_notifications %>" class="notification-count" title="<%= loc('Notifications') %>"><%= $notification_count %></a>
                % }
                </span>
                |
                <form class="form-inline" method="post" action="<%= $helpers->url->logout %>" id="logout">
                    <button class="link" type="submit"><%= loc('Logout') %></button>
                </form>

                % } else {
                <a href="<%= $helpers->url->register %>" rel="nofollow"><%= loc('Sign up') %></a> | <a href="<%= $helpers->url->login %>" rel="nofollow"><%= loc('Login') %></a>
                % }
                <hr />
            </div>
            %== $content;
        </div>
            <div class="grid-10">
            </div>
        </div>
        <div id="push"></div>
    </div>
    <div id="footer">
        <div class="grid-container">
            <div class="grid-100 mobile-grid-100">
                <i class="fa fa-github"></i> <a href="http://github.com/vti/threads">Threads</a>, <%= loc('powered by') %> <a href="http://perl.org">Perl</a>
            </div>
        </div>
    </div>
    <script src="/js/jquery.js"></script>
    <script src="/formalize/js/jquery.formalize.min.js"></script>
    <script src="/codemirror/codemirror.js"></script>
    <script src="/codemirror/perl.js"></script>
    <script src="/js/moment.js"></script>
    <script src="/js/models.js"></script>
    <script src="/js/actions.js"></script>
    <script src="/js/essentials.js"></script>
    % if ($helpers->acl->is_user && (my $events_config = $helpers->config->config->{events})) {
    <script src="/js/EventSource.js"></script>
    <script>
      function openEvents(timeout) {
          var es = new EventSource("<%= $events_config->{path} %>", { withCredentials: true });
          var listener = function (event) {
            if (event.type === "message") {
              if (event.data) {
                var data = jQuery.parseJSON(event.data);
                Models.noCount.set('count', data.total);
              }
            }
            else if (event.type === "error") {
              es.close();
              setTimeout(function() {
                  if (timeout < 300000)
                      timeout = timeout * 2
                  openEvents(timeout);
              }, timeout);
            }
            else if (event.type === "open") {
                timeout = 1000;
            }
          };
          es.addEventListener("open", listener);
          es.addEventListener("message", listener);
          es.addEventListener("error", listener);
      }

      openEvents(1000);
    </script>
    % }
    %== $helpers->assets->include(type => 'js');
</body>
</html>
