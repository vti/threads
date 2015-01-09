use strict;
use warnings;

use Test::More;
use TestLib;
use TestRequest;

use Hash::MultiValue;
use Toks::Helper::Form;

subtest 'builds simple input' => sub {
    my $helper = _build_helper();

    is $helper->input('username'), <<'EOT';
<div class="form-input">
    <input type="text" name="username" />
</div>
EOT
};

subtest 'builds input with label' => sub {
    my $helper = _build_helper();

    is $helper->input('username', label => 'Login'), <<'EOT';
<div class="form-input">
    <label>Login</label><br />
    <input type="text" name="username" />
</div>
EOT
};

subtest 'builds input with label marked required' => sub {
    my $helper = _build_helper();

    is $helper->input('username', label => 'Login', required => 1), <<'EOT';
<div class="form-input">
    <label>Login*</label><br />
    <input type="text" name="username" />
</div>
EOT
};

subtest 'builds input with default value' => sub {
    my $helper = _build_helper();

    is $helper->input('username', default => 'foo'), <<'EOT';
<div class="form-input">
    <input type="text" name="username" value="foo" />
</div>
EOT
};

subtest 'builds input with default value escaped' => sub {
    my $helper = _build_helper();

    is $helper->input('username', default => '<foo'), <<'EOT';
<div class="form-input">
    <input type="text" name="username" value="&lt;foo" />
</div>
EOT
};

subtest 'builds input with previously submitted value' => sub {
    my $helper = _build_helper(vars => {params => {username => 'foo'}});

    is $helper->input('username'), <<'EOT';
<div class="form-input">
    <input type="text" name="username" value="foo" />
</div>
EOT
};

subtest 'builds input with previously submitted value escaped' => sub {
    my $helper = _build_helper(vars => {params => {username => '<foo'}});

    is $helper->input('username'), <<'EOT';
<div class="form-input">
    <input type="text" name="username" value="&lt;foo" />
</div>
EOT
};

subtest 'builds input with error' => sub {
    my $helper = _build_helper(vars => {errors => {username => 'required'}});

    is $helper->input('username'), <<'EOT';
<div class="form-input">
    <input type="text" name="username" />
    <div class="error">required</div>
</div>
EOT
};

subtest 'builds input with additional tags' => sub {
    my $helper = _build_helper();

    is $helper->input('username', foo => 'bar'), <<'EOT';
<div class="form-input">
    <input type="text" name="username" foo="bar" />
</div>
EOT
};

subtest 'builds checkbox' => sub {
    my $helper = _build_helper();

    is $helper->checkbox('flag'), <<'EOT';
<div class="form-input">
    <input type="checkbox" name="flag" />
</div>
EOT
};

subtest 'builds checkbox with default' => sub {
    my $helper = _build_helper();

    is $helper->checkbox('flag', default => 1), <<'EOT';
<div class="form-input">
    <input type="checkbox" name="flag" checked="checked" />
</div>
EOT
};

subtest 'builds checkbox with previously submitted' => sub {
    my $helper = _build_helper(vars => {params => {flag => 1, submit => 1}});

    is $helper->checkbox('flag'), <<'EOT';
<div class="form-input">
    <input type="checkbox" name="flag" checked="checked" />
</div>
EOT
};

subtest 'builds simple select' => sub {
    my $helper = _build_helper();

    is $helper->select('name', options => [foo => 'bar']), <<'EOT';
<div class="form-input">
    <select name="name">
        <option value="foo">bar</option>
    </select>
</div>
EOT
};

subtest 'builds simple select with label' => sub {
    my $helper = _build_helper();

    is $helper->select('name', label => 'Choose', options => [foo => 'bar']),
      <<'EOT';
<div class="form-input">
    <label>Choose</label><br />
    <select name="name">
        <option value="foo">bar</option>
    </select>
</div>
EOT
};

subtest 'builds simple select with default' => sub {
    my $helper = _build_helper();

    is $helper->select(
        'name',
        options  => [foo => 'bar', bar => 'baz'],
        multiple => 1,
        default => ['foo', 'bar']
      ),
      <<'EOT';
<div class="form-input">
    <select name="name" multiple>
        <option value="foo" selected="selected">bar</option>
        <option value="bar" selected="selected">baz</option>
    </select>
</div>
EOT
};

subtest 'builds simple select with escaped default' => sub {
    my $helper = _build_helper();

    is $helper->select(
        'name',
        options  => ['>foo' => '<bar', bar => 'baz'],
        default => '>foo'
      ),
      <<'EOT';
<div class="form-input">
    <select name="name">
        <option value="&gt;foo" selected="selected">&lt;bar</option>
        <option value="bar">baz</option>
    </select>
</div>
EOT
};

subtest 'builds simple select with error' => sub {
    my $helper = _build_helper(vars => {errors => {name => 'required'}});

    is $helper->select('name', options => [foo => 'bar', bar => 'baz']),
      <<'EOT';
<div class="form-input">
    <select name="name">
        <option value="foo">bar</option>
        <option value="bar">baz</option>
    </select>
    <div class="error">required</div>
</div>
EOT
};

subtest 'builds multiple select with default' => sub {
    my $helper = _build_helper();

    is $helper->select(
        'name',
        options => [foo => 'bar', bar => 'baz'],
        default => 'bar'
      ),
      <<'EOT';
<div class="form-input">
    <select name="name">
        <option value="foo">bar</option>
        <option value="bar" selected="selected">baz</option>
    </select>
</div>
EOT
};

subtest 'builds simple select with submitted value' => sub {
    my $helper = _build_helper(vars => {params => {name => 'foo'}});

    is $helper->select(
        'name',
        options => [foo => 'bar', bar => 'baz'],
        default => 'baz'
      ),
      <<'EOT';
<div class="form-input">
    <select name="name">
        <option value="foo" selected="selected">bar</option>
        <option value="bar">baz</option>
    </select>
</div>
EOT
};

subtest 'builds simple select with submitted escaped value' => sub {
    my $helper = _build_helper(vars => {params => {name => '<foo'}});

    is $helper->select(
        'name',
        options => ['<foo' => 'bar', bar => 'baz'],
        default => 'baz'
      ),
      <<'EOT';
<div class="form-input">
    <select name="name">
        <option value="&lt;foo" selected="selected">bar</option>
        <option value="bar">baz</option>
    </select>
</div>
EOT
};

subtest 'builds multiple select with submitted value' => sub {
    my $helper = _build_helper(vars => {params => {name => ['foo', 'bar']}});

    is $helper->select(
        'name',
        multiple => 1,
        options  => [foo => 'bar', bar => 'baz'],
        default  => 'baz'
      ),
      <<'EOT';
<div class="form-input">
    <select name="name" multiple>
        <option value="foo" selected="selected">bar</option>
        <option value="bar" selected="selected">baz</option>
    </select>
</div>
EOT
};

my $env;

sub _build_helper {
    my (%params) = @_;

    my $vars = delete $params{vars} || {};
    $env = $params{env} || TestRequest->to_env(%params);
    $env->{'tu.displayer.vars'} = $vars;

    return Toks::Helper::Form->new(env => $env);
}

done_testing;
