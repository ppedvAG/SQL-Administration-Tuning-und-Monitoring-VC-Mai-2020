--Physikalisches Partitionieren

--Selbe Idee wie partitionierte Sicht, aber ohne weitere Tabellen


--Wie part Sicht nur unter der Haube.. Tabelle bliebt .. keine Sicht!

--IDEE.. Funktion identifiziert den Bereich, in dem ein DS physikalisch liegen muss
--das Part-Schema gibt den exakten Ort des Berecihs an (Dateigruppe)


--fZahl(117) 2

-----------------100-----------------200---------------
--      1                   2              3


create partition function fzahl(int) -- -2,1 Mrd -- 2,1
as
RANGE LEFT FOR VALUES (100,200)


select $partition.fzahl(117) --> 2


--DGruppen: bis100, bis200, rest, bis5000

USE [master]
GO
ALTER DATABASE [TuningDB] ADD FILEGROUP [bis100]
GO
ALTER DATABASE [TuningDB] ADD FILE ( NAME = N'bis100daten', FILENAME = N'C:\_SQLDBS\bis100daten.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [bis100]
GO
ALTER DATABASE [TuningDB] ADD FILEGROUP [bis200]
GO
ALTER DATABASE [TuningDB] ADD FILE ( NAME = N'bis200daten', FILENAME = N'C:\_SQLDBS\bis200daten.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [bis200]
GO
ALTER DATABASE [TuningDB] ADD FILEGROUP [bis5000]
GO
ALTER DATABASE [TuningDB] ADD FILE ( NAME = N'bis5000', FILENAME = N'C:\_SQLDBS\bis5000.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [bis5000]
GO
ALTER DATABASE [TuningDB] ADD FILEGROUP [rest]
GO
ALTER DATABASE [TuningDB] ADD FILE ( NAME = N'restdaten', FILENAME = N'C:\_SQLDBS\restdaten.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [rest]
GO




--Scheme

create partition scheme schZahl 
as
partition fzahl to (bis100, bis200, rest)
--                     1      2       3

--Tabelle lieg auf Scheme...
create table ptab (id int identity, Nummer int, spx char(4100)) on schZahl(nummer)


declare @i as int = 1

while @i < =20000
	begin
		insert into ptab values (@i, 'XY')
		set @i+=1
	end

--statt 40 Sekunden nun sichtbar schneller

--besser?: --> set stat... Plan
set statistics io, time on

select * from ptab where nummer = 115

select * from ptab where id = 100


--- Häufig Abfragen auf Bereich 201 und 5000


-----100-----------200-------------5000--------------------------------
--1           2                3                     4



--Tabelle, F(), scheme
--neue Grenze


-- Tabelle muss nie geändert werden
--F() --> 4 --- Scheme --DGR

--zuerst scheme

alter partition scheme schZahl next used bis5000


select $partition.fzahl(nummer), min(nummer), max(nummer), count(*)
from ptab
group by $partition.fzahl(nummer)


------100---200-------5000----------------

alter partition function fZahl() split range(5000)




/****** Object:  PartitionFunction [fzahl]    Script Date: 07.05.2020 15:33:30 ******/
CREATE PARTITION FUNCTION [fzahl](int) AS RANGE LEFT FOR VALUES (100, 200, 5000)
GO


/****** Object:  PartitionScheme [schZahl]    Script Date: 07.05.2020 15:33:56 ******/
CREATE PARTITION SCHEME [schZahl] AS PARTITION [fzahl] TO ([bis100], [bis200], [bis5000], [rest])
GO




--Grenze 100 entfernen

--Tabelle, f() , scheme

--Tabelle ? ..nie!!
--f()

alter partition function fzahl() merge range (100)


--Wann mach ich das.. bei Tabellen, die sehr groß sind...Millionen

--Archivieren

--Datensätze verschwinden aus patb und sind in Archivtabelle
select * from ptab where id = 10

create table archiv (id int not null, nummer int, spx char(4100)) on REST

alter table ptab switch partition 3 to archiv

select * from archiv --15000

select * from ptab --5000

--100MB /sek 
--10000000000 MB--> Archiv .. dann wäre die Dauer: 0ms

--es werden keine DS verschoben, sondern part 3 wurd Archiv genannt





--Kunden: AbisM  NbisR  SbisZ
create partition function fzahl(varchar(50)) -- -2,1 Mrd -- 2,1
as
RANGE LEFT FOR VALUES ('N','S')

--Maier ist größer als M
--------------M]-----------------------R--------------

--  2018     2019   
create partition function fzahl(datetime) -- -2,1 Mrd -- 2,1
as
RANGE LEFT FOR VALUES ('31.12.2018 23.59:59:999','')



CREATE PARTITION SCHEME [schZahl] AS PARTITION [fzahl] 
TO ([Primary], [Primary], [Primary], [Primary])
GO


create table ptab2 (id int identity, Nummer int, spx char(4100)) on schZahl(nummer)


declare @i as int = 1

begin tran
while @i < =20000
	begin
		insert into ptab2 values (@i, 'XY')
		set @i+=1
	end
commit


GO --Batch

select * from sys.dm_tra