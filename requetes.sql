-- Les utilisateurs ayant assisté à un évènement dans un lieu donné
\set lieu 'stade de france'

select u.id, u.nom as u_nom, u.prenom, e.nom as e_nom, e.date_rdv
from
  utilisateur u
  join presence p on p.utilisateur = u.id
  join evenement e on p.evenement = e.id
  join lieu l on e.lieu_rdv = l.id
where l.nom = :'lieu';

\unset lieu

-- Les utilisateurs qui sont compatibles d'un point de vue orientation
select u1.id, u1.nom, u1.prenom, u2.id, u2.nom, u2.prenom
from
  util_desc u1
  join util_desc u2
  on u1.id <> u2.id
  and (u1.pref is null or u1.pref::text in ('tout', u2.genre::text))
  and (u2.pref is null or u2.pref::text in ('tout', u1.genre::text));

-- Les lieux dans la ville d'un utilisateur où aucun évènement n'est prévu
\set util 'robinm'

-- Renvoie ce que l'on veut
select l.id, l.nom, l.adresse
from
  utilisateur u
  join lieu l using (ville)
where u.id = :'util' and not exists (
  select 1
  from evenement_futur natural join evenement e
  where e.lieu_rdv = l.id
);

-- Renvoie ce que l'on veut si AUCUN évènement n'a un lieu_rdv à null, sinon
-- elle renvoie toujours la table vide
select l.id, l.nom, l.adresse
from
  utilisateur u
  join lieu l on l.ville = u.ville
where u.id = :'util' and l.id not in (
  select lieu_rdv
  from evenement_futur natural join evenement
);

-- Version corrigée qui renvoie toujours ce qu'on veut
select l.id, l.nom, l.adresse
from
  utilisateur u
  join lieu l on l.ville = u.ville
where u.id = :'util' and l.id not in (
  select lieu_rdv
  from evenement_futur natural join evenement
  where lieu_rdv is not null
);

\unset util

-- TODO: sous requête dans le FROM

-- Les utilisateurs ayant assisté à tous les évènements sur Paris depuis un mois
-- Autrement dit les utilisateurs pour lesquels ils n'existe pas d'évènement sur
--   Paris de moins d'un mois auquel il n'a pas assisté
select id, nom, prenom
from utilisateur u
where id not in (
  select utilisateur
  from
    presence p
    join evenement_termine et on et.id = p.evenement
    join evenement e on e.id = et.id
    join lieu l on l.id = e.lieu_rdv
    join ville v on v.code = l.ville
  where age(e.date_rdv) < interval '1 month'
  and v.nom = 'Paris'
);

-- TODO: 2 agrégats

-- Les utilisateurs qui ont moins aimé que la moyenne 4 évènements

-- Le(s) lieu(x) qui ouvre(nt) le plus tôt
