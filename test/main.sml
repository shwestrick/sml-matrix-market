functor Main
  (M:
   sig
     type matrix
     val read_file: string -> matrix
     val showMatrix: matrix -> string
   end) =
struct

  fun main () =
    let
      val f = List.hd (CommandLineArgs.positional ())
              handle _ => Util.die ("missing filename")

      val show_output = CommandLineArgs.parseFlag "show-output"
      val _ = print
        ("--show-output? " ^ (if show_output then "yes" else "no") ^ "\n")

      val _ = print ("reading file " ^ f ^ "\n")
      val (m, tm) = Util.getTime (fn () => M.read_file f)
      val _ = print ("parsed file in " ^ Time.fmt 4 tm ^ "s\n")

      val _ = if show_output then print (M.showMatrix m ^ "\n") else ()
    in
      ()
    end
end

structure Main32 = Main(MatrixMarket (structure I = Int32 structure R = Real32))
structure Main64 = Main(MatrixMarket (structure I = Int64 structure R = Real64))

val p = CommandLineArgs.parseInt "p" 32
val _ = print ("-p " ^ Int.toString p ^ "\n")

val () =
  case p of
    32 => Main32.main ()
  | 64 => Main64.main ()
  | _ => Util.die ("invalid -p <bits>. options are: 32 64")
