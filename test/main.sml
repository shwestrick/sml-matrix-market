structure M = MatrixMarket (structure I = Int structure R = Real)

val f = List.hd (CommandLineArgs.positional ())
        handle _ => Util.die ("missing filename")

val show_output = CommandLineArgs.parseFlag "show-output"
val _ = print ("--show-output? " ^ (if show_output then "yes" else "no") ^ "\n")

val _ = print ("reading file " ^ f ^ "\n")
val (m, tm) = Util.getTime (fn () => M.read_file f)
val _ = print ("parsed file in " ^ Time.fmt 4 tm ^ "s\n")

val _ = if show_output then print (M.showMatrix m ^ "\n") else ()
