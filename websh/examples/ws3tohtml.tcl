#!/bin/sh
# the next line restarts using tclsh \
    exec tclsh "$0" "$@"

foreach ws3 [glob *.ws3] {
    puts "processing $ws3"
    catch {
	exec /usr/bin/enscript -h -B -t [file root $ws3] --color -Etcl -B --language=html -o [file rootname $ws3].html $ws3
    }
    file copy -force $ws3 "[file rootname $ws3]_ws3.txt"
}
