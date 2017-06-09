Sa Majesté Truchante :
======================
	
	Josselin GIET
	David REBOULLET

Le projet se compile avec `make`.

Solveur SAT :
-------------

### Présenation générale

Le solveur SAT, appelé `sat_epate`, utilise un algorithme DPLL classique. 
Le choix de la procédure à appliquer est dans l'ordre : 
0. `SAT/Fail/Backtrack` (ces points ne se présentent jamais en même temps)
1. `Unit`
2. `Decide`

Fail et Backtrack sont gérés au moyen d'exception :
* Si une clause est fausse : on backtrack
* Si, pendant le backtrack, il n'ya plus de décision sur laquelle revenir,
  on fail.

Par ailleurs, on utilise une heuristique pour déterminer la variable à
décider : On choisit la variable non instanciée qui est la plus présente
dans la formule.

### Utilisation

#### Sur des fichiers 

On peut lancer le soveur smt en mode `sat` avec l'appel :

	./smt --sat <filename>.cnf

L'option `--time` peut être réjoutée à la fin afin de mesurer le temps de
l'exécution. Ce temps comprend celui nécessaire pour ouvrir le fichier et
parser la formule.

Une liste d'exemples est fournit dans `./example/sat`.

Le solveur time-out sur les exemples suivants : 
* example/sat/bf0432-007.cnf
* example/sat/unsat/aim-100-1_6-no-1.cnf
* example/sat/unsat/dubois20.cnf
* example/sat/unsat/dubois21.cnf
* example/sat/unsat/dubois22.cnf

#### Sur des tests générés aléatoirement

On peut aussi appeler le solveur SAT sur des formules générées aléatoirement
avec la commande :

	./smt --sat-rand <nbtest> <nbclause> <nbvar>

où :
* `<nbtest>` est le nombre de test qu'on veut effectuer
* `<nbclause>` est le nombre de clause dans la formule
* `<nbvaraiable>` est le nombre de variables dans la formule

Le programme renvoie alors la moyenne du temps de calcul nécessaire pour
chaque test (ce temps ne comprend que celui nécessaire pour la
résolution, pas celui pour la génération de formule).
On peut aussi comparer ce solveur avec le solveur `sat_naif` avec
l'argument `--compare`. Attention au dela de quelques variables (25 sur
les ordis de l'ÉNS) le solveur naïf est lent !

Solveur SMT :
-------------

### Présentation générale

Le solveur SMT implémente l'algorithme classique d'un solveur SMT sans trop
de spécificité si ce n'est qu'il est présenté comme foncteur du solveur SAT
et de la théorie. Cette dernière est composée d'un type `t` des litéraux,
d'une comparateur `compare`, d'une négation `neg` involutive sur `compare`
et d'une fonction `check` décidant une proposition formulée sous forme de
conjonction de litéraux.

Deux théories ont été implémentées : la théorie de l'égalité et celle des
inégalitées sur un ordre complet infini. La première effectue uniquement un
Union-Find sur les litéraux d'égalités pour ensuite tester dans un deuxième
temps les inégalitées. La théorie des inégalitées rajoute en interne deux
constructions : supérieur ou égal, et strictement inférieur par soucis de
symmétrie par rapport à `neg`. Cette dernière construction est dans la
théorie immédiatement remplacée par une conjonction de supérieur ou égal et
différent. Après avoir traité les inégalitées, la théorie parcourt le
graphe engendré par la relation supérieur ou égal pour unifier dans la
structure d'Union-Find les boucles. Il ne reste alors plus qu'à vérifier
les différences.

### Utilisation

Le solveur SMT ne s'utilise que sur des fichiers via la commande :

	./smt <filename>.cnfuf

pour vérifier un fichier utilisant la théorie de l'égalité, ou avec la
commande :

	./smt --ineq <filename>.cnfuf

pour vérifier un fichier utilisant la théorie de l'inégalité.

La commande `--time` est de plus toujours possible à la fin.

