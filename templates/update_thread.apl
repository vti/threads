<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Update thread') %></h1>

    <form method="POST">

    <%== $helpers->form->input('title', label => 'Title', default => $thread->{title}) %>
    <%== $helpers->form->textarea('content', label => 'Content', default => $thread->{content}) %>

    <input type="submit" value="<%= loc('Update') %>" />

    </form>

</div>
