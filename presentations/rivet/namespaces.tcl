namespace eval foo {
    set foovar 1
    namespace eval bar {
	set barvar 1
    }
}

puts $::foo::bar::barvar
puts $::foo::foovar

namespace eval request {
    set greeting "Hello, World"
    puts -nonewline $greeting
}

namespace eval request {
    puts -nonewline $greeting
}