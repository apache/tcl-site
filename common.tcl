# stuff common to all pages

proc navbar { } {
    include newnav.html
}

proc title { {txt "Apache Tcl Project"} } {
    puts {
	<table width="100%" border="0">
	<tr>
	<td align="center" valign="top">
	<h1>
    }
    puts "$txt"
    puts {
	</h1>
	</td>
	</tr>
	</table>
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
