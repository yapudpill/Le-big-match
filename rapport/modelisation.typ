Voici le diagramme ER que nous avons établi à partir du sujet et en fonction duquel la base de donnée a été construite :

#image("../diagrammes/diagramme_ER.svg")

_Note : Si l'image vectorielle ne s'affiche pas correctement, il y a aussi le fichier #link("../diagrammes/diagramme_ER.png", `diagramme_ER.png`)_

Nous avons découpé les informations du sujet 4 catégories : ce qui concerne les utilisateurs, les évènements, les lieux et les tags. Nous avons également ajouté une 5ème catégorie concernant la géographie pour pouvoir évaluer la distance entre deux villes.

La catégorie la plus simple est justement cette catégorie de géographie. Elle contient une représentation simplifiée de la France avec ses villes, départements et régions imbriqués. Cette modélisation permet deux choses : on peut grossièrement estimer la proximité entre deux villes (même si ça fonctionne en réalité mal pour les villes en bordure de département/région) ; et on peut proposer aux utilisateurs de l'appli une auto complétion des champs de villes.

Concernant la catégorie des utilisateurs, la plus importante, elle contient évidemment l'entité centrale `Utilisateur` qui représente un utilisateur de l'application avec ses informations personnelles et les variables internes de l'appli comme la date d'inscription et le status de l'abonnement. Cette entité est également liée à la ville où déclare habiter l'utilisateur. Pour ne pas trop charger cette entité (et la table SQL qui en résulte), la description physique des utilisateurs est stockée dans l'entité faible `Description`, elle est faible car rien à part son leur utilisateur associé ne permet de d'identifier de façon unique les descriptions. Un utilisateur peut ensuite exprimer plusieurs préférences/critères de recherche concernant les profils qu'il souhaite rencontrer. Ces préférences sont représentée par l'entité du même nom.

Le système de like/nope est représenté par l’association réflexive `Avis` qui s’interprete comme "`<source>` a liké/nopé `<destination>`", le type de l'avis indique s'il s'agit d'un like ou d'un nope. Une condition externe implémentable en SQL avec un check a été précisée sur cette relation pour empêcher dun utilisateur de se donner un avis à soit-même.

Ces utilisateurs assistent à des évènements ayant diverses caractéristiques : nom, date, description, nombre de place, organisateur... Comme les évènements peuvent également être importés par l'application depuis des sites externes, l'attribut `source` permet de garder une trace de la provenance d'un évènement. On utilise `lbm` pour les évènements déclarés depuis l'application. On a distingué 3 types d'évènements formant un héritage total et disjoint : les évènements à venir, qui ont un nombre de places restantes et auxquels les utilisateurs peuvent informer de leur présence (`assiste`, `interesse` ou `pas_interesse`) ; les évènements terminées auxquels les utilisateurs peuvent laisser une note de 0 à 10 ; enfin les évènements annulés ayant une raison de l'annulation.

Les évènements se passent eux mêmes dans des lieux ayant un no, une adresse dans une ville, une description, des horaires...

Enfin la dernière catégorie concerne les tags. Ils s'agit simplement d'une seule entité avec un seul attribut pour le mot clé associé à ce tag. Les trois entités principales (utilisateur, évènement, lieu) peuvent être associées à un nombre arbitraire de tags. On se sert également du système de tags pour stocker les informations inférées concernant un utilisateur/évènement/lieu. Par exemple, si un utilisateur like des musiques de jazz sur spotify, on lui inferera le tag jazz ainsi que le titre des morceaux et du nom des artistes. L'attribut source permet, comme pour les évènements, de garder une trace de la provenance d'un tag.
