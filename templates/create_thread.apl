<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Create thread') %></h1>

    <form method="POST">

    <%== $helpers->form->input('title', label => 'Title') %>
    <%== $helpers->form->textarea('content', label => 'Content') %>

    <input type="submit" value="<%= loc('Create new thread') %>" />

    </form>

</div>
