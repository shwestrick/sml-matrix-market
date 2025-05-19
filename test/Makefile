SOURCES=../lib/github.com/shwestrick/sml-matrix-market/**.sml ../lib/github.com/shwestrick/sml-matrix-market/**.mlb **.mlb **.sml

main.mlton: $(SOURCES)
	mlton -default-type int64 -default-type word64 main.mlton.mlb

main.mpl: $(SOURCES)
	mpl -default-type int64 -default-type word64 main.mpl.mlb
