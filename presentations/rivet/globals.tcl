namespace eval request {
    set ::global_data [clock seconds]
}
namespace delete request

namespace eval request {
    puts "The last person to access this child process came at:"
    puts [clock format $::global_data]
}
namespace delete request