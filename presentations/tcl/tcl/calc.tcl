label .result -textvariable Result -anchor e
entry .input -textvariable Input

pack .result -fill both -expand 1
pack .input -fill both -expand 1

bind .input <Return> {
    if { [catch {
	set Result [expr $Input]
    } err] } {
	set Result $err
    }
}