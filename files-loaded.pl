    #!/usr/bin/perl -W

    # author : hardball
    # version : v20160919-01
    # description :
    #   recherche recursivement dans les script nas et les fichiers xml et ac d'autres
    #   fichiers nas, xml, wav et png charges

    use Term::ANSIColor ;

    #===============================================================================
    #                                                                     CONSTANTES

    # nom du repertoire de l'aeronef
    $dirname_aircraft = 'bourrasque' ;

    # nom de l'aeronef (celui appele au lancement de fgfs)
    $aircraft = 'bourrasque' ;

    # chemin de depart pour la recherche recursive
    $dirpath_root = '/home/nico/Dropbox/documents/home/games/projet_fgfs/hangar/'. $dirname_aircraft .'/' ; # slash ending

    $color{'xml'} = 'bright_blue' ;
    $color{'ac'}  = 'bright_yellow' ;
    $color{'png'} = 'bright_magenta' ;
    $color{'rvb'} = 'red' ;
    $color{'nas'} = 'yellow' ;
    $color{'wav'} = 'white' ;

    #===============================================================================
    #                                                   INITIALISATION DES VARIABLES

    my @a = () ;

    #===============================================================================
    #                                                                      FONCTIONS

    # affiche le resultat sous forme arborescente
    sub recherche_tree
    {
        my ($path, $depth, $from_path, $from_file, $list_is_last) = @_ ;
        my $indent = '' ;
        my @lil = @{$list_is_last} ; # contient pour chaque fichier parent de l'item
                                     # en cours si c'est le dernier de la liste
        for(my $l = 0 ; $l < @lil ; $l++)
        {
            # item en cours
            if($l == (@lil - 1))
            {
                $indent .= $lil[$l]
                    ? ' `-- '
                    : ' |-- ' ;
            }
            # parents
            else
            {
                $indent .= $lil[$l]
                    ? '     '
                    : ' |   ' ;
            }
        }
        $path =~ s/^\/?Aircraft\/$dirname_aircraft\/// ;
        $path =~ s/^.\/// ;
        if($path !~ /\//)
        {
            $path = $from_path . $path ;
        }
        $path_to_try = $dirpath_root . $path ;
        if(-f $path_to_try)
        {
            $from_file = $path ;

            my ($ext) = ($from_file =~ /\.(\w+)$/) ;
            print "${indent}" ;
            print color $color{$ext} ;
            print ${from_file} ;
            print color 'reset' ;
            print "\n" ;

            #print "${indent}${from_file}\n" ;
            if($path_to_try =~ /.xml$/)
            {
                $depth++;
                $from_path = $path ;
                $from_path =~ s/[^\/]+$// ;
                my @f = () ;
                open(my $XML, $path_to_try) ; my @XML = <$XML> ; close $XML ;
                for(@XML)
                {
                    if((/>(.+\.(xml|nas|ac|wav))</)
                        or (/=["'](.+\.(xml|nas|ac|wav))["']/))
                    {
                        push(@f, $1) ;
                    }
                }
                for(my $i = 0 ; $i < @f ; $i++)
                {
                    $path = $f[$i] ;
                    my $l = ($i < (@f - 1)) ? 0 : 1 ;
                    push(@lil, $l) ;
                    recherche_tree($path, $depth, $from_path, $from_file, \@lil) ;
                    pop(@lil) ;
                }
            }
            elsif($path_to_try =~ /.nas$/)
            {
                $depth++;
                $from_path = $path ;
                $from_path =~ s/[^\/]+$// ;
                my @f = () ;
                open(my $NAS, $path_to_try) ; my @NAS = <$NAS> ; close $NAS ;
                for(@NAS)
                {
                    if(/["']([^"']+$dirname_aircraft\/[^"']+\.(xml|nas))["']/)
                    {
                        push(@f, $1) ;
                    }
                }
                for(my $i = 0 ; $i < @f ; $i++)
                {
                    $path = $f[$i] ;
                    my $l = ($i < (@f - 1)) ? 0 : 1 ;
                    push(@lil, $l) ;
                    recherche_tree($path, $depth, $from_path, $from_file, \@lil) ;
                    pop(@lil) ;
                }
            }
            elsif($path_to_try =~ /.ac$/)
            {
                $depth++;
                $from_path = $path ;
                $from_path =~ s/[^\/]+$// ;
                my @f = () ;
                my %uniq_f = () ;
                open(my $AC, $path_to_try) ; my @AC = <$AC> ; close $AC ;
                for(@AC)
                {
                    if(/texture\s+["'](.+\.(png|rvb))/)
                    {
                        $uniq_f{$1} = 1 ;
                    }
                }
                @f = sort keys %uniq_f ;
                for(my $i = 0 ; $i < @f ; $i++)
                {
                    $path = $f[$i] ;
                    my $l = ($i < (@f - 1)) ? 0 : 1 ;
                    push(@lil, $l) ;
                    recherche_tree($path, $depth, $from_path, $from_file, \@lil) ;
                    pop(@lil) ;
                }
            }
            else
            {
                pop(@lil) ;
            }
        }
        else
        {
            print STDERR "[W] file not found : SKIPPING - $path -- $from_file\n" ;
        }
    }

    sub recherche
    {
        my ($path, $depth, $from_path, $from_file) = @_ ;
        $path =~ s/^\/?Aircraft\/$dirname_aircraft\/// ;
        $path =~ s/^.\/// ;
        if($path !~ /\//)
        {
            $path = $from_path . $path ;
        }
        $path_to_try = $dirpath_root . $path ;
        if(-f $path_to_try)
        {
            $from_file = $path ;
            print "$path_to_try\n" ;
            if($path_to_try =~ /.xml$/)
            {
                $depth++;
                $from_path = $path ;
                $from_path =~ s/[^\/]+$// ;
                open(my $XML, $path_to_try) ; my @XML = <$XML> ; close $XML ;
                for(@XML)
                {
                    if((/>(.+\.(xml|nas))</)
                        or (/=["'](.+\.(xml|nas))["']/))
                    {
                        recherche($1, $depth, $from_path, $from_file) ;
                    }
                }
            }
            elsif($path_to_try =~ /.nas$/)
            {
                $depth++;
                $from_path = $path ;
                $from_path =~ s/[^\/]+$// ;
                open(my $NAS, $path_to_try) ; my @NAS = <$NAS> ; close $NAS ;
                for(@NAS)
                {
                    if(/["']([^"']+$dirname_aircraft\/[^"']+\.(xml|nas))["']/)
                    {
                        recherche($1, $depth, $from_path, $from_file) ;
                    }
                }
            }
        }
    }

    #===============================================================================
    #                                                                           MAIN


    recherche_tree($aircraft. '-set.xml', 0, '', '', \@a) ;

    ### EOF
