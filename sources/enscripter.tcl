#!/usr/local/bin/tclsh8.4

# Tcl code that calls 'enscript' to generate HTML files from Tcl
# source code.

# Usage:

# enscripter.tcl destination_directory ?source_directory?

# destination directory is a directory that the script will create and
# populate with HTML representations (where appropriate) of files
# within the source_directory.

# source directory is the location from which files are to be pulled.
# Default is "."

# David N. Welton <davidw@dedasys.com>

# taken from tcllib
proc find {{basedir .} {filtercmd {}}} {
    set filenames [glob -nocomplain $basedir/* $basedir/.*]
    set files {}
    set filt [string length $filtercmd]
    # If we don't remove . and .. from the file list, we'll get stuck in
    # an infinite loop in an infinite loop in an infinite loop in an inf...
    foreach special [list "." ".."] {
	set index [lsearch -exact $filenames [ file join $basedir $special ] ]
	set filenames [lreplace $filenames $index $index]
    }
    foreach filename $filenames {
	# Use uplevel to eval the command, not eval, so that variable 
	# substitutions occur in the right context.
	if {!$filt || [uplevel $filtercmd [list $filename]]} {
	    lappend files $filename
	}
	if {[file isdirectory $filename]} {
	    set files [concat $files [find $filename $filtercmd]]
	}
    }
    return $files
}

# gettype - takes a filename as its argument, and returns the 'type'.
# to get a list of available types, do: enscript --help-pretty-print

proc gettype { filename } {
    set ext [ file extension $filename ]
    set type ""
    switch $ext {
	.tcl { set type tcl }
	.ws3 { set type tcl }
	.test { set type tcl }     
	.html { set type html }
	.xml { set type passthrough }
	.xsl { set type passthrough }
	.ttml { set type passthrough }
	.rvt { set type passthrough }
	.c { set type c }
	.h { set type c }
	.pl { set type perl }
	.sh { set type sh }
	.scm { set type scheme }
	.m4 { set type m4 }
    }
    switch $filename {
	Makefile { set type makefile }
	ChangeLog { set type changelog } 
    }
    return $type
}

proc stylesheet { } {
    return {
	<style type="text/css">
	P, TD, OL, UL, MENU, BLOCKQUOTE, DIV
	{
	    font-family: Arial,Geneva,Helvetica,sans-serif;
	}
	body
	{	    
	    font-family: Arial,Geneva,Helvetica,sans-serif;
	    background-color: #ffffff;
	}
	</style>
    }
}

proc makeindex { dir filelist } {
    array set files $filelist
    set oput [ open [file join $dir index.html] w ]
    puts $oput [ format { <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
    <head>
    <title>%s</title>
    %s
    </head>
    <body> } $dir [ stylesheet ] ]

    foreach fl [lsort [array names files] ] {
	if { $files($fl) != "" } {
	    # it has an HTML extension
	    set fullname "${fl}.html"
	} else {
	    set fullname "$fl"
	}
	if { [file isdirectory $fullname] } {
	    puts $oput [ format {<a href="%s">%s/</a><br>} [file tail $fullname] [file tail $fl] ]
	} else {
	    puts $oput [ format {<a href="%s">%s</a><br>} [file tail $fullname] [file tail $fl] ]
	}
    }
    
    puts $oput {
	<p>
	Created with enscripter.tcl, available at <a href="http://www.dedasys.com/freesoftware/">http://www.dedasys.com/freesoftware/</a>
	</p>
	</body>
	</html>
    }
    close $oput
}

# go to beginning directory, get filenames, go to destination
# directory

proc main { argv } {
    set cwd [pwd]
    set argvlen [ llength $argv ]
    # start in this directory - default is current
    set start .
    if { $argvlen == 1 } {
	set start .
    } elseif { $argvlen == 2 } {
	set start [ lindex $argv 1 ]
    } else {
	puts stderr {
	    Usage: enscript.tcl destination_directory ?start_directory?
	    exit 1
	}	
    }
	
    set dest [ lindex $argv 0 ]
    if { ! [ file isdirectory $dest ] } {
	file mkdir $dest
    }
    
    cd $start
    set files [ find . {} ]
    set startdir [pwd]
    cd $cwd
    cd $dest
    set destdir [pwd]

    foreach fl $files {
	set origin [ file join $startdir $fl ]
	# eliminate files mentioning CVS
	if { [ string first CVS $fl ] != -1 } {
	    continue
	}
	
	if { [ file isdirectory $origin ] } {
	    file mkdir $fl
	    continue
	} 

	lappend fllist $fl
	set type ""
	set type [ gettype $fl ]

	if { $type != "" } {
	    cd $startdir
	    catch {
		exec enscript -h -B -t [ file tail $fl ] --color "-E$type" -B \
			-W html -o [ file join $destdir ${fl}.html ] $fl
	    } err
	    puts $err
	    cd $destdir
	} else {
	    file copy -force $origin $fl 
	}
    }

    # organize directories and files
    lappend dirlist .
    foreach fl $files {
	if { [ string first CVS $fl ] != -1 } {
	    continue
	}

	if { [ file isdirectory $fl ] } {
	    lappend dirlist $fl
	    array set $fl {}
	    set ${fl}(..) ""
	}
	set [file dirname $fl]($fl) [gettype $fl]
    }
    foreach dir $dirlist {
	makeindex $dir [ array get $dir ]
    }
}

main $argv
