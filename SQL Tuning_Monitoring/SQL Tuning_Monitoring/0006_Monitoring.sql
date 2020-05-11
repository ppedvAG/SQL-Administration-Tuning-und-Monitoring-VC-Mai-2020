--Tools??
--Windows taskmanager
--DMVs: Live Monitoring, auch historisch (ausser es efolgte Neustart)



--DMVS
select * from sysprocesses

--typische DMVs
-- sys.dm_db_index_...
-- sys.dm_os_Wait_Stats



--Idera, Red Gate


--Aufzeichnung: NT Perfmon (grafisch), Profiler (Statements), XEvents




select * from sys.dm_os_wait_stats


--ABFRAGE--> Ressourcen finden sind die frei --

--0-----------------100ms--------150ms-- jetzt beginnt die Arbeit

-------------------------------> wait_time  (150)

--                     -------> 50ms signal_time

--Wait_time-signal_time = Wartezeit auf Ressource

--Aufzeichnung..

