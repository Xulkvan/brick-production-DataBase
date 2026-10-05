use mydb;

-- EXISTS
SELECT p.idPartiya FROM proizvodstvennayaPartiya p
WHERE EXISTS (SELECT 1 FROM brak b WHERE b.idPartiya = p.idPartiya);

SELECT * FROM proizvodstvennayaPartiya
WHERE idPartiya NOT IN (SELECT idPartiya FROM brak);

SELECT o.idOborudovanie, o.naimenovanie
FROM oborudovanie o
WHERE NOT EXISTS (
    SELECT 1 FROM ispolzovanieOborudovaniya i
    WHERE i.idOborudovanie = o.idOborudovanie
);

SELECT DISTINCT p.idPersonal, p.familiya
FROM personal p
WHERE EXISTS (SELECT 1 FROM rabotaPersonala rp 
              WHERE rp.idPersonal = p.idPersonal AND rp.idPartiya = 1)
  AND EXISTS (SELECT 1 FROM rabotaPersonala rp 
              WHERE rp.idPersonal = p.idPersonal AND rp.idPartiya = 6);
              
              
-- Группировка
SELECT idPartiya, idVidBraka, SUM(colBraka)
FROM brak
GROUP BY idPartiya, idVidBraka;