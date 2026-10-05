use mydb;

-- SELECT → FROM → JOIN → ON → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT

-- оператор select
select idPartiya, colProducta as количество_кирпича from proizvodstvennayapartiya;
select distinct(idVidSiryo) from vidSiryo limit 4;  -- только уникальные значения

-- фильтры
select * from proizvodstvennayapartiya where colProducta between 2000 and 4000;
select * from tipKirpicha where markaKirpicha in ('М150', 'М100');
select * from tipKirpicha where nazvanieKirpicha like '%полуторный%';
select * from personal where name like '%Мар%' or idDolzhnost = 2;

-- сортировка
select * from tipKirpicha order by markaKirpicha desc;
select * from tipKirpicha where idRecept > 2 order by markaKirpicha desc limit 3;

-- изменение таблиц
describe tipKirpicha;
alter table vidSiryo add column testColumn bool;
alter table vidSiryo rename column testColumn to Test;
alter table vidSiryo drop column Test;

-- вставка и изменение данных
-- insert into personal (idDolzhnost, familiya, name, otchestvo) values (6, 'Голиков', 'Сан', 'Саныч');
-- select * from personal where idDolzhnost = 6;
-- update personal set familiya = 'Медведев', name = 'Михал', otchestvo = 'Михалыч' where idPersonal = 3;
-- delete from personal where idPersonal = 14 or idPersonal = 15;
-- select * from personal where idDolzhnost = 6 or FIOpersonal = 'Медведев Михал Михалыч';

-- группировка данных
select idRezultatProd, count(*) from kontrolProducta group by idRezultatProd;
select idPartiya, idRezultatProd, count(*) from kontrolProducta where idPartiya <= 5 group by idPartiya, idRezultatProd order by count(*) asc;
SELECT idVidBraka, COUNT(*) AS sluchaev, SUM(colBraka) AS summa FROM brak GROUP BY idVidBraka ORDER BY summa DESC;

-- агрегатные функции
select idVidBraka, count(*), sum(colBraka) from brak group by idVidBraka order by sum(colBraka) desc;
select idKirpich, avg(colProducta), sum(colProducta) from proizvodstvennayaPartiya group by idKirpich order by sum(colProducta) desc;
select idKirpich, min(colProducta) as MINIMUM, max(colProducta) as MAXIMUM from proizvodstvennayaPartiya group by idKirpich limit 5;
select count(*), sum(colProducta) from proizvodstvennayaPartiya;

-- группировка и фильрация
select idKirpich, count(*) from proizvodstvennayaPartiya where idPlan <= 3 group by idKirpich having count(*) > 1;

-- JOIN
select proizvodstvennayaPartiya.*, tipKirpicha.nazvanieKirpicha from proizvodstvennayaPartiya 
join tipKirpicha on proizvodstvennayaPartiya.idKirpich = tipKirpicha.idKirpich order by idPartiya;

select pp.*, tk.nazvanieKirpicha as 'Название кирпича' from proizvodstvennayaPartiya as pp join tipKirpicha as tk on pp.idKirpich = tk.idKirpich;
select pp.idPartiya, tk.nazvanieKirpicha as 'Название кирпича' from proizvodstvennayaPartiya as pp 
join tipKirpicha as tk on pp.idKirpich = tk.idKirpich where idPlan <=3 and markaKirpicha in ('М100', 'М150') order by idPartiya;

select personal.*, idPartiya from personal left outer join rabotaPersonala on personal.idPersonal = rabotaPersonala.idPersonal;
select personal.*, idPartiya from personal right outer join rabotaPersonala on personal.idPersonal = rabotaPersonala.idPersonal;
-- select personal.*, rabotaPersonala.idPartiya from personal full outer join rabotaPersonala on personal.idPersonal = rabotaPersonala.idPersonal;
select personal.*, idPartiya from personal cross join rabotaPersonala;

select pp.idPartiya, pp.dataProizvodstva, pp.colProducta, iob.timeNachala, iob.timeOkonchaniya, o.naimenovanie from proizvodstvennayaPartiya as pp 
join ispolzovanieOborudovaniya as iob on pp.idPartiya = iob.idPartiya
join oborudovanie as o on o.idOborudovanie = iob.idOborudovanie where o.idCex in (1, 2) and dataProizvodstva between '2026-09-01' and '2026-09-07';

select proizvodstvennayaPartiya.idPartiya, kontrolProducta.norma, kontrolProducta.factZnachenie, kontrolProducta.idRezultatProd, brak.prichinaBraka from kontrolProducta 
join proizvodstvennayaPartiya on kontrolProducta.idPartiya = proizvodstvennayaPartiya.idPartiya 
join brak on proizvodstvennayaPartiya.idPartiya = brak.idPartiya where idRezultatProd > 1;

-- подзапросы
select * from proizvodstvennayaPartiya where colProducta = (select max(colProducta) from proizvodstvennayaPartiya);

select * from oborudovanie where idOborudovanie not in (select idOborudovanie from ispolzovanieOborudovaniya); -- оборудование которое не используется