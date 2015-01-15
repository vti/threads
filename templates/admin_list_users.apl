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
        </tr>
    % }
    </table>

    %== $helpers->displayer->render('include/pager', base_url => $helpers->url->admin_list_users, total => $helpers->admin_user->count);

</div>
