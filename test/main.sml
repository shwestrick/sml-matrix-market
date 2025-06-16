functor Main
  (structure I: INTEGER
   structure R:
   sig
     include REAL
     val fromLargeWord: LargeWord.word -> real
   end) =
struct

  structure M = MatrixMarket (structure I = I structure R = R)

  fun count2d (a: 'a array array) =
    SeqBasis.reduce 1000 op+ 0 (0, Array.length a) (fn i =>
      Array.length (Array.sub (a, i)))

  fun num_explicit_entries (M.Matrix {data, symm, num_rows, num_cols}) =
    case data of
      M.Coordinate {row_indices, ...} => Array.length row_indices
    | M.Pattern {row_indices, ...} => Array.length row_indices
    | M.Array c =>
        case c of
          M.Columns.Real a => count2d a
        | M.Columns.Integer a => count2d a
        | M.Columns.Complex a => count2d a

  fun values_type v =
    case v of
      M.Values.Real _ => "real"
    | M.Values.Integer _ => "integer"
    | M.Values.Complex _ => "complex"

  fun columns_type c =
    case c of
      M.Columns.Real _ => "real"
    | M.Columns.Integer _ => "integer"
    | M.Columns.Complex _ => "complex"

  fun header_summary (m as M.Matrix {num_rows, num_cols, data, symm}) =
    let
      val data_spec =
        case data of
          M.Coordinate {values, ...} => "coordinate " ^ values_type values
        | M.Pattern _ => "coordinate pattern"
        | M.Array c => "array " ^ columns_type c
      val symm_spec =
        case symm of
          M.General => "general"
        | M.Symmetric => "symmetric"
        | M.SkewSymmetric => "skew-symmetric"
        | M.Hermitian => "hermitian"
    in
      data_spec ^ " " ^ symm_spec
    end

  fun summarize_matrix (m as M.Matrix {num_rows, num_cols, data, symm}) =
    header_summary m ^ "\nnum_rows " ^ Int.toString num_rows ^ "\nnum_cols "
    ^ Int.toString num_cols ^ "\nnum_explicit_entries "
    ^ Int.toString (num_explicit_entries m) ^ "\n"

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

      val _ =
        if show_output then print (M.showMatrix m ^ "\n")
        else print (summarize_matrix m ^ "\n")
    in
      ()
    end
end

(* need MLton.RealXX.fromLargeWord *)
structure R32 =
struct open Real32 open MLton.Real32 end
structure R64 = struct open Real64 open MLton.Real64 end

structure Main32 = Main (structure I = Int32 structure R = R32)
structure Main64 = Main (structure I = Int64 structure R = R64)

val p = CommandLineArgs.parseInt "p" 32
val _ = print ("-p " ^ Int.toString p ^ "\n")

val () =
  case p of
    32 => Main32.main ()
  | 64 => Main64.main ()
  | _ => Util.die ("invalid -p <bits>. options are: 32 64")
