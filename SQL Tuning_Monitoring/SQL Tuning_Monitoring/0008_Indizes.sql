--Indizes

--Daten produzieren
select * into ku from kundeumsatz

--so oft wiederholen bis 551000 ca eingefügt wuden.. ergibt 1,1 Mio Datensätze
insert into ku
select * from ku

--QueryStore aktiviert


/*

Clustered IX x
NON Clustered IX x
--------------------
eindeutiger IX x
zusammengesetzter IX x max 16 Spalten.. max 900byte
IX mit eingschlossenen Spalten ..ca 1000 Spalten
gefilterten IX ....X
ind Sicht ---Sieht cool aus, aber !!
part. IX ..wie gefilterte
abdeckender IX .. der ideale IX
realer hypth IX.. kommt von einem Tool IX --- _dta_
---------------------
Columnstore IX ... grenzgenial











N CL = Kopie (nicht aller ) Daten .. ca 1000 mal Tabellen


CL IX = Tabelle in physikal. sortierter Form .. nur 1 mal pro Tab

---------------------------------
Wann ist welcher gut geeignet?
---------------------------------

CL IX ist gut bei Bereichsabfragen : where mit > < like between

NCL IX, dann gut wenn rel wenig rauskommt: Tipping
--oft 1 % der Tabelle

Oberste prio: Welche Spalte bekommt den CL IX!???

PK wird immer per default als CL IX eindeutig verwendet

Wie kann man den PK von gr IX auf N GR ändern?
In Entwurfansicht IX von Clustered Ja auf Nein setzten


*/


select * into ku2 from ku


alter table ku2 add id int identity


--Welche Spalte soll CL IX haben?

--CL IX auf Orderdate

--SCAN a bis z
--Seek herauspicken
set statistics io, time on

select id from ku2 where id = 100
--60926-- 300ms/50ms

--besser mit: NIX_ID

select id from ku2 where id = 100
--3  0ms

--Seek mit Lookup..teuer.. wollen wir nicht haben
select id, city from ku2 where id = 100

--mit NIX_ID_CITY ..kein Lookup mehr

select id, city, country from ku2 where id = 100

--NIX_ID_iCICY
select id, city from ku2 where id = 100


--zusammengestzte IX kann nicht meh als 16 Spalten enthalten
--IX mit include Columns kann ca 1000 Spalten enthalten

--beste X
select shipcountry, shipcity, sum(unitprice*quantity)
from ku2
where freight < 0.2
group by shipcountry, shipcity

--das müssen 2 IX werden.. und SQL ist draussen was automatische IX Vorschäge betrifft
select shipcountry, shipcity, sum(unitprice*quantity)
from ku2
where freight < 0.2 and employeeid = 2
group by shipcountry, shipcity



--gefilterter IX--wenn es weniger Ebenen am Ende gibt

select * from ku2 where freight < 0.2 and country = 'Austria'




select country, count(*) from ku2
group by country

create view vInd
as
select country, count(*) AS Anz from ku2
group by country


select * from vind


alter view vInd with schemabinding
as
select country, count_big(*) AS Anz from dbo.ku2
group by country



--was wäre wenn, 20000000 Mrd DS liefern in alle Länder
--Wieviele Seiten würde wir per ind Sicht benötigen

--200 Länder ? 200 Zeilen--> 2 Seiten

--where wenn INS UP DEL

--extrem viele bedingungen




*/


select * into ku3 from ku2
select * into ku4 from ku2


select top 3 * from ku3

--Abfrage
--where , Berechnung


--durchschn Bestellmenge pro Kunde, die wo aus Frankreich sind

set statistics io, time on
select companyname,avg(quantity) from ku3 where country='france' group by companyname

--idealer IX:  NIX_country_incl_Cname_qu
USE [Northwind]
GO
CREATE NONCLUSTERED INDEX NIX_country_incl_Cname_qu
ON [dbo].[ku3] ([Country])
INCLUDE ([CompanyName],[Quantity])
GO


--Auf tab ku4.. ColumnStore IX
--will nix wissen
--Generalindex?


select companyname,avg(quantity) from ku4 where country='france' group by companyname

--CPU:0   Dauer:2.. deutlich besser als der ideale IX
--versteh ich nicht

--KU3 = 430MB groß
--KU4 = 4,3MB groß , wenn das stimmt, dann muss ku4 komprimiert sein
--aber die normaler Kompression mit Seiten oder Zeilen  40% bis 60%
--Archivierungskompression: 4,2 --> 3,2..  1,2MB--> 0,2--> 200kb

--200kb in RAM!!!!! statt 360 plus IX

select companyname,avg(quantity) from ku4 where city='paris' group by companyname


select companyname,avg(unitsinstock) from ku4 where city='paris' group by companyname

--schneidet fast immer besser ab.. wieso!!



--Pflege der Indizes: 
-- TAB X mit 3 Spalten  A B C

--max. Anzahl der Indizes: 
--A B C BA BC AB AC CA CB ABC ACB BCA BAC CAB CBA
--ca 1000 Indizes sind 1000 Inserts
-- NIX1 AB NIX 2 AB

--nur die absolut notwendigen IX reintun
--fehlende rein überflüsssige raus

--Überflüssige: SEEK ist gut.. SCAN ist schlecht

--IX Seek   IX SCAN
--CL IX SCAN  CL IX SEEK
--Table SCAN


--Phänomen


select * into ku5 from ku

alter table ku5 add id int identity


--Wieiviel hat die Tabelle un dwie ausgelsatet sind die Seiten
dbcc showcontig('ku5') --46330

set statistics io, time on
select * from ku5 where id = 10 --Seiten: Table Scan: aber 60000 statt 46330


select 60955-46330 -- 14625 nur IDs??? krank!!!!

--messen
--besser als der dbcc showcontig
select * from sys.dm_db_index_physical_stats(db_id(), object_id('ku5'), NULL, NULL, 'detailed')





create proc gpdemo @id int
as
select * from ku3 where id < @id


--Problem der Prozedur

--gelten als schnell
--weil der Plan nur reinmal gemacht werden muss, beim ersten Aufruf


exec gpdemo 2 --IX Seek

--optimal mit : 
select * from ku3 where id < 2  --IX Seek

select * from ku3 where freight = 1 --Scan 46290


select * from ku3 where id < 1000000 -- Nicht gr IX nicht´mehr günstig wg Lookup.. Tipping
--Seiten: 46290--, CPU-Zeit = 3546 ms, verstrichene Zeit = 22397 ms.


exec gpdemo 1000000 --1002240 Seiten !!!!!!!!!!!!!.. immer Seek

dbcc freeproccache --leert komplette Prozeduren Cache

exec gpdemo 1000000 --46290 --, CPU-Zeit = 3562 ms, verstrichene Zeit = 21890 ms.

exec gpdemo 2 --46290!...


select * into ku6 from ku4


select * from ku6 where freight=0.02

select * from ku6 where country = 'UK'

--wann soll/werden stat aktualisiert?
--20%+500 I , UP, DEL
--ähh.. Tipping Point 1%..viel zu spät..
--am besten jeden tag 

--Wartung-- IX (Rebuild/Reorg/Stat akt)


--bis 10% nix
--> 10% Reorg
--> 30% Rebuild

--SQL 2014 ---sehr besch**** Wartungplan




--DMVs


select * from sys.dm_os_wait_stats

--misst seit dem Neustart kummulierend

--alle 10min.. Intervallweise wegschreiben inkl Zeit

--




--Was soll man dann mit Proz tun?
--Code with recompile, dann ist aber der Vorteil der Proc weg..
--nicht benutzerfreundlich

exec gpKundensuche 'ALFKI' -- 1Treffer
exec gpKundensuche 'A' -- alle mit A beginnend 10 Treffer
exec gpKundensuche  -- alle!

--Code
---IF -%  --> exec GPSuchealle (SCAN)
--ELSE exec gpKundensuchewenige Üaer (SEEK)














--nach CL IX nur noch 46330 plus 1600 Seiten für IDs--> 48004
--bei CL IX kann kein forward record cohnt auftauchen
--eigtl sollte jede Tabelle einen CL IX haben






















select * from sys.dm_db_index_usage_stats










