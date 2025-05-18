structure M = MatrixMarket (structure I = Int structure R = Real)

val f = CommandLineArgs.parseString "f" "test.mtx"

val m = M.read_file f

val _ = print (M.showMatrix m ^ "\n")
