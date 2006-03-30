#!/usr/local/bin/tclsh8.4

set env(PATH) "$env(PATH):/usr/local/bin/"

set trees [list tcl tcl-moddtcl tcl-modtcl tcl-rivet tcl-websh]

set dir /home/tclwww/install/tcl-site/sources
cd $dir

# update cvs trees

cd cvstrees
set dir2 [pwd]
foreach tree $trees {
    cd $tree
    puts "$dir2 : $tree"
    catch {
	exec cvs update -d
    } oput
    puts $oput
    cd $dir2
}

# run enscripter.tcl

cd $dir
foreach tree $trees {
    puts "$tree"
    catch {
	exec [file join [pwd] enscripter.tcl] $tree [file join cvstrees $tree]
    } oput	
    puts $oput
    exec chmod -R o+r $tree
}
