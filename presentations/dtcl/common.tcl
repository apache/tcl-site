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

    proc ::nexturl { } {
	return "[lindex $::urls $::next].rvt?index=$::next"
    }

    proc ::prevurl { } {
	return "[lindex $::urls $::prev].rvt?index=$::prev"
    }

    proc ::prevnext { title } {
	set ::urls [getorder]
	if { [var exists index] } {
	    set ::index [var get index]
	    if { ! [string is integer $::index] } {
		error "Index must be a number!"
	    }
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
	    <a href="[prevurl]"><img src="prev.png" alt="previous"></a>
	    </td>
	    <td align="center">
	    $title
	    </td>
	    <td align="right">
	    <a href="[nexturl]"><img src="next.png" alt="next"></a>
	    </td>
	    </tr>
	    </table>
	}
	puts [subst $str]
    }
    set ::mtime $statinfo(mtime)
} 



