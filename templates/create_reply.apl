<div class="grid-50 mobile-grid-100">

    <h1><%= loc('Create reply') %></h1>

    <form method="POST">

    <%== $helpers->form->input('content', label => 'Content') %>

    <input type="submit" value="<%= loc('Create') %>" />

    </form>

</div>
