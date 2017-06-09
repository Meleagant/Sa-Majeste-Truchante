Sa Majesté Truchante :
======================

Solveur SAT :
-------------

### Présenation générale

Le solveur SAT (appelé `sat_epate`) utilise un algorithme DPLL classique. 
Le choix de la procédure à appliquer est dans l'ordre : 
0. `SAT/Fail/Backtrack` (ces points ne se présentent jamais en me temps)
1. `Unit`
2. `Decide`

Fail et Backtrack sont gérés au moyen d'exception :
* Si un clause est fausse : on backtrack
* Si, pendant le backtrack, il n'ya plus de décision sur laquelle revenir,
  on fail.

Par ailleurs, on utilise une heuristique pour déterminer la variable à
décider : On choisit la variable non instanciée qui est la plus présente
dans la formule.

### Perforamnce

Il y a plusieur moyens de tester la performance du solveur `sat_epate`

#### Sur des fichiers 

On peut lancer le soveur smt en mode `sat` avec l'appel :

	./smt --sat <filename>.cnf

L'option `--time` peut être réjoutée à la fin afin de mesurer le temps de
l'exécution. Ce temps comprend celui nécessaire pour ouvrir le fichier et
parser la formule.

#### Sur des tests générés aléatoirement

On peut aussi appeler le solveur SAT sur des formules générées aléatoirment
avec la commande :

	./smt --sat-rand <nbtest> <nbclause> <nbvar>

où :
* `<nbtest>` est le nombre de test qu'on veut effectuer
* `<nbclause>` est le nombre de clause dans la formule
* `<nbvaraiable>` est le nombre de variables dans la formule

Le programme renvoie alors le moyenne du temps de calcul nécessaire pour
chaque test (ce temps ne comprend que celui nécessaire pour la
résolution, pas celui pour la génération de formule).
On peut aussi comparer ce solveur avec le solveur `sat_naif` avec
l'argument `--compare`. Attention au dela de 
 variables le solveur naïf est lent !


