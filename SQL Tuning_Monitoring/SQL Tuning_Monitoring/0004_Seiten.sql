--Idee: 
/*

wie groß ist ein DS ca: 4kb
select 20000*4--> 80MB, aber die t1 ist tats. 160MB groß!!!!

DS kommen in Datendateien (mdf)
Dateien sind in Seiten und Blöcken organisiert
Seite hat immer 8192 bytes, davon sind aber nur 8060bytes Nutzlast


*/

create table t2 (id int identity, sp1 varchar(4100), sp2 char(4100))

--Großes Ziel: Reduzieren der Seiten!!
--Weniger Seiten--> Weniger CPU --> weniger RAM
--Indizes
--Kompression
--Partitionierung


use northwind

--Seite: max 8060 NUtzlast
--geht nicht
create table t1 (id int identity, sp1 char(4100), sp2 char(4100))

--geht... wenn eine DS > 8060 wird..geht trotzdem..???
create table t1 (id int identity, sp1 varchar(4100), sp2 varchar(4100))


 create table t1 (id int identity, sp1 char(4100))

 --1 DS muss in eine Seite passen. I.d.R. zumindest
  --Dauer für 20000 Inserts	: 26 Sekunden

 insert into t1
 select 'XY'
 GO 20000

 select count(*) from t1--20000 --437

 --1 DS hat ca 4100


 --Abfragen messen:
 set statistics io, time on -- Anzahl der Seiten und Dauer in ms; CPU und Gesamtzeit
select * from t1 where Id = 100

--ohne IX lesen wir alle Seiten

--aber letztendlich hättte wir das schneller haben können



   --in unserem Fall ist jede Seite nur zu ca 51% gefüllt
   --8060 davon 4100 mit Daten

   --1MIO ca 4100byte
   --hunderte von Spalten  (bis zu 30000)
   --auch NULL braucht Platz

   --1 MIO DS a 4100 bytes-->  1 MIO Seiten
   --1 MIO Seiten von der HDD --> RAM  --> von dort gelesen
   --1 MIO Seiten im RAM ==> 8 GB HDD und 8 GB RAM 

   --Redesign: 100byte in TabB

   --TAB A   4000byte   TAB B mit 100
   --2 DS /Seite		 8060/100--> 80 DS/Seite
   --500.000            12.500 Seiten
   --4 GB               110MB
   --> 4,1GB HDD und 4,1 GB RAM Verbrauch

   --kann man das messen:

   dbcc showcontig('t1')
   -- Gescannte Seiten.............................: 200000000
   -- Mittlere Seitendichte (voll).....................: 95.79%

   --bessere Messung mit
 select * from sys.dm_db_index_physical_stats(db_id('Datebank'), object_id('Tabelle'), NULL, NULL, 'detailed')
GO

--mehr Infos. DBCC SHOWCONTIG ist depricated


--statt datetime oder nvarchar nur varchar, statt char einen varchar

--Was wenn etwas nicht mehr in die Seite passt?
--varchar(4100)+ varchar(4100)
--oder es kommen SPalten später dazu..

--Seiten: 15.349.848 
-- 82%

--Kein Verlust an Seiten


--2 Experiment

use northwind;

select * into ku1 from vKundenumsatz;
GO

set statistics io , time off

insert into ku1
select * from ku1

--jetzt 1,1 Mio Zeilen


dbcc showcontig('ku1')	   --: 98.13% bei 41632 Seiten


 --auffällig hier: Import der DAten deutlich schneller als vorher!
set statistics io , time on
select * from ku1 where customerid = 'ALFKI'

--ohne IX: alle Seiten.. 41632


alter table ku1 add kuid int identity

dbcc showcontig('ku1')		 --42215 ..98.16%

--wird alles durchsuchen müssen wg fehlenden IX.. 1 DS aber 42215 Seiten
select * from ku1 where kuid = 100
 --hat aber 56663 Seiten ???


---Warum??
--weil wir etwas nicht gesehen haben..
--dbcc showcontig ist depricated

--besser
select * from sys.dm_db_index_physical_Stats
		(db_id(), object_id('ku1'), NULL, NULL, 'detailed')
		--DBID     ObjektID    , IX, PART, detailed

  --forward_record_Count: zusätzliche Seiten mit den KUID Werten
  ----wir würden theoretisch mit deutlich weniger Seiten auskommen


  --Tabelle war ein HEAP: Dreckshaufen

  --kann man sofort ausbügeln: 
  --Clustered IX = Tabelle in physikalisch sortierte Form

  select * from ku1



  create table t2 (id int identity, sp1 varchar(4100), sp2 varchar(4100))


  set statistics io , time on
  insert into t2
  select 'X', 'Y'
  GO 20000

  update t2 set sp1 = replicate('X', 7100)
				, sp2 = replicate('Y', 1100)



select * from sys.dm_db_index_physical_Stats
		(db_id(), object_id('t2'), NULL, NULL, 'detailed')
		--DBID     ObjektID    , IX, PART, detailed

select * from t2 where id = 100

dbcc showcontig('t2')

---Am Ende zählt: warum gibt es Tabellen die ein HEAP sind!!

 --row_overflow Data.. hier kann nicht immer der CL IX Wunder beiwrklen
 --aber forward_record_Counts bekommt man komplett weg


 --Schnelldurchgang IX..
 --Wieso PROC gut oder schlecht
 --Wieso dauert der go 20000 so lange
 --und wie geht das schneller

 --Gute Sicht schlechte Sicht

 --F()
 --Pläne
 --Transactions
 --Locks und BLocks
 --While , IF, CASE UNION, EXCEPT 


















