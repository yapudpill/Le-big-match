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
    age int
);

\copy tmp_preference from 'data/preference.csv' with (format csv, header true)
insert into preference (chercheur,couleur_cheveux,couleur_yeux,poids,taille,age)
    select chercheur,couleur_cheveux,couleur_yeux,poids,taille,age
    from tmp_preference;

drop table tmp_preference;
