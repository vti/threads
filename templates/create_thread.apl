<div class="grid-100">

    <h1><%= loc('Create thread') %></h1>

    <form method="POST" id="create-thread">

    <%== $helpers->form->input('title', label => loc('Title')) %>
    <%== $helpers->form->textarea('content', label => loc('Content')) %>

    <input type="submit" value="<%= loc('Create new thread') %>" />

    </form>

</div>
