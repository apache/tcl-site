proc do {body while expression} {
    uplevel $body
    while { [uplevel expr $expression] } {
	uplevel $body
    }
}

set i 0
do {
    puts $i
    incr i
} while {$i < 0}