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
    