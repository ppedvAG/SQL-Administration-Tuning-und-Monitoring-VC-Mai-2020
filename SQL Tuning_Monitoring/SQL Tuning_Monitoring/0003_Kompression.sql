
--Kompression

--t1
--Neustart

--RAM SQL Server: 492--615  (inkl read ahead)--> 160MB in RAM

set statistics io, time on
select * from tuningDB..t1

--Seiten: 20000  CPU:  250 ms    Dauer:  2536 ms

--Neustart: T1 ist komprimiert-- statt 160MB nun 0,6 MB


--RAM SQL Server: bei Start weniger--> eher gleich-- danach kaum mehr.. 0,6 MB
--er liest in den RAM komprimierte Seiten

set statistics io, time on
select * from t1

--Seiten: 32  CPU: eher höher      Dauer: eher gleich

--Client bekommt 160MB

--Kompression eher zu Gunsten anderer: Archivtabellen
--Erwartung an Kompression: 40% bis 60%


--Wieso kann man nicht gleich alle Tabelle sprich die DB komprimieren?


