proc decr {varname} {
    uplevel [list incr $varname -1]
}
set a 5
decr a
puts $a