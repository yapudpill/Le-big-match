-- Les utilisateurs ayant assisté à un évènement au state de france
select u.id, u.nom, u.prenom, e.nom, e.date_rdv
from
  utilisateur u
  join presence p on p.utilisateur = u.id
  join evenement e on p.evenement = e.id
  join lieu l on e.lieu_rdv = l.id
where l.nom = 'state de france';

-- Les utilisateurs qui sont compatibles d'un point de vue orientation
select u1.id, u1.nom, u1.prenom, u2.id, u2.nom, u2.prenom
from
  util_desc u1
  join util_desc u2
  on u1.id <> u2.id
  and (u1.pref is null or u1.pref::text in ('tout', u2.genre::text))
  and (u2.pref is null or u2.pref::text in ('tout', u1.genre::text));
