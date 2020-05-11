
--Partitionierte Sicht

create table u2020 (id int identity, jahr int, spx int)
create table u2019 (id int identity, jahr int, spx int)
create table u2018 (id int identity, jahr int, spx int)
create table u2017 (id int identity, jahr int, spx int)


--
--Statt um satz viele kleine Tabellen
---aber mit Hilfe von einer Sicht 'UMSATZ" Objekt generieren
--Das Verhalten der Sicht sollte identisch sein, wie eine große Umsatztabellen
--nur besser ;-)

--partitionierte Sicht (view)

select * from (select * from t1) t

create view vt
as
select * from t1

select * from vt


--UNION ALL--keine Suche nach doppelten Datensätzen
create view Umsatz
as
select * from u2020
UNION ALL
select * from u2019
UNION ALL
select * from u2018
UNION ALL
select * from u2017


--schneller?... Plan.. set stats
select * from umsatz where jahr = 2019

ALTER TABLE dbo.u2019 ADD CONSTRAINT CK_u2019 CHECK (jahr=2019)
ALTER TABLE dbo.u2017 ADD CONSTRAINT CK_u2017 CHECK (jahr=2017)
ALTER TABLE dbo.u2016 ADD CONSTRAINT CK_u2016 CHECK (jahr=2016)
ALTER TABLE dbo.u2020 ADD CONSTRAINT CK_u2020 CHECK (jahr=2020)

--geil!!!

--Kann man auf Sicht INS UP DEL anwenden??


insert into umsatz (id,jahr, spx) values(1,2017,100)

--Eindeutigkeit über alle Tabellen (id + jahr)

--kein Identity..Mist.. macht die Anwendung aber nicht mehr mit


--Wann ist eine part Sich tgut zu gebrauchen...?
--eigtl nur für SELECT brauchbar.. Archivtabllen


--nachteil.... 

--Gibts da nicht da was besseres..??




