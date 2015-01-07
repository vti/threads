<div class="grid-50 mobile-grid-100">

    <h1><%= $thread->{title} %></h1>

    <%= $thread->{content} %>

    <form method="POST" action="<%= $helpers->url->create_reply(id => $thread->{id}) %>">

    <%== $helpers->form->input('content', label => 'Content') %>

    <input type="submit" value="<%= loc('Reply') %>" />

    </form>

    % foreach my $reply ($helpers->reply->find_by_thread($thread)) {
        <div>
            <%= $reply->{content} %>
        </div>

        <form method="POST" action="<%= $helpers->url->create_reply(id => $thread->{id}) %>">

        <input type="hidden" name="to" value="<%= $reply->{id} %>" />
        <%== $helpers->form->input('content', label => 'Content') %>

        <input type="submit" value="<%= loc('Reply to') %>" />

        </form>
    % }

</div>
