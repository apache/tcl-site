# stuff common to all pages

proc navbar { } {
    include newnav.html
}

proc title { {txt "Apache Tcl Project"} } {
    puts {
<p style="margin: 0; border: 0;" align="center">
<img style="margin-bottom: -2.5em; " src="/logos/medium_logo.gif" alt="Apache Tcl"></p>}
}

proc rivettitle { {txt "Apache Rivet"} } {
    puts {<p align="center"><img src="Rivetlogo_smaller.png" alt="Apache Rivet"></p>}
}

proc powered { } {
    puts {
	<table align="center" width="100%">
	<tr>
	<td align="left">
	<a href="http://www.apache.org/"><img src="/apache_pb.gif"
	alt="Powered by Apache" border="0"
	width="259"
	height="32"></a>
	</td>
	<td align="right">
	<a href="http://www.tcl.tk/"><img src="/tclp.gif"
	alt="Powered by Tcl" border="0"
	width="42"
	height="64"></a>
	</td>
	</tr>
	</table>
    }
}
