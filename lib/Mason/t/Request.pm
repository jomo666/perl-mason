package Mason::t::Request;
use Test::More;
use strict;
use warnings;
use base qw(Mason::Test::Class);

sub _get_current_comp_class {
    my $m = shift;
    return $m->_current_comp_class;
}

sub test_comp_exists : Test(1) {
    my $self = shift;

    $self->add_comp( path => '/comp_exists/one.m', component => 'hi' );
    $self->test_comp(
        path      => '/comp_exists/two.m',
        component => '
% foreach my $path (qw(/comp_exists/one.m /comp_exists/two.m /comp_exists/three.m one.m two.m three.m)) {
<% $path %>: <% $m->comp_exists($path) ? "yes" : "no" %>
% }
',
        expect => '
/comp_exists/one.m: yes
/comp_exists/two.m: yes
/comp_exists/three.m: no
one.m: yes
two.m: yes
three.m: no
',
    );
}

sub test_current_comp_class : Test(1) {
    shift->test_comp(
        path      => '/current_comp_class.m',
        component => '<% ' . __PACKAGE__ . '::_get_current_comp_class($m)->comp_path %>',
        expect    => '/current_comp_class.m'
    );
}

sub test_count : Test(3) {
    my $self = shift;
    $self->setup_dirs;
    $self->add_comp( path => '/count.m', component => 'count=<% $m->count %>' );
    is( $self->{interp}->srun('/count'), "count=0" );
    is( $self->{interp}->srun('/count'), "count=1" );
    is( $self->{interp}->srun('/count'), "count=2" );
}

sub test_page : Test(1) {
    my $self = shift;
    $self->add_comp( path => '/page/other.mi', component => '<% $m->page->comp_title %>' );
    $self->test_comp(
        path      => '/page/first.m',
        component => '<% $m->page->comp_title %>; <& other.mi &>',
        expect    => '/page/first.m; /page/first.m'
    );
}

sub test_subrequest : Test(2) {
    my $self = shift;
    $self->add_comp(
        path      => '/subreq/other.m',
        component => '
<% $m->page->comp_title %>
<% $m->request_path %>
<% join(", ", @{ $m->request_args }) %>
',
    );
    $self->test_comp(
        path      => '/subreq/go.m',
        component => '
This should not get printed.
<%perl>$m->go("/subreq/other", foo => 5);</%perl>',
        expect => '
/subreq/other.m
/subreq/other
foo, 5
',
    );
    $self->test_comp(
        path      => '/subreq/visit.m',
        component => '
begin
<%perl>$m->visit("/subreq/other", foo => 5);</%perl>
end
',
        expect => '
begin
/subreq/other.m
/subreq/other
foo, 5
end
',
    );

}

1;