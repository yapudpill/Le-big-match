#import "template.typ": template
#show: template.with(
  title: "Projet de Bases de données",
  subtitle: "Le Big Match",
  authors: ("Anthony Fernandes", "Marc Robin"),
)

= Modélisation ER

#include "modelisation.typ"

= Schéma relationnel

#include "schema.typ"

= Algorithme de matching

#include "matching.typ"

= Limitations

#include "limitations.typ"