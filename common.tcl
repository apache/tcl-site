# stuff common to all pages

proc navbar { } {
    include newnav.html
}

proc title { {txt "Apache Tcl Project"} } {
    puts {
	<table align="center" width="63%" border="0">
	<tr>
	<td align="center" valign="top">
	<h1 style="padding: .3em;">
    }
    puts "$txt"
    puts {
	</h1>
	</td>
	</tr>
	</table>
	<hr>
    }
}

proc rivettitle { {txt "Apache Rivet"} } {
    puts {
	<table align="center" width="100%" border="0">
	<tr>
	<td align="left"><img src="Rivetlogo_small.png"></td>
	<td align="center" valign="top" width="100%">
	<h1 style="padding: .3em;">
    }
    puts "$txt"
    puts {
	</h1>
	</td>
	</tr>
	</table>
	<hr>
    }
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
