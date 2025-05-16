# sml-matrix-market

Standard ML package for parsing [MatrixMarket](https://math.nist.gov/MatrixMarket/formats.html) files.

Compatible with the [`smlpkg`](https://github.com/diku-dk/smlpkg)
package manager.

This library is reasonably well-optimized, and highly parallel,
if compiled with [MaPLe](https://github.com/mpllang/mpl).

# Library sources

There are two source files:

  * `lib/github.com/shwestrick/sml-matrix-market/sml-matrix-market.mlb`
  * `lib/github.com/shwestrick/sml-matrix-market/sml-matrix-market.mpl.mlb`

The `.mlb` is for use with normal SML (e.g. [MLton](http://mlton.org/))
and the `.mpl.mlb` is for use with [MaPLe](https://github.com/mpllang/mpl).
Both supply the same interface, described below.

