label .result -text "Result"
entry .input 

grid .result -sticky news
grid .input -sticky news

bind .input <Return> {
    if {[catch {
	.result configure -text [expr [.input get]]
    } err]} {
	.result configure -text $err
    }
}