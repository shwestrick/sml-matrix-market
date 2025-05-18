# sml-matrix-market

:warning: work in progress :warning:

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

