#!/usr/local/bin/tclsh8.3

# install.tcl -- helper for install
# nca-115-2
# $Id$

# usage: install.tcl src dest chmod

if {$argc != 3} {
    puts "($argc) usage: install.tcl src dest chmod"
    exit 1
}
set src [lindex $argv 0]
set dest [lindex $argv 1]
set chmod [lindex $argv 2]

set doInstall 0

if { ![file exists $src] } {
    puts "install.tcl - $src does not exist - skip"
    return
}


if { [file exists $dest] } {

    if {[file mtime $src] > [file mtime $dest]} {

	file delete $dest
	set doInstall 1
    }
} else {

    set doInstall 1
    if { ![file exists [file dirname $dest]] } {
	puts "install.tcl - making [file dirname $dest]"
	file mkdir [file dirname $dest]
    }
}

if {$doInstall} {

    puts -nonewline "install.tcl - installing $dest ... "
    file copy $src $dest
    file attributes $dest -permissions $chmod
    puts "done"
}
