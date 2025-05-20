\set util 'fernanda'

drop function if exists score_ecart;
create function score_ecart (val int, seuil int) returns int as $$
  select greatest(0, 1 - (val / seuil)^2) as score
$$ language SQL;

-- Compatibilité
select u2.id, u2.nom, u2.prenom
from util_desc u1, util_desc u2
where
  u1.id = :'util' and u1.id <> u2.id
  and (u1.pref is null or u1.pref::text in ('tout', u2.genre::text))
  and (u2.pref is null or u2.pref::text in ('tout', u1.genre::text));

-- Scores de tags
select u.id, (
  with T1 as (
    select tag from tag_utilisateur where utilisateur = :'util'
  ), T2 as (
    select tag from tag_utilisateur where utilisateur = u.id
  )
  select
    (select count(*) from ((select *  from T1) intersect (select * from T2)) t) /
    greatest((select count(*) from ((select *  from T1) union (select * from T2)) t), 1)
    as score
)
from utilisateur u;

\unset util
