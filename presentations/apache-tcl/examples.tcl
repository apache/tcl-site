
if { [var exists customerid] } {
    array set customer [get_customer_info $customerid]
    puts "Welcome, Mr. $customer(Surname)"
} else {
    puts "Hi, would you like to register a new account?"
}

proc greeting {} {
    switch $HTTP_ACCEPT_LANGUAGE {
	en {
	    return "Hello, how is it going?"
	}
	it {
	    return "Buon giorno, come va?"
	}
	fr {
	    return "Bonjour, .......?"
	}
	de {
	    return "Guten Tag, wie gehts?"
	}
	de {
	    return "Guten Tag, wie gehts?"
	}
    }
}

puts [greeting]