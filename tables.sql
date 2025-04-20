-- TYPES --
create type genre_t as enum ('homme', 'femme', 'autre');
create type orientation_t as enum ('hetero', 'homo', 'bi', 'autre');
create type avis_t as enum ('like', 'nope');

-- GÉOGRAPHIE (données de l'INSEE) --
drop table if exists region cascade;
create table region (
    code char(2) primary key,
    nom  text not null
);

drop table if exists departement cascade;
create table departement (
    code   char(3) primary key,
    nom    text not null,
    region char(2) not null references region(code)
);

drop table if exists ville cascade;
create table ville (
    code        char(5) primary key,
    nom         text,
    departement char(3) references departement(code)
);

-- LIEUX --
drop table if exists lieu cascade;
create table lieu (
    id          text primary key check (id <> ''),
    nom         text not null check (nom <> ''),
    adresse     text,
    ville       char(5) references ville(code),
    description text,
    ouverture   time,
    fermeture   time,
    type_lieu   text
    -- affluence_moyenne quel type ?
);

-- UTILISATEURS --
drop table if exists utilisateur cascade;
create table utilisateur (
    -- Infos utilisateur
    id        text primary key check (id <> ''),
    nom       text not null check (nom <> ''),
    prenom    text not null check (prenom <> ''),
    naissance date not null check (current_date >= naissance + interval '18 years'),
    bio       text,
    ville     char(5) references ville(code),

    -- Interne appli
    abonne      boolean not null,
    inscription timestamp not null default current_timestamp,

    -- Description
    genre           genre_t,
    orientation     orientation_t,
    couleur_cheveux text,
    couleur_yeux    text,
    poids           int check (poids > 0), -- kg
    taille          int check (taille > 0), -- cm
);

drop table if exists cherche cascade;
create table cherche (
    chercheur       text not null references utilisateur(id),
    genre           genre_t,
    orientation     orientation_t,
    couleur_cheveux text,
    couleur_yeux    text,
    poids           int check (poids > 0),
    taille          int check (taille > 0),
    age             int check (age >= 18)
);

drop table if exists avis cascade;
create table avis (
    source      text references utilisateur(id),
    destination text references utilisateur(id),
    type_avis   avis_t not null,
    date_avis   timestamp not null default current_timestamp,
    primary key (source, destination)
);

drop table if exists interet cascade;
create table interet (
    categorie            text,
    sous_categorie       text,
    nom                  text,
    nombre_interesses    int check (nombre_interesses >= 0),
    createur_participant text, -- Peut-être trouver un autre nom ?
    lieu                 text references lieu(id),
    primary key (categorie, nom, createur_participant)
);

drop table if exists centre_interet cascade;
create table centre_interet (
    utilisateur          text references utilisateur(id),
    categorie            text,
    nom                  text,
    createur_participant text,
    rapport              text,
    source               text,
    frequence            interval,
    primary key (utilisateur, categorie, nom, createur_participant, rapport),
    foreign key (categorie, nom, createur_participant) references interet (categorie, nom, createur_participant)
);
