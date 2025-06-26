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

  (* For files with the following header, data is organized into columns.
   *   %%MatrixMarket matrix array ...
   * Note that the encoding of the columns depends on symmetries! If the
   * data is either symmetric, skew-symmetric, or Hermitian, only the lower
   * triangular portion is included, and the 2D structure will therefore be
   * jagged. Each inner array is either:
   *   (a) one whole column (if no symmetry), or
   *   (b) a lower triangular portion of a column (if there is some symmetry)
   *)
  structure Columns:
  sig
    datatype columns =
      Real of R.real array array
    | Integer of I.int array array
    | Complex of {re: R.real, im: R.real} array array
    type t = columns
  end


  (* For files with the following header, data is stored sparsely.
   *   %%MatrixMarket matrix coordinate [real|integer|complex] ...
   * The data of such a matrix will be parsed into the SML form:
   *   Coordinate {row_indices, col_indices, values}
   * These three arrays together are essentially an SoA representation
   * of the tuples (row, col, value) which are the entries of the matrix.
   * For every i, we have one entry:
   *     (row_indices[i], col_indices[i], values[i])
   *)
  structure Values:
  sig
    datatype values =
      Real of R.real array
    | Integer of I.int array
    | Complex of {re: R.real, im: R.real} array
    type t = values
  end


  (* Array and Coordinate forms described above. The Pattern form is
   * essentially the same as Coordinate, but with no values.
   *)
  datatype data =
    Array of Columns.t
  | Coordinate of
      {row_indices: I.int array, col_indices: I.int array, values: Values.t}
  | Pattern of {row_indices: I.int array, col_indices: I.int array}


  (* The data stored in MatrixMarket files has a few ad-hoc compression
   * schemes, taking advantage of symmetries commonly found in matrices:
   *
   *   General: no symmetry, all entries are included in the data.
   *
   *   Symmetric: matrix is symmetric along the diagonal (M[i,j] = M[j,i]).
   *     The data includes only the lower triangular portion, including
   *     diagonal entries, which can be non-zero.
   *
   *   SkewSymmetric: same as Symmetric, but the data along the diagonal is 0
   *     and is excluded.
   *
   *   Hermitian: as the name suggests. The values must be complex, and only
   *     the lower triangular portion of the matrix is included in the data,
   *     including the diagonal, which can be non-zero. The upper triangular
   *     portion is excluded; this can be recovered according to the definition
   *     of Hermitian matrices: M[i,j] = ComplexConjugate(M[j,i]).
   *)
  datatype symmetry =
    General
  | Symmetric
  | SkewSymmetric
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