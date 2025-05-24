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


-- Scores de Critère


--0.5 * score age + 0.125 * score taille + 0.125 * score poids + 0.125 * score cheveux + 0.125 * score yeux

--score age -> score_ecart (notre_age - age_recommandation,5)
--score taille -> score_ecart (notre_taille - taille_recommandation,20)
--score poids -> score_ecart (notre_poids - poids_recommandation,20)

 with prefs as (
    select *
    from preference
    where chercheur = :'util'
), autres as (
    select *
    from description
    where id <> :'util'
), compatibilite as (
  select *
  from util_desc u1, util_desc u2
  where
  u1.id = :'util' and u1.id <> u2.id
    and (u1.pref is null or u1.pref::text in ('tout', u2.genre::text))
    and (u2.pref is null or u2.pref::text in ('tout', u1.genre::text))
)
select
    a.id,
    max(
        coalesce(0.5   * (extract(year from age(naissance)) between age_min and age_max)::int, 0) +
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





\unset util
