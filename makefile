
.PHONY: all smt test clean

export OCAMLRUNPARAM=b

all: smt
	@

smt:
	cd source && ocamlbuild main.native -use-menhir -cflag -g
	mv source/main.native smt

test: smt
	
	./smt --test

clean:
	rm -f smt
	cd source && ocamlbuild -clean

%.cmo:
	cd source && ocamlbuild $@ -use-menhir

