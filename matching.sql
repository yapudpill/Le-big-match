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
    from cherche
    where chercheur = :'util'
), autres as (
    select *
    from description
    where id <> :'util'
)
select
    a.id,max(
        0.5   * score_ecart((((current_date - u.naissance) / 365.25)::int - p.age), 5) +
        0.125 * score_ecart((a.taille - p.taille), 20) +
        0.125 * score_ecart((a.poids - p.poids), 20) +
        0.125 * case when a.couleur_cheveux = p.couleur_cheveux then 1 else 0 end +
        0.125 * case when a.couleur_yeux = p.couleur_yeux then 1 else 0 end)
     as score
from autres a, utilisateur u, prefs p
where u.id = a.id
group by a.id;






\unset util
