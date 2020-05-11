/*
Volumenwartungstask
spielt eine Rolle bei Vergrößerungen von Datendateien
Datei wird normalerweise vorher vom System "ausgenullt"--ergo doppelte Menge wid geschrieben

Volumenwartungstask: SQL Dienstkonto bekommt Recht, die Datei selbständig zu vergrößern
und es wird nicht mehr ausgenullt.--> Lokale Sicherheitsrichtlinie


Datenbankeinstellung (HDD)

Pfade
Trenne Daten von Log pro DB


Seit 2019

Frage nach MAXDOP
Wieviele Prozessoren verwendet eine Abfrage
default 1 oder alle
abhängig vom Kostenschwellwert (default 5.. sehr niedrig)
besser: 25 (später feinjustieren) 
Max Grad der Parallelität: default 0 (bzw Anzahl Kerne max 8 seit SQL 2019)
besser: max 8 später feintuning mit 50-25% der Kerne
--> kein Neustart Notwendig, kein Einfluss auf laufende Prozesse


MAX RAM
default: 2,1 PB (habe aber nur 16GB)...95% des RAM.. für das OS bleibt nix..
Gesamter Speicher - OS (10%: 4 GB max -- 2GB max)
seit 2019 wird ein Max vorgeschlagen


RAM
MIN: 0
MAX: 3000  2,1 PB    Gesamt: 6000-2GB--> 4000
					 Gesamt: 4500_->1500--> 3000 


					 TaskManager: akt: 11000 MB   Max: 14000
					 --> keine große Differenz

Min Ram wird erst eingehalten, wenn er erreicht wurde
Idee: Min RAM kann auf Max Arbeitsatz eingestellt werden..(Taskmanager)
					 


erweitert: MAXDOP (grad der Para..)  und Kostenschwellwert


*/

use nwindbig

--Im Plan ist Paralleismus zu sehen.. (Doppelpfeile)

set statistics io, time on--ms für CPU, Dauer
select customerid, sum(freight) from orders group by customerid
option (maxdop 1)

--Ist es effizient alle CPUs zu verwenden....

--TEST:

---MAXDOP: mehr CPUs (8 Kerne)
--CPU-Zeit = 5983 ms, verstrichene Zeit = 13962 ms.

--mit 1 CPU: = 3578 ms.. 2 Sekunden CPU gespart und 7 sind frei.. Dauer 13 Sekunden

--ab wann soll er mehr CPUS einsetzen...? Kosten..SQL Dollar = OPeratorkosten
-- default: 5 SQL Dollar

--bis SQL 2017: default: 5 Kostenschwellwert und 0 bei Anzahl der Prozessoren (alle)
--Regel: nie mehr als 8
--


--CPU-Zeit = 25983 ms, verstrichene Zeit = 13962 ms...lohnt sich mehr CPUs..ja..



