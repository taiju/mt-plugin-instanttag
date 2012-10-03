package InstantTag;
use strict;
use Data::Dumper;

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

    unless ($instanttags) {
        return $ctx->error("not exists are defined mt:instanttags.");
    }

    if ($args->{caller}) {
        if ($instanttags->{$args->{caller}}) {
            return $instanttags->{$args->{caller}}->(@_);
        }
        else {
            return $ctx->error("can't find **caller=$args->{caller}**.");
        }
    }
    else {
        if ($instanttags->{__anonymous}) {
            return $instanttags->{__anonymous}->(@_);
        }
        else {
            return $ctx->error("can't find **caller=__anonymouse**.");
        }
    }
}

1;
