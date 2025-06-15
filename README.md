# sml-matrix-market

Standard ML package for parsing [MatrixMarket](https://math.nist.gov/MatrixMarket/formats.html) (`.mtx`) files.

Compatible with the [`smlpkg`](https://github.com/diku-dk/smlpkg)
package manager.

This library is parallelized
if compiled with [MaPLe](https://github.com/mpllang/mpl).

# Library sources

There are two source files:

  * `lib/github.com/shwestrick/sml-matrix-market/sources.mlton.mlb`
  * `lib/github.com/shwestrick/sml-matrix-market/sources.mpl.mlb`

The `.mlton.mlb` file is for use with [MLton](http://mlton.org/)
and the `.mpl.mlb` file is for use with [MaPLe](https://github.com/mpllang/mpl).
Both supply the same interface, described below.

# Interface

This library is designed to closely model the actual file format itself.

The library defines a functor, `MatrixMarket`, which takes implementations
of `INTEGER`s and `REAL`s as argument. This allows for choosing between
different integer sizes and real precisions. For example, using `I = Int32`
will store all parsed integers as 32-bit values.

The `REAL` implementation also needs to
define a function `fromLargeWord: LargeWord.word -> real` which rounds the
input value (interpreted as an unsigned integer) to the nearest representable
floating point value. In MLton (and MaPLe), suitable functions are
`MLton.Real32.fromLargeWord` and `MLton.Real64.fromLargeWord`. This function
is needed by [`sml-fast-real`](https://github.com/shwestrick/sml-fast-real) for
fast real number parsing.

See below for example usage.

```sml
functor MatrixMarket
  (structure I: INTEGER
   structure R:
   sig
     include REAL
     val fromLargeWord: LargeWord.word -> real
   end):
sig
  structure Columns:
  sig
    datatype columns =
      Real of R.real array array
    | Integer of I.int array array
    | Complex of {re: R.real, im: R.real} array array
    type t = columns
  end

  structure Values:
  sig
    datatype values =
      Real of R.real array
    | Integer of I.int array
    | Complex of {re: R.real, im: R.real} array
    type t = values
  end

  datatype data =
    Array of Columns.t
  | Coordinate of
      {row_indices: I.int array, col_indices: I.int array, values: Values.t}
  | Pattern of {row_indices: I.int array, col_indices: I.int array}

  datatype symmetry =
    General
  | SkewSymmetric
  | Symmetric
  | Hermitian

  datatype matrix =
    Matrix of {num_cols: int, num_rows: int, data: data, symm: symmetry}

  (* read_file(path) -> matrix *)
  val read_file: string -> matrix
end
```

# Example usage


Example `main.mlb` for MLton or MaPLe. 
```
$(SML_LIB)/basis/basis.mlb
$(SML_LIB)/basis/mlton.mlb                                     (* for MLton.Real64.fromLargeWord *)
lib/github.com/shwestrick/sml-matrix-market/sources.mlton.mlb  (* or use .mpl.mlb instead for MaPLe *)
main.sml
```

Example `main.sml`:
```sml
structure R64 =
struct
  open MLton.Real64 (* need this for fromLargeWord *)
  open Real64
end

structure M = MatrixMarket(structure I = Int64 structure R = R64)

val matrix = M.read_file "example.mtx"

val () =
  case matrix of
    M.Matrix {num_rows, num_cols, data, symm} =>
      print ("num_rows = " ^ Int.toString num_rows
             ^ ", num_cols = " ^ Int.toString num_cols
             ^ ", ...\n")
```

Example `example.mtx`:
```
%%MatrixMarket matrix coordinate real general
% hello world
4 5 3
1 2 -42.0e-1
1 4 12345
4 5 2.
```