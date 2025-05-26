\set util 'fernanda'

drop function if exists score_ecart;
create function score_ecart (val numeric, seuil numeric) returns numeric as $$
  select greatest(0, 1 - (val / seuil)^2) as score
$$ language SQL;

with compatibilite as (
  -- On détermine avec qui util peut être compatible
  select u2.id, u2.naissance, u2.ville
  from util_desc u1, util_desc u2
  where
    u1.id = :'util' and u1.id <> u2.id
    and (u1.pref is null or u1.pref::text in ('tout', u2.genre::text))
    and (u2.pref is null or u2.pref::text in ('tout', u1.genre::text))
),
score_proximite as (
  -- Proximité entre la ville de a et celle de util
  select a.id,
    case
      when a.ville = ref.ville then 1
      when a.dep = ref.dep then 0.75
      when a.reg = ref.reg then 0.25
      else 0
    end as score_prox
  from
    (select ville.code as ville, departement.code as dep, region.code as reg
      from
        ville
        join departement on ville.departement = departement.code
        join region on departement.region = region.code
        join utilisateur on ville.code = utilisateur.ville
      where utilisateur.id = :'util') ref,
    (select ville.code as ville, departement.code as dep, region.code as reg, compatibilite.id
      from
      ville
        join departement on ville.departement = departement.code
        join region on departement.region = region.code
        join compatibilite on ville.code = compatibilite.ville) a
),
score_tags as (
  -- Proportion de tags partagés par util et autre parmi les tags qu'ils utilisent
  select u.id, (
    with T1 as (select tag from tag_utilisateur where utilisateur = :'util'),
         T2 as (select tag from tag_utilisateur where utilisateur = u.id),
         I as ((select * from T1) intersect all (select * from T2)),
         U as ((select * from T1) union all (select * from T2))
    select 1. * (select count(*) from I) / greatest((select count(*) from U), 1.) as score_t
  )
  from compatibilite u
),
score_evenements as (
  -- Proportion d'évènements partagés par util et autre parmi les évènements
  -- auxquels ils ont été
  select u.id, (
    with T1 as (select evenement from presence where utilisateur = :'util'),
         T2 as (select evenement from presence where utilisateur = u.id),
         I as ((select * from T1) intersect all (select * from T2)),
         U as ((select * from T1) union all (select * from T2))
  select 1. * (select count(*) from I) / greatest((select count(*) from U), 1.) as score_e
  )
  from compatibilite u
),
score_preferences as (
  -- Score de proximité entre l'utilisateur a et les critères de util
  select a.id, max(
    0.5 * (extract(year from age(a.naissance)) between coalesce(age_min,0) and coalesce(age_max,100))::int
    + coalesce(0.125 * score_ecart(a.taille - p.taille, 10), 0)
    + coalesce(0.125 * score_ecart(a.poids - p.poids, 10), 0)
    + coalesce(0.125 * (a.couleur_cheveux = p.couleur_cheveux)::int, 0)
    + coalesce(0.125 * (a.couleur_yeux = p.couleur_yeux)::int, 0)
  ) as score_p
  from
    (compatibilite natural left join description) a,
    (select *
     from (values (:'util')) t(chercheur) natural left join preference
     where chercheur = :'util') p
  group by a.id
)
-- On assemble tous les scores
select
  id,
  round(0.4 * score_p + 0.3 * score_e + 0.2 * score_t + 0.1 * score_prox, 3) as score
from
  score_tags
  natural join score_evenements
  natural join score_preferences
  natural join score_proximite
order by score desc;

\unset util
