<div class="grid-100">

    <h1><%= loc('Update thread') %></h1>

    <form method="POST" id="update-thread">

    <%== $helpers->form->input('title', label => loc('Title'), default => $thread->{title}) %>
    <%== $helpers->form->textarea('content', label => loc('Content'), default => $thread->{content}) %>

    <input type="submit" value="<%= loc('Update') %>" />

    </form>

</div>
