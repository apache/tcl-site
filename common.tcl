# stuff common to all pages

proc title { {txt "Apache Tcl Project"} } {
    hputs {
	<table width="100%" border="0">
	<tr>
	<td align="center" valign="top">
	<h1>
    }
    hputs "$txt"
    hputs {
	</h1>
	</td>
	</tr>
	</table>
    }
}
    
proc powered { } {
    hputs {
	<table align="center" width="100%">
	<tr>
	<td align="left">
	<a href="http://www.apache.org/"><img src="/apache_pb.gif"
	alt="Powered by Apache" border="0"
	width="259"
	height="32"></a>
	</td>
	<td align="right">
	<a href="http://www.tcl-tk.net/"><img src="/tclp.gif"
	alt="Powered by Tcl" border="0"
	width="42"
	height="64"></a>
	</td>
	</tr>
	</table>
    }
}
