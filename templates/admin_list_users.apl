<div class="grid-100">

%== $helpers->displayer->render('include/admin_nav');

    % my @users = $helpers->admin_user->find;

    <table>
    % foreach my $user (@users) {
        <tr>
        <td><%= $user->{id} %></td>
        <td><%= $user->{email} %></td>
        <td><%= $user->{name} %></td>
        <td><%= $user->{status} %></td>
        <td><%= $user->{role} %></td>
        <td><%= $helpers->date->format($user->{created}) %></td>
        <td>
        % if ($helpers->acl->user->{id} != $user->{id}) {
        % my $is_blocked = $user->{status} eq 'blocked';
        <form class="form-inline" method="POST" action="<%= $helpers->url->admin_toggle_blocked(id => $user->{id}) %>">
        <button onclick="return confirm('<%= loc('Are you sure?') %>')">
        % if ($is_blocked) {
            <i class="fa fa-ban"></i> <%= loc('unban') %>
        % } else {
            <i class="fa fa-check"></i> <%= loc('ban') %>
        % }
        </button>
        % }
        </form>
        </td>
        </tr>
    % }
    </table>

    %== $helpers->displayer->render('include/pager', base_url => $helpers->url->admin_list_users, total => $helpers->admin_user->count);

</div>
