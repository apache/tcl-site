foreach ws3 [glob *.ws3] {
    puts "processing $ws3"
    catch {
	exec /usr/bin/enscript -h -B -t [file root $ws3] --color -Etcl -B --language=html -o [file rootname $ws3].html $ws3
    }
}