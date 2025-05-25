\set util 'fernanda'

drop function if exists score_ecart;
create function score_ecart (val int, seuil int) returns int as $$
  select greatest(0, 1 - (val / seuil)^2) as score
$$ language SQL;

-- Compatibilité
select u2.id, u2.nom, u2.prenom, u2.naissance
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
from (select u2.id, u2.nom, u2.prenom
from util_desc u1, util_desc u2
where
  u1.id = :'util' and u1.id <> u2.id
  and (u1.pref is null or u1.pref::text in ('tout', u2.genre::text))
  and (u2.pref is null or u2.pref::text in ('tout', u1.genre::text))) u;


-- Scores de Critère


--0.5 * score age + 0.125 * score taille + 0.125 * score poids + 0.125 * score cheveux + 0.125 * score yeux

--score taille -> score_ecart (notre_taille - taille_recommandation,20)
--score poids -> score_ecart (notre_poids - poids_recommandation,20)

with compatibilite as (
  select u2.id, u2.nom, u2.prenom, u2.naissance
  from util_desc u1, util_desc u2
  where
    u1.id = :'util' and u1.id <> u2.id
    and (u1.pref is null or u1.pref::text in ('tout', u2.genre::text))
    and (u2.pref is null or u2.pref::text in ('tout', u1.genre::text))
)
select
    a.id,
    max(
        coalesce(0.5   * (extract(year from age(u.naissance))
          between coalesce(age_min,0) and coalesce(age_max,100))::int, 0) +
        coalesce(0.125 * score_ecart((a.taille - p.taille), 10), 0) +
        coalesce(0.125 * score_ecart((a.poids - p.poids), 10), 0) +
        coalesce(0.125 * (a.couleur_cheveux = p.couleur_cheveux)::int, 0) +
        coalesce(0.125 * (a.couleur_yeux = p.couleur_yeux)::int, 0)
    ) as score
from  (select * from description where id <> :'util') a,
      compatibilite u,
      (select * from preference where chercheur = :'util') p
where u.id = a.id
group by a.id;


-- Scores d'évènements
select u.id, (
  with E1 as (
    select evenement from presence p where p.utilisateur = :'util'
  ), E2 as (
    select evenement from presence p where p.utilisateur = u.id
  )
  select
    (select count(*) from ((select *  from E1) intersect (select * from E2)) t) /
    greatest((select count(*) from ((select *  from E1) union (select * from E2)) t), 1)
    as score
)
from (select u2.id, u2.nom, u2.prenom
from util_desc u1, util_desc u2
where
  u1.id = :'util' and u1.id <> u2.id
  and (u1.pref is null or u1.pref::text in ('tout', u2.genre::text))
  and (u2.pref is null or u2.pref::text in ('tout', u1.genre::text))) u;


-- Requête avec score final

with compatibilite as (
  select u2.id, u2.nom, u2.prenom, u2.naissance
  from util_desc u1, util_desc u2
  where
    u1.id = :'util' and u1.id <> u2.id
    and (u1.pref is null or u1.pref::text in ('tout', u2.genre::text))
    and (u2.pref is null or u2.pref::text in ('tout', u1.genre::text))
), score_tags as (
    select u.id, (
    with T1 as (
      select tag from tag_utilisateur where utilisateur = :'util'
    ), T2 as (
      select tag from tag_utilisateur where utilisateur = u.id
    )
    select
      (select count(*) from ((select *  from T1) intersect (select * from T2)) t) /
      greatest((select count(*) from ((select *  from T1) union (select * from T2)) t), 1)
      as score_t
    )
    from utilisateur u
  ), score_evenements as (
    select u.id, (
    with E1 as (
      select evenement from presence p where p.utilisateur = :'util'
    ), E2 as (
      select evenement from presence p where p.utilisateur = u.id
    )
    select
      (select count(*) from ((select *  from E1) intersect (select * from E2)) t) /
      greatest((select count(*) from ((select *  from E1) union (select * from E2)) t), 1)
      as score_e
    )
    from utilisateur u
  ), score_preferences as (
    select a.id,
        max(
            coalesce(0.5   * (extract(year from age(u.naissance))
              between coalesce(age_min,0) and coalesce(age_max,100))::int, 0) +
            coalesce(0.125 * score_ecart((a.taille - p.taille), 10), 0) +
            coalesce(0.125 * score_ecart((a.poids - p.poids), 10), 0) +
            coalesce(0.125 * (a.couleur_cheveux = p.couleur_cheveux)::int, 0) +
            coalesce(0.125 * (a.couleur_yeux = p.couleur_yeux)::int, 0)
        ) as score_p
    from  (select * from description where id <> :'util') a,
          compatibilite u,
          (select * from preference where chercheur = :'util') p
    where u.id = a.id
    group by a.id
  )
select sp.id, (0.5*score_p + 0.3*score_e + 0.2*score_t) as score
from score_preferences sp, score_evenements se, score_tags st
where sp.id = se.id and se.id = st.id;


\unset util



