# -----------------------------------------------------------------------------
# syp2txt - plug-in for syp: convert to text
# nca-115-2
# $Id$
# -----------------------------------------------------------------------------

set _syp_mode TXT

# ----------------------------------------------------------------------------
# tags
# ----------------------------------------------------------------------------
proc boldify {tmp} {return  "$tmp"}
proc italicify {tmp} {return  "$tmp"}
proc preify {tmp} {return  "$tmp"}
proc newLine {} {return "\n"}
proc hrefify {tmp {t2 ""}} {
    if { "$t2" == "" } { set t2 $tmp }
    return  "$tmp"
}

# ----------------------------------------------------------------------------
# default processors
# ----------------------------------------------------------------------------
proc procH {type str {aName ""}} {

    if {[string equal $type "h1"]} {
	set symb "="
    } elseif {[string equal $type "h2"]} {
	set symb "-"
    } elseif {[string equal $type "h3"]} {
	set symb "."
    }
    
    puts "$str"
    for {set i 0} {$i < [string length $str]} {incr i} {
        puts -nonewline "$symb"
    }
    puts ""
    puts ""
}

proc procH1 {str {aName ""}} { procH h1 $str $aName }
proc procH2 {str {aName ""}} { procH h2 $str $aName }
proc procH3 {str {aName ""}} { procH h3 $str $aName }

proc procList {type item vStr vState {isItem 0}} {
    upvar $vStr str
    upvar $vState state

    if {$state == 0} {
	set state 1
	set isItem 1
    }  elseif {$state == 2} {
	set state 0
	return
    }
    if {$isItem } {
	puts "$item $str"
    } else {
	puts "$str"
    }
}

proc procItemize {vStr vState {isItem 0}} {
    upvar $vStr str
    upvar $vState state
    return [procList "" * str state $isItem]
}

proc procEnum {vStr vState {isItem 0}} {
    upvar $vStr str
    upvar $vState state
    global _enumcnt

    if {$state == 0} {set _enumcnt 0} 

    return [procList "" "$_enumcnt." str state $isItem]
}

proc procDesc {vStr vState {isDesc 0}} {
    upvar $vStr str
    upvar $vState state

    if {$state == 0} {
	set state 1
	set isDesc 1
    } elseif {$state == 2} {
	set state 0
	return
    }
    if {$isDesc } {
	puts "$str:"
    } else {
	puts "  $str"
    }
}

proc procPre {vStr vState} {
    upvar $vStr str
    upvar $vState state

    if {$state == 0} {
	puts "$str"
	set state 1
	return
    }  elseif {$state == 2} {
	puts "$str"
	set state 0
	return
    }
}

proc procTable {vStr vState} {
    upvar $vStr str
    upvar $vState state
    global _sypTableRow

    set cols [split $str {|}]

    if {$state == 0} {
	foreach col $cols {
	    puts "[boldify [string trim $col]]"
	}
	set state 1
	set _sypTableRow 1
	return
    }  elseif {$state == 2} {
	set state 0
	return
    }
    if {$_sypTableRow} {
	set _sypTableRow 0
    } else {
	set _sypTableRow 1
    }

    foreach col $cols {
	puts "[string trim $col]"
    }
}

proc procPara {} {
    puts [newLine]
}

proc procFigRef {id} {
    return "Figure [findFigRef $id]"
}

proc procFigure {id url shortdesc caption} {

    set tmp [procFigRef $id]

    puts "\[Figure $shortdesc ($url)\]"
    puts "$tmp - $caption"
}

proc procIndex {{title ""} {anchor ""}} {

    global _sypidx

    if {[string length $title] < 1} { set title "index" }
    if {[string length $anchor] < 1} { set anchor $title }

    if { [info exists _sypidx] } {

        procPara
	procH1 $title $anchor
	set i 0

        foreach ent $_sypidx {

	    set type [lindex $ent 0]
	    set link [lindex $ent 1]
	    set text [lindex $ent 2]

	    if {[string equal $type "h1"] || [string equal $type "h2"] } {

		if { [string compare $type "h2"] == 0 } {
		    puts -nonewline "  -"
		} else {
		    puts -nonewline "$i "
		    incr i
		}
		puts "$text"
	    }
	}
    }
}

proc conformify {in} { return $in }
