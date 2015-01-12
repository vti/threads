<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta http-equiv="x-ua-compatible" content="ie=edge" />
<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1" />
% my $base_title = $helpers->config->config->{meta}->{title} || loc('Forum');
<title><%= $helpers->meta->get('title') ? $helpers->meta->get('title') . ' | ' : '' %><%= $base_title %></title>
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
%== $helpers->assets->include(type => 'css');
<link rel="stylesheet" href="/css/styles.css" />
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
                % my $notification_count = $helpers->notification->count;

                <i class="fa fa-user"></i> <a href="<%= $helpers->url->profile %>"><%= $helpers->user->display_name($helpers->acl->user) %></a>
                % if ($notification_count) {
                <a href="<%= $helpers->url->list_notifications %>" class="no-underline status-bg-notice" title="<%= loc('Notifications') %>">( <%= $notification_count %> )</a>
                % }
                |
                <form class="form-inline" method="post" action="<%= $helpers->url->logout %>" id="logout">
                    <button class="link" type="submit"><%= loc('Logout') %></button>
                </form>

                % } else {
                <a href="<%= $helpers->url->register %>"><%= loc('Sign up') %></a> | <a href="<%= $helpers->url->login %>"><%= loc('Login') %></a>
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
    <script src="/unsemantic/js/jquery.js"></script>
    <script src="/formalize/js/jquery.formalize.min.js"></script>
    <script src="/codemirror/codemirror.js"></script>
    <script src="/codemirror/perl.js"></script>
    %== $helpers->assets->include(type => 'js');
    <script>
        $(document).ready(function() {
            var editors = [];
            $('pre.markup code').each(function() {
                $(this).replaceWith('<textarea class="code perl">' + $(this).text() + '</textarea>');
            });
            $('textarea.code').each(function() {
                var editor = CodeMirror.fromTextArea(this, {readOnly: true, lineNumbers: true});
                editors.push(editor);
            });
        });
    </script>

</body>
</html>
