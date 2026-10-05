use mydb;

DROP VIEW IF EXISTS oborudovanie_v;
DROP VIEW IF EXISTS brak_v;
DROP VIEW IF EXISTS personal_v;
DROP VIEW IF EXISTS siryo_v;
DROP VIEW IF EXISTS tipKirpicha_v;

create view oborudovanie_v as
select pp.idPartiya, pp.idKirpich, pp.colProducta, ob.naimenovanie as oborudovanie, ob.idCex, iob.timeNachala, iob.timeOkonchaniya from proizvodstvennayaPartiya as pp
join ispolzovanieOborudovaniya as iob on pp.idPartiya = iob.idPartiya
join oborudovanie as ob on iob.idOborudovanie = ob.idOborudovanie order by idPartiya, timeNachala, timeOkonchaniya;

create view brak_v as
select proizvodstvennayaPartiya.idPartiya, kontrolProducta.norma, kontrolProducta.factZnachenie, rezultatProd.rezultatProd, brak.prichinaBraka 
from kontrolProducta 
join proizvodstvennayaPartiya on kontrolProducta.idPartiya = proizvodstvennayaPartiya.idPartiya 
join brak on proizvodstvennayaPartiya.idPartiya = brak.idPartiya
join rezultatProd on kontrolProducta.idRezultatProd = rezultatProd.idRezultatProd where kontrolProducta.idRezultatProd > 1 order by idPartiya, norma;

create view personal_v as
select pp.idPartiya, pp.idKirpich, d.dolzhnost, p.familiya, p.name, p.otchestvo, rp.timeNachala, rp.timeOkonchaniya from proizvodstvennayaPartiya as pp
join rabotaPersonala as rp on pp.idPartiya = rp.idPartiya
join personal as p on rp.idPersonal = p.idPersonal
join dolzhnost as d on p.idDolzhnost = d.idDolzhnost order by timeNachala, timeOkonchaniya, familiya, name;

create view siryo_v as
select tk.*, r.nazvanieRecepta, vs.vidSiryo, cm.colmateriala, cm.edIzmereniya from tipkirpicha as tk
join recept as r on r.idRecept = tk.idRecept
join colmateriala as cm on cm.idRecept = r.idRecept
join vidsiryo as vs on vs.idVidSiryo = cm.idVidSiryo order by idKirpich, vidSiryo;

create view tipKirpicha_v as
select pp.idPartiya, tk.nazvanieKirpicha, tk.markaKirpicha, colProducta from proizvodstvennayaPartiya as pp
join tipKirpicha as tk on pp.idKirpich = tk.idKirpich order by idPartiya;