\set util 'u1'
\set util 'u2'

with  T1 as (
        select * from tag_utilisateur where utilisateur = 'u1'
    ), T2 as (
        select * from tag_utilisateur where utilisateur = 'u2'
    )
    select ( select count(*) from T1 intersect T2) / ( select count(*) from T1 union T2)
    as score from utilisateur u




\unset util