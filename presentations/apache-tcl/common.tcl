file stat [info script] statinfo

if { ! [info exists ::mtime] || $::mtime < $statinfo(mtime) } {
    proc ::getorder { } {
	set fl [open order.txt]
	set data [split [read $fl] \n]
	close $fl
	foreach ln $data {
	    lappend ret [string trim $ln]
	}

	return $ret
    }

    proc ::makeindex {} {
	puts "<ul>"
	foreach fl [getorder] {
	    set flttml "$fl.ttml"
	    puts [subst {
		<li style="font-size:small ; list-style-type:square ; list-style-image: none"><a href="$flttml">$fl</a></li>
	    }]
	}
	puts "</ul>"
    }

    proc ::nexturl { } {
	return "[lindex $::urls $::next].ttml?index=$::next"
    }

    proc ::prevurl { } {
	return "[lindex $::urls $::prev].ttml?index=$::prev"
    }

    proc ::prevnext { title } {
	hgetvars
	set ::urls [getorder]
	if { [var exists index] } {
	    set ::index [var get index]
	} else {
	    set ::index 0
	}

	set ::next [expr $::index + 1]
	set ::prev [expr $::index - 1]
	if { $::next >= [llength $::urls] } {
	    incr ::next -1
	}
	if { $::prev < 0 } {
	    incr ::prev
	}

	set str {
	    <table align="center" width="90%">
	    <tr>
	    <td align="left">
	    <a href="[prevurl]"><img src="left.png" alt="previous"></a>
	    </td>
	    <td align="center">
	    $title
	    </td>
	    <td align="right">
	    <a href="[nexturl]"><img src="right.png" alt="next"></a>
	    </td>
	    </tr>
	    </table>
	}
	puts [subst $str]
    }

    proc ::footer {} {
	puts {
	    <p align="center" style="font-size:small">
	    <a href="list.ttml">INDEX</a>
	    </p>
	}
    }

    set ::mtime $statinfo(mtime)
}