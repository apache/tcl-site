# -----------------------------------------------------------------------------
# syp - simple yet powerful text processor
# nca-115-2
#
#
# $Id$
# -----------------------------------------------------------------------------

# == what is syp ? ==
#
# -- The idea --
#
# ==* easy to use through implicit syntax (no end tags)
# ==* eye-catching, intuitive syntax
# ==* multi-format output (HTML,txt,rtf,docbook)
#
# -- the tags --
#
# ==* headers:
#     ==* == h1 ==
#     ==* -- h2 --
#     ==* .. h3 ..
# ==* lists:
#     ==* ==* unordered list
#     ==* ==1 ordered list
#     ==* ==D description list
# ==* formatting
#     ==* =\=\preformatted\=\=
#     ==* =\=|bold|=\=
#     ==* =\=/italic/=\=
# ==* misc
#     ==* =\=(URL)(text)=\= for links
#     ==* =\==Figure==anchor==path\= for figures
#     ==* =\==>anchor\= for references
#     ==* =\==T\= for tables
#     ==* =\--- \= for pre-formatted text


set _syp_mode HTML
set _syp_title TITLE
set _template ""

# ----------------------------------------------------------------------------
# index
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# utils
# ----------------------------------------------------------------------------
proc fputs {str} {
    global _ofh
    puts $_ofh $str
}

# ----------------------------------------------------------------------------
# tags
# ----------------------------------------------------------------------------
proc boldify {tmp} {return  "<b>$tmp</b>"}
proc italicify {tmp} {return  "<i>$tmp</i>"}
proc preify {tmp} {return  "<tt>$tmp</tt>"}
proc newLine {} {return "<br>"}
proc hrefify {tmp {t2 {}}} {
    if { "$t2" == "" } { set t2 $tmp }
    return  "<a href=\"$tmp\">$t2</a>"
}

# ----------------------------------------------------------------------------
# default processors
# ----------------------------------------------------------------------------
proc procH {type str} {
    global _anchors
    global _filename
    global _linecnt
    global _reverseAnchors

    set akey  [list ${_filename} $str $type ${_linecnt}]
    set aname  $_anchors($akey)
    set tocent $_reverseAnchors($akey)

    foreach {fn tit type line h1cnt h2cnt h3cnt} $tocent {}

    set cnt $h1cnt
    if { $h2cnt > 0 } {
	append cnt ".$h2cnt"
    }
    if { $h3cnt > 0 } {
	append cnt ".$h3cnt"
    }

    fputs "<a name=\"$aname\"><a href=\"\#toc\"><$type>$cnt $str</$type></a>"
}

proc procH1 {str} {
    procH h1 $str
}

proc procH2 {str} {
    procH h2 $str
}

proc procH3 {str} {
    procH h3 $str
}

proc procGenericListStart {type str} {

    global _level
    global _level_stack
    global _state

    fputs "<$type>"

    incr _level

    # puts "DBG genericListStart setting stack($_level) to $type"
    set _level_stack($_level) $type
    # puts "DBG genericListStart stack now: [array get _level_stack]"

    
    set _state $type

    procGenericList $str
}

proc procGenericListEnd {type} {

    global _level
    global _state

    fputs "</$type>"
    incr _level -1
    if {$_level == 0 } {
        set  _state ""
    }
}

proc procGenericList {str} {

    fputs "<li>$str</li>"
}

##

proc procItemizeStart {str} {

    return [procGenericListStart ul $str]
}

proc procItemizeEnd {} {

    return [procGenericListEnd ul]
}

proc procItemize {str} {

    return [procGenericList $str]
}

##

proc procEnumStart {str} {

    return [procGenericListStart ol $str]
}

proc procEnumEnd {} {

    return [procGenericListEnd ol]
}

proc procEnum {str} {

    return [procGenericList $str]
}

##

proc procDescStart {str} {

    global _level
    global _level_stack
    global _state

    fputs "<dl>"
    incr _level
    set  _state dl

    # puts "DBG descStart setting stack($_level) to dl"
    set _level_stack($_level) "dl"
    # puts "DBG descStart stack now: [array get _level_stack]"

    procDesc $str 1
}

proc procDescEnd {} {

    global _level
    global _state

    fputs "</dl>"
    incr _level -1
    if {$_level == 0 } {
        set  _state ""
    }
}

proc procDesc {str {isDesc 0}} {

    if {$isDesc } {
	fputs "<dt>[boldify $str]\n<dd>"
    } else {
	fputs "$str"
    }
}

proc endList {level} {

    global _level_stack

    # puts "DBG endList stack: [array get _level_stack]"
    # puts "DBG endList level: $level"

    if { [info exists _level_stack($level)] } {

        # puts "DBG endList: found $_level_stack($level)"

        switch $_level_stack($level) {
            ul {
                procItemizeEnd
                unset _level_stack($level)
            }
            ol {
                procEnumEnd
                unset _level_stack($level)
            }
            dl {
                procDescEnd
                unset _level_stack($level)
            }
        }
    } else {
        puts "DBG endList: level not found in stack"
    }

}

proc procPre {vStr vState} {


    upvar $vStr str
    upvar $vState state

    # puts "DBG procPre - got '$str'"

    if {$state == 0} {
	fputs "<pre>"
	fputs "$str"
	set state 1
	return
    }  elseif {$state == 2} {
	fputs "$str"
	fputs "</pre>"
	set state 0
	return
    }
}


proc procTable {vStr vState} {

    global _sypTableRow

    upvar $vStr str
    upvar $vState state

    set cols [split $str {|}]

    if {$state == 0} {
	# puts "<table border=\"1\">\n"
	fputs "<table>"
	fputs "<tr>"
	foreach col $cols {
	    fputs "  <td>[boldify [string trim $col]]</td>"
	}
	fputs "</tr>"
	set state 1
	set _sypTableRow 1
	return
    }  elseif {$state == 2} {
	fputs "</table>"
	set state 0
	return
    }
    if {$_sypTableRow} {
	fputs "<tr bgcolor=\"#99CCCC\">"
	set _sypTableRow 0
    } else {
	fputs "<tr bgcolor=\"#FFFFFF\">"
	set _sypTableRow 1
    }

    foreach col $cols {
	set tmp [string trim $col]
	if {[string length $tmp] < 1} {
	    set tmp "&nbsp;"
	}
	fputs "  <td>$tmp</td>"
    }
    fputs "</tr>"
}

proc procPara {} {

    fputs [newLine][newLine]
}


proc findFigRef {id} {
    set idx 1
    global _sypfig
    foreach tmp $_sypfig {
	set idinlist [lindex  $tmp 0]
	if { [string compare $id $idinlist] == 0 } {
	    return $idx
	}
	incr idx
    }
}

proc procFigRef {id} {
    return "Figure [findFigRef $id]"
}

proc procFigure {id url shortdesc caption} {

    set tmp [procFigRef $id]

    fputs "<center><img src=\"$url\" alt=\"$shortdesc\"></center><br>"
    fputs "[boldify $tmp] - $caption <br><br>"
}

proc procIndex {{title "Table of Contents"}} {

    global _toc
    global _anchors

    set isFirst 1

    if { [info exists _toc] } {

        fputs "<br>"

        procH1 $title

        foreach item $_toc {

            # puts stderr "toc: $item"

            # "${fn}:${res}:h1"
            foreach {fn tit type line h1cnt h2cnt h3cnt } $item {}

	    set anchorkey [list $fn $tit $type $line]

# 	    puts "DBG procIndex: key:      $anchorkey"
# 	    puts "DBG procIndex: item:     $item"
# 	    puts "DBG procIndex: _anchors: [array get _anchors]"

            set anc $_anchors($anchorkey)

	    # puts "DBG anc - $anc"

            if { [string equal $type h1] } {

                fputs "<br>${h1cnt}&nbsp;<a href=\"\#$anc\"><b>$tit</b></a><br>"

            } elseif { [string equal $type h2] } {
                
                fputs "&nbsp;&nbsp;&nbsp;&nbsp;${h1cnt}.${h2cnt} <a href=\"\#$anc\"><b>$tit</b></a><br>"

            } elseif { [string equal $type h3] } {

                fputs "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${h1cnt}.${h2cnt}.${h3cnt} <a href=\"\#$anc\"><b>$tit</b></a><br>"
            }
        }
    }
}

proc conformify {in} {

    if {[regexp {^%%%(.*)} $in]} {
	return $in
    } else {
	return [web::htmlify -- $in]
    }
}


# ----------------------------------------------------------------------------
# override default, if any
# ----------------------------------------------------------------------------
#TBD

# ----------------------------------------------------------------------------
# private methods
# ----------------------------------------------------------------------------

proc isH1 {line vTitle vAnchor} {
    upvar $vTitle  title
    upvar $vAnchor anchor

    set title {}
    set anchor {}

    if {[regexp {^== (.*)} $line dum rest] } {

        # puts "DBG starts correctly: rest $rest"

        if { [set first [string first " ==" $rest 0]] != -1 } {
            incr first -1
            set title [string range $rest 0 $first]
            incr first 4
            set anchor [string range $rest $first end]
            return 1
        }
    }
    return 0
}

proc isH2 {line vTitle vAnchor} {
    upvar $vTitle  title
    upvar $vAnchor anchor

    set title {}
    set anchor {}

    if {[regexp {^-- (.*)} $line dum rest] } {

        # puts "DBG starts correctly: rest $rest"

        if { [set first [string first " --" $rest 0]] != -1 } {
            incr first -1
            set title [string range $rest 0 $first]
            incr first 4
            set anchor [string range $rest $first end]
            return 1
        }
    }
    return 0
}

proc isH3 {line vTitle vAnchor} {
    upvar $vTitle  title
    upvar $vAnchor anchor

    set title {}
    set anchor {}

    if {[regexp {^\.\. (.*)} $line dum rest] } {

        # puts "DBG starts correctly: rest $rest"

        if { [set first [string first " .." $rest 0]] != -1 } {
            incr first -1
            set title [string range $rest 0 $first]
            incr first 4
            set anchor [string range $rest $first end]
            return 1
        }
    }
    return 0
}


# sypsub:
# suppose escape is "|":
# searches for "=|....|=" in txt, calls handler with argument "....", and
# replaces "...." with result from handler
#
# example: "a =|simple | text|= =|with|= a star"
proc sypsub {vTxt escape handler} {
    upvar $vTxt txt
    set idx 0
    set found 0
    while { [set first [string first "=$escape" $txt $idx]] != -1 } {
        # found one
        set idx $first
        incr idx
        if { [set next [string first "${escape}=" $txt $idx]] != -1 } {
            incr next
            set start $first
            set end   $next
            incr start 2
            incr end   -2
            set tmp [string range $txt $start $end]
            # puts "DBG sypsub - tmp: $tmp"
            set tmp [eval [list $handler $tmp]]
            set txt [string replace $txt $first $next $tmp]
            incr idx [string length $tmp]
            set found 1
        }
        # puts "DBG sypsub - txt now: $txt"
    }
    return $found
}

# _getNextInputLine
proc _getNextInputLine {fh} {

    global _prevLine
    global _curLine
    global _nextLine
    global _linecnt

    set _prevLine $_curLine
    set _curLine $_nextLine

    gets $fh _nextLine
    incr _linecnt

    #
    # make it output compliant (eg htmlify in HTML case)
    #
    set _nextLine [conformify $_nextLine]

    #
    # explicit newlines: "some text\\"
    #
    if { [regsub -all {\\\\$} $_curLine [newLine] tmp] } {
	set _curLine $tmp
    }
    
    #
    # text marked for bold: =*bold*=
    #
    sypsub _curLine "|" boldify

    #
    # text marked as pre-formatted: =%pre%=
    #
    sypsub _curLine "\\" preify

    #
    # text marked as italic: =/italic/=
    #
    sypsub _curLine "/" italicify

    #
    # an explicit link w/o text: "=(http://tcl.apache.org/websh)="
    #
    if { [regsub -all {\=\(([^\)]+)\)\=} $_curLine \
	      "[hrefify \\1]" tmp] } {
	set _curLine $tmp
    }

    #
    # an explicit link: "=(http://tcl.apache.org)(the cool tcl web site)="
    #
    if { [regsub -all {\=\(([^\)]+)\)\(([^\)]+)\)\=} $_curLine \
	      "[hrefify \\1 \\2]" tmp] } {
	set _curLine $tmp
    }
}


# _firstScan -- build list of figures and references
proc _firstScan {fn} {

    global _prevLine
    global _curLine
    global _prevLine
    global _anchors
    global _toc
    global _linecnt
    global _sypfig
    global _split_level
    global _split_first
    global _split_last
    global _reverseAnchors

    set _prevLine ""
    set _curLine ""
    set _nextLine ""
    set _linecnt 0

    set _doProcess 1

    set mySplitCnt 0

    set fh [open $fn "r"]

    ## first line
    if {[eof $fh] == 0} {gets $fh ::_nextLine}

    set h1cnt 0
    set h2cnt 0
    set h3cnt 0

    while {[eof $fh] == 0 && $_doProcess} {

	_getNextInputLine $fh

	set tLine $_curLine

	# gets $fh tLine
	if { [regexp {^%%%STOPPROCESSINGHERE} $_curLine dum res] } {
	    set _doProcess 0
	    continue
	} elseif {[regexp {^==Figure==([^=]*)==([^=]*)={0,2}(.*)} $tLine dum id url alt]
	    != 0 } {
	    # puts stderr "DBG -- found $tLine"
	    lappend _sypfig [list $id $url $alt]

	} elseif {[isH1 $tLine res aname] } {

	    incr h1cnt
	    set h2cnt 0
	    set h3cnt 0
	    

            if { ![string length $aname] } {
                set aname $_linecnt
            }

            if { $_split_level == 1 } {

                incr mySplitCnt

                set _split_last $mySplitCnt

                set aname "[splitFileName $mySplitCnt]\#${aname}"
            }

            set anchorkey [list ${fn} ${res} h1 ${_linecnt}]
            set tocent    [list ${fn} ${res} h1 ${_linecnt} $h1cnt $h2cnt $h3cnt]

            set _anchors($anchorkey) $aname
	    set _reverseAnchors($anchorkey) $tocent

            lappend _toc $tocent

	} elseif {[isH2 $tLine res aname] } {

	    incr h2cnt
	    set h3cnt 0

            if { ![string length $aname] } {
                set aname $_linecnt
            }
                
            set anchorkey [list ${fn} ${res} h2 ${_linecnt}]
            set tocent    [list ${fn} ${res} h2 ${_linecnt} $h1cnt $h2cnt $h3cnt]

            set _anchors($anchorkey) $aname
	    set _reverseAnchors($anchorkey) $tocent

            lappend _toc $tocent


	} elseif {[isH3 $tLine res aname] } {

	    incr h3cnt

            set anchorkey [list ${fn} ${res} h3 ${_linecnt}]
            set tocent    [list ${fn} ${res} h3 ${_linecnt} $h1cnt $h2cnt $h3cnt]

            set _anchors($anchorkey) $aname
	    set _reverseAnchors($anchorkey) $tocent
            lappend _toc $tocent

	} elseif { [regexp {^%%%TOC *(.*)} $_curLine dum res] } {

	    incr h1cnt
	    set h2cnt 0
	    set h3cnt 0

            set anchor toc
            if { [string length $res] } {
                set title $res
            } else {
                set title "Table of Contents"
            }

            set anchorkey [list ${fn} ${title} h1 ${_linecnt}]
            set tocent    [list ${fn} ${title} h1 ${_linecnt} $h1cnt $h2cnt $h3cnt]

            set _anchors($anchorkey) $anchor
	    set _reverseAnchors($anchorkey) $tocent

            lappend _toc $tocent

	} elseif { [regexp {^%%%SPLIT *(.*)} $_curLine dum res] && $_split_level  } {

            incr mySplitCnt
            
            set _split_last $mySplitCnt
	}

    }
    close $fh

    incr _split_last
}

# _mainScan -- process line by line
proc _mainScan {fn} {

    global _prevLine
    global _curLine
    global _nextLine
    global _linecnt

    global _syp_mode
    global _syp_title
    global _template

    global _anchors
    global _toc

    global _state
    global _level

    global _split_level

    global _cur_h1

    set stateInItemize 0
    set stateInEnum 0
    set stateInDesc 0
    set stateInPre 0
    set stateIsContinuation 0
    set stateInTable 0

    set _prevLine ""
    set _curLine ""
    set _nextLine ""

    set _linecnt 0

    set _doProcess 1

    set fh [open $fn "r"]

    ## first line
    if {[eof $fh] == 0} {gets $fh ::_nextLine}

    while {[eof $fh] == 0 && $_doProcess} {

	_getNextInputLine $fh

        # puts "DBG cur: $_curLine"

	if { [regexp {^%%%STOPPROCESSINGHERE} $_curLine dum res] } {
	    set _doProcess 0
	    continue
	}

	## search and replace reference to figure
	##[==ws3ov==]
	if {[regexp {\[==([^=]*)==\]} $_curLine dum res] != 0 } {
	    set tmp [procFigRef $res]
	    regsub {\[==[^=]*==\]} $_curLine $tmp _curLine
	}
	
	## continuation

	## paragraph
	if {[string equal $_prevLine ""] && [string equal $_curLine ""]} {
	    procPara
	    continue
	}

	## pre-processed (do not change)
	if {[regexp {^%%%([^ ]+) *(.*)} $_curLine dum mode res] != 0 } {

	    if { [string equal $_syp_mode $mode] } {
		## HTML
		fputs $res
	    } elseif { [string equal $mode "TOC"] } {
                if { [string length $res] } {
                    procIndex $res
                } else {
                    procIndex
                }
	    } elseif { [string equal $mode "SPLIT"] && $_split_level} {

                closeOutputFile
                openNextOutputFile

            } elseif { [string equal $mode INC] } {

		set ifh [open $res r]
		while { ![eof $ifh] } {

		    gets $ifh iline
		    fputs $iline
		}

		close $ifh
	    }

	    ## comment, ignore
	    continue
	}

	## Pre-formatted
	if {[regexp {^--- (.*)} $_curLine dum res] != 0 } {
	    if {$stateInPre} {set stateInPre 2}
	    procPre res stateInPre
	    continue
	}

	## ws3 code
	if {[regexp {^---ws3 (.*)} $_curLine dum res] != 0 } {
            if { [string equal $_state ws3] } {
                set _state ""
                if { [string length $res] } {
                    fputs $res
                }
                fputs </pre>
            } else {
                set _state ws3
                fputs <pre>
                if { [string length $res] } {
                    fputs $res
                }
            }
            continue
        }

	## Itemize
	if {[regexp {^( *)==\* (.*)} $_curLine dum spaces res] != 0 } {
            set level [expr [string length $spaces] / 4 + 1]
            if { $level == $_level } {
                # continue on current level
                procItemize $res
            } elseif {$level < $_level } {
                # level decreased
                for {set i $_level } {$i > $level} {incr i -1}  {
                    endList $i
                }
                procItemize $res
            } else {
                # new level
                procItemizeStart $res
            }
	    continue
	}
	
	## Enum
	if {[regexp {^( *)==1 (.*)} $_curLine dum spaces res] != 0 } {

            set level [expr [string length $spaces] / 4 + 1]
            if { $level == $_level } {
                procEnum $res
            } elseif {$level < $_level } {
                for {set i $_level } {$i > $level} {incr i -1}  {
                    endList $i
                }
                procEnum $res
            } else {
                procEnumStart $res
            }
	    continue
	}

	## Description
	if {[regexp {^( *)==D (.*)} $_curLine dum spaces res] != 0 } {

            #==D foo
            #    bar
            #1234==D foo
            set level [expr [string length $spaces] / 4 + 1]
            # puts "DBG processing desc, level: $level ($_level) ($_state)"
            if { $level == $_level } {
                # continue on current level
                procDesc $res 1
            } elseif {$level < $_level } {
                for {set i $_level } {$i > $level} {incr i -1}  {
                    endList $i
                }
                procDesc $res 1
            } else {
                # new level
                procDescStart $res
            }
	    continue
	} 	    

	## Table
	if {[regexp {^==T (.*)} $_curLine dum res] != 0 } {
	    procTable res stateInTable
	    continue
	} 	    

	if { [isH1 $_curLine res aname] } {

	    set _cur_h1 $res

            if { $_split_level == 1 } {

                closeOutputFile
                openNextOutputFile
            }

            procH1 $res

            continue

	} elseif {[isH2 $_curLine res aname] } {

	    ## H2
	    procH2 $res
	    continue
	} elseif {[isH3 $_curLine res aname] } {
	    ## H3
	    procH3 $res
	    continue
	}

	
	## Figure
	#     if {[regexp {^==Figure==([^=]*)==([^=]*)==(.*)} $_curLine dum id url alt] 
	# 	!= 0 } {}
	if {[regexp {^==Figure==([^=]*)==([^=]*)={0,2}(.*)} $_curLine dum id url alt] 
	    != 0 } {
	    #puts stderr "DBG syp.tcl -- found Figure."
	    #puts stderr "DBG syp.tcl -- next line: $_nextLine."
	    ## -- ok, this is a special case. Try to read the caption. --
            set caption {}
	    if {[regexp {^   (.*)} $_nextLine dum res] != 0 } {
		set caption $res
		#puts stderr "DBG syp.tcl -- caption: $caption."
		while {[eof $fh] == 0} {

		    _getNextInputLine $fh

		    if {[regexp {^   (.*)} $_nextLine dum res] != 0 } {
			append caption "\n$res"
		    } else {
			break
		    }
		}
	    }
	    procFigure $id $url $alt $caption
	    continue
	}
        
        # continuation
	if {[regexp {^( +)(.*)} $_curLine dum spaces res] != 0 } {

            if { [string equal $_state ws3] } {

                ## websh3 code
                procWS3Code [web::dehtmlify $res]
                continue
            }

            set level [expr [string length $spaces] / 4]

            # puts "DBG is continuation, level: $level, state: $_state, actual level: $_level, in: $res"

            if { $level >= 1 } {
                if {[string equal $_state ul]} {
                    if {$level < $_level } {
                        for { set i $_level } {$i <= $level} {incr i -1}  {
                            procItemizeEnd
                        }
                        procItemize $res
                    } else {
                        fputs $res
                        # procItemize $res
                    }
                } elseif {[string equal $_state ol]} {

                    if {$level < $_level } {
                        for { set i $_level } {$i <= $level} {incr i -1}  {
                            procEnumEnd
                        }
                        procEnum $res
                    } else {
                        fputs $res
                        # procEnum $res
                    }
                } elseif {$stateInTable} {
                    procTable res stateInTable
                } elseif {[string equal $_state dl]} {

                    if {$level < $_level } {

                        # level decreased
                        for { set i $_level } {$i <= $level} {incr i -1}  {
                            procDescEnd
                            procDesc $res
                        }
                    } else {
                        fputs $res
                        # procDesc $res
                    }
                } else {
                    # puts "DBG unmatched continuation 1: $res"
                    fputs $_curLine
                }
            } else {
                # puts "DBG unmatched continuation 2: $res"
                fputs $_curLine
            }
	    continue
	}

	## so it was a termination ?
	set dum ""
	if {[string equal $_state ul]} {
            for { set i $_level } {$i > 0} {incr i -1}  {
                endList $i
            }
        } elseif {[string equal $_state ol]} {
            for { set i $_level } {$i > 0} {incr i -1}  {
                endList $i
            }
	} elseif {$stateInTable} {
	    set stateInTable 2
	    procTable dum stateInTable
	} elseif {[string equal $_state dl]} {
            # puts "DBG processing term, ($_level)  ($_state)"
            for { set i $_level } {$i > 0} {incr i -1}  {
                endList $i
            }
        }

	## just text
	fputs $_curLine
    }
    close $fh
}

proc splitFileName {{cnt -1}} {

    global _outBaseName
 
    set base [file rootname ${_outBaseName}]
    set ext  [file extension ${_outBaseName}]

    if { $cnt > -1 } {
	set fn "${base}${cnt}${ext}"
    } else {
	set fn $_outBaseName
    }
}


proc openNextOutputFile {} {

    global _ofh
    global _tfh
    global _split_cnt
    global _split_level
    global _split_first
    global _split_last
    global _template
    global _cur_h1

    if { $_split_level } {

	incr _split_cnt

	set fn [splitFileName $_split_cnt]

    } else {

	set fn [splitFileName]
    }


    # puts "DBG opening $fn"

    set _ofh [open $fn w]

    # -------------------------------------------------------------------------
    # use template, if any
    # -------------------------------------------------------------------------
    if { [string length $_template] } {

        set _tfh [open $_template r]
        while { [eof $_tfh] == 0 } {

            gets $_tfh template_line

            if {[regexp {^%%%H1(.*)} $template_line]} {
                fputs $_cur_h1
                continue
            }
            if {[regexp {^%%%FIRST(.*)} $template_line]} {
                fputs "<a href=\"[splitFileName $_split_first]\">[web::htmlify "<<"]</a>"
                continue
            }
            if {[regexp {^%%%LAST(.*)} $template_line]} {
                fputs "<a href=\"[splitFileName $_split_last]\">[web::htmlify ">>"]</a>"
                continue
            }
            if {[regexp {^%%%NEXT(.*)} $template_line]} {
                set cnt $_split_cnt
                incr cnt
                if { $cnt <= $_split_last } {
                    fputs "<a href=\"[splitFileName $cnt]\">[web::htmlify ">"]</a>"
                } else {
                    fputs [web::htmlify ">"]
                }

                continue
            }
            if {[regexp {^%%%PREV(.*)} $template_line]} {
                set cnt $_split_cnt
                incr cnt -1
                if { $cnt >= $_split_first } {
                    fputs "<a href=\"[splitFileName $cnt]\">[web::htmlify "<"]</a>"
                } else {
                    fputs [web::htmlify "<"]
                }
                continue
            }
                

            if {[regexp {^%%%TMPL(.*)} $template_line]} {
                break
            } else {
                fputs $template_line
            }
        }
    }
}

proc closeOutputFile {} {

    global _ofh
    global _tfh
    global _template
    global _split_first
    global _split_last
    global _split_cnt

    # puts "DBG closing"

    # -------------------------------------------------------------------------
    # finish template file, if any
    # -------------------------------------------------------------------------
    if { [string length $_template] } {

        while { [eof $_tfh] == 0} {

            gets $_tfh template_line

            if {[regexp {^%%%FIRST(.*)} $template_line]} {
                fputs "<a href=\"[splitFileName $_split_first]\">[web::htmlify "<<"]</a>"
                continue
            }
            if {[regexp {^%%%LAST(.*)} $template_line]} {
                fputs "<a href=\"[splitFileName $_split_last]\">[web::htmlify ">>"]</a>"
                continue
            }
            if {[regexp {^%%%NEXT(.*)} $template_line]} {
                set cnt $_split_cnt
                incr cnt
                if { $cnt <= $_split_last } {
                    fputs "<a href=\"[splitFileName $cnt]\">[web::htmlify ">"]</a>"
                } else {
                    fputs [web::htmlify ">"]
                }
                continue
            }
            if {[regexp {^%%%PREV(.*)} $template_line]} {
                set cnt $_split_cnt
                incr cnt -1
                if { $cnt >= $_split_first } {
                    fputs "<a href=\"[splitFileName $cnt]\">[web::htmlify "<"]</a>"
                } else {
                    fputs [web::htmlify "<"]
                }
                continue
            }
            fputs $template_line
        }
        close $_tfh
    }

    close $_ofh
}

proc init {} {

    global _state
    global _level
    global _split_cnt
    global _split_level
    global _split_first
    global _split_last
    global _level_stack
    global _cur_h1

    set _state {}
    set _level 0
    set _split_cnt 0
    set _split_level 0
    set _split_first 1
    set _split_last 0
    set _cur_h1 {}
}

proc usage {arglist switches} {
    puts stderr "usage: syp input outputBase \[options\]"
    puts stderr "  e.g. syp in.syp out.html"
    foreach {name arg desc} $arglist {
        puts stderr "  -$name $arg $desc"
    }
    foreach {name desc} $switches {
        puts stderr "  -$name $desc"
    }
}

proc main {argc argv} {

    global _filename
    global _template
    global _ofh
    global _outBaseName
    global _split_level

    set arglst {
        split <level> "one output file per h1,h2,... section - <level> is int"
        tr <module> "use <module> for output generation"
        template <file>   "use <file> as template for output"
    }
    set switches {}

    # -------------------------------------------------------------------------
    # command line
    # -------------------------------------------------------------------------
    if {$argc > 1 } {
        set _filename [lindex $argv 0]
        set _outBaseName [lindex $argv 1]
    } else {
        usage $arglst $switches
        exit 1
    }

    if {$argc > 2 } {

        foreach {name vale desc} $arglst {

            # -----------------------------------------------------------------
            # (-tr) load module, if any
            # -----------------------------------------------------------------
            set idx [lsearch $argv "-tr"]

            if { $idx != -1} {

                source [lindex $argv [expr $idx + 1]]
            }

            # -----------------------------------------------------------------
            # (-split)
            # -----------------------------------------------------------------
            set idx [lsearch $argv "-split"]

            if { $idx != -1} {

                set _split_level [lindex $argv [expr $idx + 1]]
                if { ![string is integer $_split_level] } {
                    puts "error: argument for -split must be integer, not $_split_level"
                    exit 1
                }
                puts "DBG split: $_split_level"
            }

            # -------------------------------------------------------------------
            # (-template) load template, if any
            # -------------------------------------------------------------------
            set idx [lsearch $argv "-template"]
            
            if { $idx != -1} {

                set _template [lindex $argv [expr $idx + 1]]
                if { ![file exists $_template] } {
                    puts "error: file $_template does not exist"
                    exit 1
                }
            }
        }
    }

    # -------------------------------------------------------------------------
    # file exists ?
    # -------------------------------------------------------------------------
    if {![file exists $_filename] } {
        puts stderr "syp.tcl --- cannot read $_filename"
        exit 1
    }

    # -------------------------------------------------------------------------
    # first scan: build list of figures and references
    # -------------------------------------------------------------------------
    _firstScan $_filename

    openNextOutputFile

    _mainScan $_filename

    closeOutputFile
}

init
main $argc $argv
