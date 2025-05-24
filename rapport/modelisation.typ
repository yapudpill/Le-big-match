Voici le diagramme ER que nous avons établi à partir du sujet et en fonction duquel la base de donnée a été construite :

#image("../diagrammes/diagramme_ER.svg")

_Note : Si l'image vectorielle ne s'affiche pas correctement, il y a aussi le fichier #link("../diagrammes/diagramme_ER.png", `diagramme_ER.png`)_

Nous avons découpé les informations du sujet 4 catégories : ce qui concerne les utilisateurs, les évènements, les lieux et les tags. Nous avons également ajouté une 5ème catégorie concernant la géographie pour pouvoir évaluer la distance entre deux villes.

Concernant la catégorie des utilisateurs, elle contient évidemment l'entité centrale `Utilisateur` qui représente un utilisateur de l'application avec ses informations personnelles et les variables internes de l'appli comme la date d'inscription et le status de l'abonnement. Pour ne pas trop charger cette entité (et la table SQL qui en résulte), la description physique des utilisateurs est stockée dans l'entité faible `Description`, elle est faible car rien à part son leur utilisateur associé ne permet de d'identifier de façon unique les descriptions.

Un utilisateur peut ensuite exprimer plusieurs préférences concernant les profils qu'il recherche TODO
