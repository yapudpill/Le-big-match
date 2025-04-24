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
