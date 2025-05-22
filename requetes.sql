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

-- Les matchs effectifs
select source, destination
from avis
where type_avis = 'like'
and (destination, source) in (
  select source, destination
  from avis
  where type_avis = 'like'
);

-- Les lieux dans la ville d'un utilisateur où aucun évènement n'est prévu
-- (3 prochaines requêtes)
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

-- Score de proximité d'une ville donnée avec toutes les autres
\set ville_id '92002'

select ville.nom, ville.code,
  case
    when ville.code = ville_ref.code then 1
    when departement.code = ville_ref.dep then 0.75
    when region.code = ville_ref.reg then 0.25
    else 0
  end as proximite
from
  (select ville.code as code, departement.code as dep, region.code as reg
    from
      ville
      join departement on ville.departement = departement.code
      join region on departement.region = region.code
    where ville.code = :'ville_id'
  ) as ville_ref,
  ville
  join departement on ville.departement = departement.code
  join region on departement.region = region.code;

\unset ville_id

-- Les utilisateurs ayant assisté à tous les évènements sur Paris depuis un mois
-- Autrement dit les utilisateurs pour lesquels ils n'existe pas d'évènement sur
--   Paris de moins d'un mois auquel il n'a pas assisté
-- (2 prochaines requêtes)

-- Celle-ci est rapide...
select u.id
from utilisateur u
where not exists (
  select 1
  from
    evenement e
    join ville v on v.code = e.lieu_rdv
  where v.nom = 'Paris' and age(e.date_rdv) < interval '1 month'
  and (e.id, u.id) not in (select evenement, utilisateur from presence)
);

-- ...et celle-là fait la même chose plus lentement
select u.id
from utilisateur u
where not exists (
  select e.id
  from
    evenement e
    join ville v on v.code = e.lieu_rdv
  where v.nom = 'Paris' and age(e.date_rdv) < interval '1 month'
  except
  select p.evenement
  from presence p
  where p.utilisateur = u.id
);

-- Les utilisateurs qui ont moins aimé que la moyenne, 4 évènements
select utilisateur
from presence p1
where note < (
  select avg(note)
  from presence p2
  where note is not null and p1.evenement = p2.evenement
)
group by utilisateur
having count(*) >= 4;

-- Le(s) lieu(x) qui ouvre(nt) le plus tôt
select id, nom
from (
  select id, nom, rank() over (order by ouverture)
  from lieu
) t
where rank = 1;

-- Pour chaque mois de 2025, l'utilisateur le plus nopé
with nb_nopes as (
  select destination, extract(month from date_avis) as mois, count(*) as nopes
  from avis
  where type_avis = 'nope' and extract(year from date_avis) = 2025
  group by destination, mois
)
select *
from nb_nopes n1
where nopes = (select max(nopes) from nb_nopes n2 where n1.mois = n2.mois)
order by mois;
