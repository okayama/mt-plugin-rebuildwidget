package MT::Plugin::RebuildWidget;
use strict;
use MT;
use MT::Plugin;
use base qw( MT::Plugin );

use MT::Util qw( encode_html );

our $VERSION = '1.0';

my $plugin = MT::Plugin::RebuildWidget->new( {
    id => 'RebuildWidget',
    key => 'rebuildwidget',
    description => '<MT_TRANS phrase=\'_PLUGIN_DESCRIPTION\'>',
    name => 'RebuildWidget',
    author_name => 'okayama',
    author_link => 'http://weeeblog.net/',
    version => $VERSION,
    l10n_class => 'MT::RebuildWidget::L10N',
} );
MT->add_plugin( $plugin );

sub init_registry {
    my $plugin = shift;
    $plugin->registry( {
        callbacks => {
            'MT::App::CMS::template_param.edit_template'
                => \&_cb_tp_edit_template,
        },
   } );
}

sub _cb_tp_edit_template {
    my ( $cb, $app, $param, $tmpl ) = @_;
    if ( my $blog = $app->blog ) {
        if ( $blog->class eq 'website' ) {
            my $show_widget = 0;
            my $pointer = $tmpl->getElementById( 'useful-links' );
            my $nodeset = $tmpl->createElement ( 'app:widget', { id => 'rebuild_list', 
                                                                 label => MT->translate( '_REBUILD_PUBLISH' ),
                                                                 label_class => 'top-label',
                                                               }
                                               );
            my $innerHTML = '<div class="textarea-wrapper">' . "\n";
            $innerHTML .= '<ul>' . "\n";
            if ( _show_rebuild( $blog ) ) {
                $innerHTML .= '<li><a href="<$mt:var name="mt_url"$>?__mode=rebuild_confirm&blog_id=' . $blog->id . '" class="icon-left icon-related mt-rebuild" title="<__trans phrase="Publish Site">">' . "\n";
                $innerHTML .= encode_html( $blog->name ) . "\n";
                $innerHTML .= '</a></li>' . "\n";
                $show_widget++;
            }
                my @children_blogs = MT->model( 'blog' )->load( { parent_id => $blog->id,
                                                                  class => 'blog',
                                                                }
                                                              );
                if ( @children_blogs ) {
                    for my $child_blog ( @children_blogs ) {
                        if ( _show_rebuild( $child_blog ) ) {
                            $innerHTML .= '<li><a href="<$mt:var name="mt_url"$>?__mode=rebuild_confirm&blog_id=' . $child_blog->id . '" class="icon-left icon-related mt-rebuild" title="<__trans phrase="Publish Site">">' . "\n";
                            $innerHTML .= encode_html( $child_blog->name ) . "\n";
                            $innerHTML .= '</a></li>' . "\n";
                            $show_widget++;
                        }
                    }
                }
            $innerHTML .= '</ul>' . "\n";
            $innerHTML .= '</div>' . "\n";
            $nodeset->innerHTML( $innerHTML );
            if ( $show_widget ) {
                $tmpl->insertAfter( $nodeset, $pointer );
            }
        }
    }
}

sub _show_rebuild {
    my ( $blog ) = @_;
    return 0 unless $blog;
    if ( _has_rebuild_permission( $blog ) && ! _is_dynamic( $blog ) ) {
        return 1;
    }
    return 0;
}

sub _has_rebuild_permission {
    my ( $blog ) = @_;
    return 0 unless $blog;
    my $app = MT->instance;
    my $user = $app->user or return 0;
    if ( $user->is_superuser ) {
        return 1;
    } elsif ( my $perms = $app->permissions( $user->permissions( $blog->id ) ) ) {
        if ( $perms->can_rebuild ) {
            return 1;
        }
    }
    return 0;
}

sub _is_dynamic {
    my ( $blog ) = @_;
    return 0 unless $blog;
    if ( $blog->custom_dynamic_templates eq 'all' ) {
        return 1;
    }
    return 0;
}

1;