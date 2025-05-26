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

-- Les matchs effectifs (définition de la vue match_eff)
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
-- (3 prochaines requêtes)

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

-- ...et celle-là fait la même chose plus lentement...
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

-- ...et maintenant avec de l'agrégation
with evenement_paris as (
  select e.id as evenement
  from
    evenement e
    join ville v on v.code = e.lieu_rdv
  where v.nom = 'Paris' and age(e.date_rdv) < interval '1 month'
)
select utilisateur
from presence natural join evenement_paris
group by utilisateur
having count(*) = (select count(*) from evenement_paris);

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

-- Les lieux n'ayant pas accueilli d'évènement depuis plus d'un mois
select l.id, l.nom
from lieu l
where not exists (
  select 1
  from evenement e
  where age(e.date_rdv) <= interval '1 month'
  and e.lieu_rdv = l.id
);

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

-- Le nombre d'utilisateur de la plateforme, mois par mois depuis de 1/1/25
select
  annee, mois,
  sum(cpt) over (order by annee, mois)
    + (select count(*) from utilisateur where inscription < date '2025-01-01') as nb_util
from (
  select
    extract(year from inscription) as annee,
    extract(month from inscription) as mois,
    count(*) as cpt
  from utilisateur
  where inscription >= date '2025-01-01'
  group by annee, mois
) t
order by annee, mois;

-- Le top 10 des tags les plus utilisés
select tag, count(*) as cpt
from (
  select tag from tag_utilisateur
  union
  select tag from tag_lieu
  union
  select tag from tag_evenement
) t
group by tag
order by cpt
limit 10;

-- Les organisateurs les plus populaires, classés par nombre d'utilisateur ayant
-- assisté aux évènements qu'ils sont organisé et n'ayant pas laissé de mauvaise
-- note
select rank() over (order by count(*)) as classement, organisateur
from
  evenement
  join presence on evenement = id
where note is null or note >= 5
group by organisateur
order by classement;

-- Vérification de la cohérence des tables d'évènement. Cette requête renvoie
-- la liste des évènements pour lesquels il y a une incohérence dans leur
-- appartenance aux tables evenement_*
select *
from
  evenement e
  left join evenement_futur f on f.id = e.id
  left join evenement_termine t on t.id = e.id
  left join evenement_annule a on a.id = e.id
where
  (f.id is not null)::int + (t.id is not null)::int + (a.id is not null)::int <> 1
  or (t.id is not null and e.date_rdv >= current_date)
  or (f.id is not null and e.date_rdv < current_date);

-- La prochaine disponibilité d'un lieu donné après le 01/09/2025
-- remplacer la date par current_date pour avoir la prochaine disponibilité à
-- partir de maintenant

\set l 'UP7'

with recursive occupe (d) as (
  select date '2025-09-01'
  union
  select d + 1
  from
    evenement
    join lieu on evenement.lieu_rdv = lieu.id
    join occupe on evenement.date_rdv::date = occupe.d + 1
  where lieu.id = :'l'
)
select max(d) + 1
from occupe;

\unset l
