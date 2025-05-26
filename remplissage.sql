-- GÉOGRAPHIE (données de l'INSEE) --
create temporary table tmp_reg (
  reg char(2),
  cheflieu char(5),
  tncc char(1),
  ncc text,
  nccenr text,
  libelle text
);

\copy tmp_reg from 'data/region.csv' with (format csv, header true)
insert into region (code, nom)
  select reg, libelle from tmp_reg;

drop table tmp_reg;

create temporary table tmp_dep (
  dep char(3),
  reg char(2),
  cheflieu char(5),
  ttcn char(1),
  ncc text,
  nccenr text,
  libelle text
);

\copy tmp_dep from 'data/departement.csv' with (format csv, header true)
insert into departement (code, nom, region)
  select dep, libelle, reg from tmp_dep;

drop table tmp_dep;

create temporary table tmp_ville (
  typecom char(4),
  com char(5),
  reg char(2),
  dep char(3),
  ctcd char(4),
  arr char(4),
  tncc char(1),
  ncc text,
  nccenr text,
  libelle text,
  can char(5),
  comparent char(5)
);

\copy tmp_ville from 'data/commune.csv' with (format csv, header true)
insert into ville (code, nom, departement)
  select com, libelle, dep from tmp_ville where typecom = 'COM';

drop table tmp_ville;

-- LIEUX --
create temporary table tmp_lieu (
  id text,
  nom text,
  adresse text,
  ville char(5),
  description text,
  ouverture time,
  fermeture time,
  type_lieu text
);

\copy tmp_lieu from 'data/lieu.csv' with (format csv, header true)
insert into lieu(id, nom, adresse, ville, description, ouverture, fermeture, type_lieu)
  select id, nom, adresse, ville, description, ouverture, fermeture, type_lieu
  from tmp_lieu;

drop table tmp_lieu;

create temporary table tmp_tag_l (
  lieu text,
  tag text,
  source text
);

\copy tmp_tag_l from 'data/tag_lieu.csv' with (format csv, header true)
insert into tag_lieu (lieu, tag, source)
  select distinct lieu, tag, source
  from tmp_tag_l;

drop table tmp_tag_l;

-- UTILISATEURS --
create temporary table tmp_util (
  id text,
  nom text,
  prenom text,
  naissance date,
  bio text,
  ville char(5),
  abonne boolean,
  inscription date
);

\copy tmp_util from 'data/utilisateur.csv' with (format csv, header true)
insert into utilisateur (id, nom, prenom, naissance, bio, ville, abonne, inscription)
  select id, nom, prenom, naissance, bio, ville, abonne, inscription
  from tmp_util;

drop table tmp_util;

create temporary table tmp_desc (
  id text,
  genre genre_t,
  pref pref_t,
  couleur_cheveux text,
  couleur_yeux text,
  poids int,
  taille int
);

\copy tmp_desc from 'data/description.csv' with (format csv, header true)
insert into description (id, genre, pref, couleur_cheveux, couleur_yeux, poids, taille)
  select id, genre, pref, couleur_cheveux, couleur_yeux, poids, taille
  from tmp_desc;

drop table tmp_desc;

create temporary table tmp_avis (
  source text,
  destination text,
  type_avis avis_t,
  date_avis date
);

\copy tmp_avis from 'data/avis.csv' with (format csv, header true)
insert into avis (source, destination, type_avis, date_avis)
  select source, destination, type_avis, date_avis
  from tmp_avis;

drop table tmp_avis;

create temporary table tmp_preference (
  chercheur text,
  couleur_cheveux text,
  couleur_yeux text,
  poids int,
  taille int,
  age_min int,
  age_max int
);

\copy tmp_preference from 'data/preference.csv' with (format csv, header true)
insert into preference (chercheur, couleur_cheveux, couleur_yeux, poids, taille, age_min, age_max)
  select chercheur, couleur_cheveux, couleur_yeux, poids, taille, age_min, age_max
  from tmp_preference;

drop table tmp_preference;

create temporary table tmp_tag_u (
  utilisateur text,
  tag text,
  source text
);

\copy tmp_tag_u from 'data/tag_utilisateur.csv' with (format csv, header true)
insert into tag_utilisateur (utilisateur, tag, source)
  select distinct utilisateur, tag, source
  from tmp_tag_u;

drop table tmp_tag_u;

-- ÉVÈNEMENTS --
create temporary table tmp_ev (
  id int,
  source text,
  nom text,
  organisateur text,
  date_rdv timestamp,
  lieu_rdv text,
  description text,
  prix int,
  nb_places int
);

\copy tmp_ev from 'data/evenement.csv' with (format csv, header true)
with ins as (
  insert into evenement (id, source, nom, organisateur, date_rdv, lieu_rdv, description, prix, nb_places)
    select id, source, nom, organisateur, date_rdv, lieu_rdv, description, prix, nb_places
    from tmp_ev
  returning *
)
select setval('preference_id_seq', (select count(*) from ins), false);

drop table tmp_ev;

create temporary table tmp_rep (
  utilisateur text,
  evenement int,
  reponse reponse_t
);

create temporary table tmp_fut (
  id int
);

\copy tmp_rep from 'data/reponse.csv' with (format csv, header true)
\copy tmp_fut from 'data/futur.csv' with (format csv, header true)

insert into evenement_futur (id, places_restantes)
  select
    tmp_fut.id,
    (select evenement.nb_places from evenement where evenement.id = tmp_fut.id)
    - (select count(*) from tmp_rep where tmp_rep.evenement = tmp_fut.id and tmp_rep.reponse = 'participe')
  from tmp_fut;

insert into reponse (utilisateur, evenement, reponse)
  select utilisateur, evenement, reponse
  from tmp_rep;

drop table tmp_rep;
drop table tmp_fut;

create temporary table tmp_ter (
  id int
);

\copy tmp_ter from 'data/termine.csv' with (format csv, header true)
insert into evenement_termine (id)
  select id
  from tmp_ter;

drop table tmp_ter;

create temporary table tmp_pres (
  utilisateur text,
  evenement int,
  note int
);

\copy tmp_pres from 'data/presence.csv' with (format csv, header true)
insert into presence (utilisateur, evenement, note)
  select utilisateur, evenement, note
  from tmp_pres;

drop table tmp_pres;

create temporary table tmp_tag_e (
  evenement int,
  tag text,
  source text
);

\copy tmp_tag_e from 'data/tag_evenement.csv' with (format csv, header true)
insert into tag_evenement (evenement, tag, source)
  select distinct evenement, tag, source
  from tmp_tag_e;

drop table tmp_tag_e;
