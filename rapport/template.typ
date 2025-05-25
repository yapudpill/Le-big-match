#import "@preview/great-theorems:0.1.2": *
#import "@preview/zebraw:0.5.4": *

// Change accent color here
#let accent-color = rgb("#8A1538")
#let accent-text = text.with(fill: accent-color)

// Maths blocs
#let mathcounter = counter("math")
#let myblock(name) = mathblock.with(
  blocktitle: name,
  prefix: nb => accent-text[*#name #nb :*],
  counter: mathcounter,
  inset: (y: 0.325em)
)

#let theorem = myblock("Théorème")(
  inset: (y: 0.325em, left: 6pt),
  stroke: (left: 2pt + accent-color),
)

#let corollary = myblock("Corollaire")()
#let definition = myblock("Définition")()

#let proof = proofblock(
  prefix: accent-text[_Démonstration :_\ ],
  suffix: accent-text[#h(1fr) $square.filled$]
)

// Document template
#let template(
  title: "",
  subtitle: none,
  authors: (),
  enable-outline: false,
  front-page: false,
  body,
) = {

  // Document config
  set document(title: title, author: authors)
  set page(numbering: "1")
  set text(lang: "fr")
  set heading(numbering: "I - 1 - a.")
  set par(justify: true)
  show heading: accent-text
  show link: accent-text
  show ref: accent-text
  show math.equation: box
  show raw.where(block: false): it => box(it, fill: luma(245), inset: (x:2pt), outset: (y: 3pt), radius: 2pt)

  show: great-theorems-init
  show: zebraw.with(numbering-separator: true, indentation: 2, lang: false)

  // Insert logo
  align(center)[
    #image("logo.png", width: 2cm)
  ]

  // Header
  line(length: 100%, stroke: accent-color)
  align(center)[
    #box(accent-text(size: 1.75em, weight: "bold", smallcaps(title)))

    #box(accent-text(size: 1.5em, subtitle))
  ]
  line(length: 100%, stroke: accent-color)

  // Authors
  align(center,
    grid(
      columns: (1fr,) * authors.len(),
      align: center,
      ..authors.map(a => text(size: 1.2em, style: "italic", a))
    )
  )

  if enable-outline {
    align(horizon)[
      #outline()
    ]
  }

  if front-page { pagebreak() }

  body
}
