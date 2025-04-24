-- DROP --
drop table if exists
    region, departement, ville,
    lieu,
    utilisateur, cherche, avis, interet, centre_interet,
    evenement, evenement_futur, evenement_termine, evenement_annule, reponse, presence,
    tag, tag_utilisateur, tag_lieu, tag_evenement;
drop type if exists genre_t, orientation_t, avis_t, reponse_t;

-- TYPES --
create type genre_t as enum ('homme', 'femme', 'autre');
create type orientation_t as enum ('hetero', 'homo', 'bi', 'autre');
create type avis_t as enum ('like', 'nope');
create type reponse_t as enum ('interesse', 'participe', 'pas interesse');

-- GÉOGRAPHIE (données de l'INSEE) --
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
    -- affluence_moyenne quel type ?
);

-- UTILISATEURS --
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
    taille          int check (taille > 0) -- cm
);

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

create table avis (
    source      text references utilisateur(id),
    destination text references utilisateur(id),
    type_avis   avis_t not null,
    date_avis   timestamp not null default current_timestamp,
    primary key (source, destination)
);

create table interet (
    categorie            text,
    sous_categorie       text,
    nom                  text,
    nombre_interesses    int check (nombre_interesses >= 0),
    createur_participant text, -- Peut-être trouver un autre nom ?
    lieu                 text references lieu(id),
    primary key (categorie, nom, createur_participant)
);

create table centre_interet (
    utilisateur          text references utilisateur(id),
    categorie            text,
    nom                  text,
    createur_participant text,
    rapport              text,
    frequence            interval,
    source               text,
    primary key (utilisateur, categorie, nom, createur_participant, rapport),
    foreign key (categorie, nom, createur_participant) references interet
);

-- ÉVÈNEMENTS --
create table evenement (
    -- Interne appli
    id               serial primary key,
    date_publication timestamp not null default current_timestamp,

    -- Infos évènement
    organisateur text not null references utilisateur(id),
    date_rdv     timestamp not null,
    lieu_rdv     text references lieu(id),
    description  text,
    prix         int check (prix >= 0), -- centimes
    nb_places    int check (nb_places > 0),

    -- Centre d'intérêt lié
    categorie            text,
    nom                  text,
    createur_participant text,
    foreign key (categorie, nom, createur_participant) references interet
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

-- TAGS --
create table tag (
    id          serial primary key,
    mot         text unique,
    utilisateur text unique references utilisateur(id),
    lieu        text unique references lieu(id),
    -- On aimerai spécifier `nulls not distinct` après chaque `unique` mais
    -- c'est disponible qu'à partir de postgres 15 et nivose utilise postgres 13

    -- Exactement 2 des 3 champs sont null
    check ((mot is null)::int + (utilisateur is null)::int + (lieu is null)::int = 2)
);

/* Pour les version de postgresql >= 15, replacer la définition du dessus par :
create table tag (
    id          serial primary key,
    mot         text,
    utilisateur text references utilisateur(id),
    lieu        text references lieu(id),
    check ((mot is null)::int + (utilisateur is null)::int + (lieu is null)::int = 2),
    unique nulls not distinct (mot, utilisateur, lieu)
);
*/

create table tag_utilisateur (
    utilisateur text references utilisateur(id),
    tag         int references tag(id),
    primary key (utilisateur, tag)
);

create table tag_lieu (
    lieu text references lieu(id),
    tag  int references tag(id),
    primary key (lieu, tag)
);

create table tag_evenement (
    evenement int references evenement(id),
    tag       int references tag(id),
    primary key (evenement, tag)
);
