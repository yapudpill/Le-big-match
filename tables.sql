-- DROP --
drop view if exists util_desc, match_eff;
drop table if exists
  region, departement, ville,
  lieu, tag_lieu,
  utilisateur, description, preference, avis, tag_utilisateur, tag_utilisateur,
  evenement, evenement_futur, evenement_termine, evenement_annule, reponse, presence, tag_evenement;
drop type if exists genre_t, pref_t, avis_t, reponse_t;

-- TYPES --
create type genre_t as enum ('homme', 'femme', 'autre');
create type pref_t as enum ('homme', 'femme', 'tout');
create type avis_t as enum ('like', 'nope');
create type reponse_t as enum ('interesse', 'participe', 'pas interesse');

-- GÉOGRAPHIE --
create table region (
  code char(2) primary key,
  nom  text not null
);

create table departement (
  code   char(3) primary key,
  nom    text not null,
  region char(2) not null references region(code)
);

create table ville (
  code        char(5) primary key,
  nom         text,
  departement char(3) references departement(code)
);

-- LIEUX --
create table lieu (
  id          text primary key check (id <> ''),
  nom         text not null check (nom <> ''),
  adresse     text,
  ville       char(5) references ville(code),
  description text,
  ouverture   time,
  fermeture   time,
  type_lieu   text
);

create table tag_lieu (
  lieu   text references lieu(id),
  tag    text,
  source text not null,
  primary key (lieu, tag)
);

-- UTILISATEURS --
create table utilisateur (
  -- Infos utilisateur
  id        text primary key check (id <> ''),
  nom       text not null check (nom <> ''),
  prenom    text not null check (prenom <> ''),
  naissance date not null check (age(naissance) >= interval '18 years'),
  bio       text,
  ville     char(5) references ville(code),

  -- Interne appli
  abonne      boolean not null,
  inscription timestamp not null default current_timestamp
);

create table description (
  id              text primary key references utilisateur(id),
  genre           genre_t,
  pref            pref_t,
  couleur_cheveux text,
  couleur_yeux    text,
  poids           int check (poids > 0), -- kg
  taille          int check (taille > 0) -- cm
);

create view util_desc as
  select * from utilisateur left join description using (id);

create table preference (
  id              serial primary key,
  chercheur       text not null references utilisateur(id),
  couleur_cheveux text,
  couleur_yeux    text,
  poids           int check (poids > 0),
  taille          int check (taille > 0),
  age_min         int check (age_min >= 18),
  age_max         int check (age_max >= age_min)
);

-- Contrainte externe : un avis n'est modifiable ssi l'utilisateur est abonné
create table avis (
  source      text references utilisateur(id),
  destination text references utilisateur(id),
  type_avis   avis_t not null,
  date_avis   timestamp not null default current_timestamp,
  check (source <> destination),
  primary key (source, destination)
);

create view match_eff as
  select source, destination
  from avis
  where type_avis = 'like'
  and (destination, source) in (
    select source, destination
    from avis
    where type_avis = 'like'
  );

create table tag_utilisateur (
  utilisateur text references utilisateur(id),
  tag         text,
  source      text not null,
  primary key (utilisateur, tag)
);

-- ÉVÈNEMENTS --
create table evenement (
  -- Interne appli
  id               serial primary key,
  date_publication timestamp not null default current_timestamp,
  source           text not null,

  -- Infos évènement
  nom          text not null check (nom <> ''),
  organisateur text not null references utilisateur(id),
  date_rdv     timestamp not null,
  lieu_rdv     text references lieu(id),
  description  text,
  prix         int check (prix >= 0), -- centimes
  nb_places    int check (nb_places > 0)
);

-- Condition externe : on suppose qu'un script passe régulièrement pour déplacer
-- les évènements dans la bonne table, tous les évènements doivent être dans une
-- et une seule table
create table evenement_futur (
  id               int primary key references evenement(id),
  places_restantes int check (places_restantes >= 0)
);

create table evenement_termine (
  id int primary key references evenement(id)
);

create table evenement_annule (
  id     int primary key references evenement(id),
  raison text
);

create table reponse (
  utilisateur  text references utilisateur(id),
  evenement    int references evenement_futur(id),
  reponse      reponse_t not null,
  primary key (utilisateur, evenement)
);

create table presence (
  utilisateur text references utilisateur(id),
  evenement   int references evenement_termine(id),
  note        int check (0 <= note and note <= 10),
  primary key (utilisateur, evenement)
);

create table tag_evenement (
  evenement int references evenement(id),
  tag       text,
  source    text not null,
  primary key (evenement, tag)
);
