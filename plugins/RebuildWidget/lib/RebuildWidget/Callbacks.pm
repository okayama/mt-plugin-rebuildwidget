package RebuildWidget::Callbacks;
use strict;

use MT::Util qw( encode_html );
use RebuildWidget::Util;

sub _cb_tp_edit_template {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $plugin = MT->component( 'RebuildWidget' );
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
            if ( RebuildWidget::Util::show_rebuild( $blog ) ) {
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
                    if ( RebuildWidget::Util::show_rebuild( $child_blog ) ) {
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

1;
