proc fac {x} {
    if { $x <= 1 } { return 1 }
    expr { $x * [fac [expr $x - 1]] }
}
