package InstantTag;
use strict;

sub _hdlr_instant_tag {
    my ($ctx, $args, $cond) = @_;

    my $tokens = $ctx->stash('tokens');
    my $builder = $ctx->stash('builder');

    my $out = $builder->build($ctx, $tokens, $cond)
            || return $ctx->error($builder->errstr);

    my $hdlr = eval $out;
    return $ctx->error("can't eval subroutine **name=$args->{name}** in mt:instanttags: $@") if ($@);

    my $instanttags = $ctx->stash('__instanttags') || {};

    if ($args->{name}) {
        $instanttags->{$args->{name}} = $hdlr;
        $ctx->stash('__instanttags', $instanttags);
    }
    else {
        $instanttags->{__anonymous} = $hdlr;
        $ctx->stash('__instanttags', $instanttags);
    }

    return;
}

sub _hdlr_call {
    my ($ctx, $args) = @_;

    my $instanttags = $ctx->stash('__instanttags') || undef;

    return $ctx->error("not exists are defined mt:instanttags.") unless $instanttags;

    if ($args->{caller}) {
        return $instanttags->{$args->{caller}}->(@_) if ($instanttags->{$args->{caller}});
        return $ctx->error("can't find **caller=$args->{caller}**.");
    }

    return $instanttags->{__anonymous}->(@_) if $instanttags->{__anonymous};
    return $ctx->error("can't find **caller=__anonymouse**.");
}

1;
