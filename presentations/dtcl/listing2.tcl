  <?
  set i 1
  hputs "<table>"
  
  while { $i <= 8 } {
      hputs "<tr>"
      for {set j 1} {$j <= 8} {incr j} {
          set num [ expr {$i * $j * 4 - 1} ]
          hputs [ format "<td bgcolor=%2x%2x%2x > $num $num $num </td>" \
                          $num $num $num ]
      }
      incr i
      hputs "</tr>"
  }

  hputs "</table>"
  ?>
