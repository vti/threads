                <div class="markup-help-template">
                    <div class="markup-help-instance">
                    <ul>
                        <li>@user</li>
                    % foreach my $code (
                    %   '_italic_',
                    %   '**bold**',
                    %   '[PP](http://pragmaticperl.com)',
                    %   '<http://pragmaticperl.com>',
                    %   'module:Plack',
                    %   'release:URI',
                    %   'author:VTI',
                    %   ) {
                        <li>
                        <pre><code><%= $code %></code></pre> &rarr; <%== $helpers->markup->render($code) %>
                        </li>
                    % }
                        <li>
                        <pre><code>`my $foo = 'bar'`</code></pre>
                        </li>
                        <li>
                        <pre><code>```
my $multi;
$line;
```</code></pre>
                        </li>
                    </ul>
                    </div>
                </div>
