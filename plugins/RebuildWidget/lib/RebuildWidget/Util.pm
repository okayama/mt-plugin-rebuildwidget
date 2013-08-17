package RebuildWidget::Util;
use strict;

sub show_rebuild {
    my ( $blog ) = @_;
    return 0 unless $blog;
    my $app = MT->instance();
    if ( has_rebuild_permission( $app->user, $blog ) && ! is_dynamic( $blog ) ) {
        return 1;
    }
    return 0;
}

sub has_rebuild_permission {
    my ( $author, $blog ) = @_;
    return 0 unless $author;
    return 0 unless $blog;
    if ( $author->is_superuser ) {
        return 1;
    } elsif ( my $perms = $author->permissions( $blog->id ) ) {
        if ( $perms->can_rebuild ) {
            return 1;
        }
    }
    return 0;
}

sub is_dynamic {
    my ( $blog ) = @_;
    return 0 unless $blog;
    if ( $blog->custom_dynamic_templates eq 'all' ) {
        return 1;
    }
    return 0;
}

1;
