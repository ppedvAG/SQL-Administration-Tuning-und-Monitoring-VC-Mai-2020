/*
DBDesign richtet sich normalerweise an Regeln der Normalisierung, Redundanz oder Generalisierung

--Datwarehouse bevorzugt Redundanz da schnell
--OLTPSystem dagegen Normalisierung (Shop zb)


Allerdigs wird nicht beachtet, was unter der Haube passiert. Dies ist bei jeden Server etwas anders.
Dennoch ist es für jedes! System wichtig!

--Was ist schneller?
TAB A 1000
TAB B 100000


Abfrage Result: 10 Zeilen

---kleine Dinge sind schneller



Advanced DB Design


*/
--DB Design: Normalisierung vs Redundanz
--> Redundanz ist schnell
--> Normalisierung verursacht mehr JOINs, langsam, aber dafür geringeres Sperrniveau

--> #tabellen


--unter der haube allerdings : Seiten und Blöcke.... wichtig !






use tuningDB
GO


create table t1 (id int identity, spx char(4100))
GO

insert into t1 
select 'XX'
GO 20000


--19 Sekunden...40Sek

insert into t1 
select 'XX'
GO 20000


--Char(4100): 4100byte
--Seite hat max 8060 bytes Platz
--fixe Längen müssen reinpassen
--nicht mehr als 700 Datensätze in einer Seiten
--8 Seiten am Stück  = Block

create table t2 (id int, spx char(4100))

dbcc showcontig('t1')
-- Gescannte Seiten.............................: 20000
--- Mittlere Seitendichte (voll).....................: 50.79%

--das muss besser:

--160MB auf HDD auch in RAM!!


--Idee

/*
anderer Datentyp: varchar(4100) 'XX'  nun nur noch 2 Zeichen statt 4100 , aber APP geht nimmer
evtl tabelle umstruktieren


Ziel: es soll kleiner werden ohne DBDesign-Änderung


----------------
Komprimieren!!
----------------
*/

--Testlauf:--------------------

--Neustart
--Angabe von Werten vor Test
--RAM des SQL Server: 492   nach test: 615  (inkl read ahead)--> 160MB in RAM

set statistics io, time on
select * from tuningDB..t1

--Seiten: 20000  CPU:  250 ms    Dauer:  2536 ms

--Neustart: T1 ist komprimiert-- statt 160MB nun 0,6 MB



--RAM SQL Server: bei Start weniger--> eher gleich-- danach kaum mehr.. 0,6 MB
--er liest in den RAM komprimierte Seiten

--RAM des SQL Server: 492   nach test: 615  (inkl read ahead)--> 160MB in RAM



set statistics io, time on
select * from t1

--Seiten: 32  CPU: eher höher      Dauer: eher gleich

--Client bekommt 160MB

--Kompression eher zu Gunsten anderer: Archivtabellen
--Erwartung an Kompression: 40% bis 60%


--Wieso kann man nicht gleich alle Tabelle sprich die DB komprimieren?
--Extreme CPU Last . Letztendlicht nicht klakulierbar bzw nützlich, da einige Tabellen 
--keine nennenswerte KOmpression erreichen, aber dennoch mehr CPU erfordern

----------------------------------------
---PARTITIONIERUNG----------------------
----------------------------------------


--Tabellen auf mehr HDD verteilen

create table tx (id int) on 'c:\ajdjdjajdajdjald.ndf' --ach tkeinen Spass

create table tx (id int) on HOT --> Dateigruppe (im Prinzip die Angabe der .ndf Datei)

--wie kann man eine best Tabelle auf andere Dgr legen?



-----Salamitaktik
--sehr große Tabelle wird immer größer
--einfach kleiner machen












































