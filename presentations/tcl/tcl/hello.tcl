set Time [clock format [clock seconds]]
label .time -textvariable Time
button .close -text "Update Clock" -command { set Time [clock format [clock seconds]] }
pack .time .close