proc Serve {chan addr port} {
    fconfigure $chan -translation {auto binary}
    set line [gets $chan]
    if { [catch { set fl [open ".[lindex $line 1]" r] } err] } {
        puts $chan "HTTP/1.0 404 Not Found\r\n"
    } else {
        puts $chan "HTTP/1.0 200 OK"
	puts $chan "Content-Type: text/html\r\n\r\n[read $fl]"
    }
    close $chan
}

set sk [socket -server Serve 5151]
fconfigure $sk -buffering line
vwait forever
