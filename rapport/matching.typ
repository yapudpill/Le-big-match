Voyons maintenant comment nous avons choisi d'exploiter notre schéma dans le but de faire matcher les utilisateurs entre eux. Il est clair qu'il n'y a pas une unique bonne manière de faire et que nous avons choisi une méthode parmi tant d'autres.

L’idée qu’on a finalement retenue, qui est d’ailleurs l’une des premières qui nous est venue à l’esprit, repose sur un principe assez intuitif : étant donné un utilisateur, on attribue une note de compatibilité, comprise entre 0 et 1, à chaque autre personne qui pourrait potentiellement lui correspondre. Cette note permet ensuite d’estimer dans quelle mesure deux profils pourraient s’entendre, en se basant sur différents critères présents dans notre base.

Cette approche a l’avantage de permettre une comparaison directe entre plusieurs profils, et donc de classer facilement les utilisateurs selon leur “degré de compatibilité” avec une personne donnée.

*Comment détermine-t-on les notes attribuées aux matchs potentiels ?*

Le Big Match étant un site de rencontre très axé sur les évènements il nous a semblé logique de leur accorder un poids important dans le calcul de la compatibilité.

Les tags, ont eux aussi leur rôle à jouer, même si nous leur avons donné une importance un peu plus modérée. Ils permettent de refléter les centres d’intérêt ou les traits de personnalité, et contribuent à affiner la compatibilité entre deux utilisateur. C'est à ce titre que nous avons choisi de donner 50% de la note à cet aspect de notre réseau réparti de la manière suivante : 30% pour les évènements et 20% pour les tags.

Les scores de tags sont calculés de la manière suivante : Si $T_1$ (resp. $T_2$) est l'ensemble des tags de $u_1$ (resp. $u_2$) alors le score de tags est donné par $(|T_1 inter T_2| )/ (|T_1 union T_2|)$, qui représente le nombre de tags qu'ils ont en commun divisé par le nombre de tags qu'ils ont fait en cumulé. Plus ils ont de tags en commun plus ils ont de chance d'être compatible. Cette méthode nous à paru être la meilleure façon d'exploiter les tags car *...*



* faire la partie sur les évènements*

* Préférences de u*

Maintenant que nous avons pris en compte les particularités de notre site de rencontre, intéressons-nous aux préférences de chaque utilisateur car même si deux personnes ont plein de points communs, si l’une d’elles ne correspond pas du tout aux attentes de l’autre, ça ne pourra jamais être un bon match. Les affinités, c’est important, mais les préférences individuelles le sont tout autant c'est donc pour cette raison que nous avons réservés les 50% restants aux préférences des utilisateurs.

Une première sélection est faite en fonction des attirances. Il va de soi que si un utilisateur est attiré par les garçons, on ne va pas lui proposer une fille, ni même un garçon qui, de son côté, n’est pas attiré par le sexe de cet utilisateur. Pour des raisons pratique nous n'avons considérés que homosexuel, bisexuel et hétérosexuel. De même si deux personnes sont trop éloignées alors elles ne sont pas considérés comme compatibles.

Ensuite nous determinons une note comprise entre 0 et 1 pour chaque personne étant compatible (au sens des critères du paragraphe ci-dessus).

Chaque utilisateur à la possibilité de renseigner ses préférences, la taille, la couleur d'yeux et de cheveux,le poids un âge minimum et maximum.

Nous avons considéré que l'âge est le critère le plus important et qu'il est primordial que se critère soit central au sein même des préférences.
On le lui accorde donc 50% et repartissons de manière équitable le reste c'est à dire 12.5% chacun.

Nous sommes conscient que cette pondération n'est probablement pas idéal mais à le bon goût d'être assez malléable. Ainsi il est dans nos plans de proposer aux utilisateurs abonnés de pouvoir choisir eux même ce qui leur semble important et ce qu'ils veulent favoriser.

Un utilisateur n'est pas obligé de renseigner de fiche de préférence. Dans ce cas nous avons choisi de mettre le score de préférence à 1.
Ce choix ne change en rien le classement final car tout le monde est le soumis à la même convention et donc les departages sont fait sur les tags et évènements.
Le score associé à la couleur des yeux et des cheveux vaut 1 si c'est exactement la bonne couleur.

C'est pour les autres critères que nous avons une méthode un peu plus recherchée. Il n'est pas raisonnable pour des raisons évidentes de faire pareil que précédemment pour la taille, le poids et l'âge.
Nous voulions que plus l’élément considéré est proche de celui voulu plus le score est élevé et que plus nous nous en éloignons plus le score baisse.
Nous voulions également l'écart compté positivement ou négativement ai le même impact sur le score. La dernière contrainte que nous voulions était une décroissante assez lente au début puis assez rapide et que passé un seuil elle vale zéro.

Traduisons cela en terme un peu plus mathématique. Nous cherchons une fonction $f : RR arrow.r  RR $, paire, décroissante sur $RR_+$, telle que $f(0) = 1$, si $ x in RR_+, x ≥ a$ alors $f(x) = 0$ où a représente le seuil fixé selon le critère.

Ainsi de ces contraintes nous avons extrait la fonction suivante :
$ f : RR arrow.r RR,\ x ↦
cases(
  1 - (x/a)^2 "si" |x| ≤ a,
  0 "sinon"
) $

Le coefficient a est fixé selon le critère considéré. Il est fixé à 10 pour la taille et le poids. Quant à l'âge nous l'avions fixé à 5 avant de finalement choisir de mettre de borne inf et sup et de mettre le score de l'âge à 1 si et seulement s'il est exactement entre les deux bornes car cela nous semblait plus judicieux et plus précis. Nous avons gardé ce système pour la taille et le poids car ce sont des critères moins sensibles aux variations.

// eventuellement on grade ca en dessous ?

Finalement le score obtenu par un candidat est donné par la formule suivante :
   écrire la formule énorme.