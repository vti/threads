<div class="grid-100">

%== $helpers->displayer->render('include/admin_nav');

    % my @users = $helpers->user->find;

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

</div>
