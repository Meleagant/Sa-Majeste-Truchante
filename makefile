
.PHONY: all smt clean

all: smt
	@

smt:
	cd source && ocamlbuild main.native -use-menhir
	mv source/main.native smt

clean:
	rm -f smt
	cd source && ocamlbuild -clean

%.cmo:
	cd source && ocamlbuild $@ -use-menhir

