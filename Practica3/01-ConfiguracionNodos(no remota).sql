-- Este script importa las filas desde un nodo, en caso de tener la base de datos covidHistorico en el mismo nodo se puede quitar el LinkedServer sin problema

-- Configuración E6_NODO_ORIENTE
-- Se debe ejecutar manualmente en MySQL el script para configurar la tabla, posteriormente se puede insertar la información con esta sentencia desde el nodo SQLServer intermedio que tenga configurado el Linked Server

-- E6_NODO_NORTE
CREATE DATABASE e6_covid_norte;
go
USE e6_covid_norte;
go
DROP TABLE IF EXISTS datoscovid;
SELECT * INTO datoscovid FROM OPENQUERY(E6_NODO_ORIGINAL, 'SELECT * FROM covidHistorico.dbo.datoscovid WHERE ENTIDAD_RES IN (''08'',''05'',''10'',''32'',''24'',''25'',''26'',''18'',''02'',''03'')');

-- E6_NODO_OCCIDENTE_Y_OTROS
CREATE DATABASE e6_covid_occidente_y_otros;
go
USE e6_covid_occidente_y_otros;
go
DROP TABLE IF EXISTS datoscovid;
SELECT * INTO datoscovid FROM OPENQUERY(E6_NODO_ORIGINAL, 'SELECT * FROM covidHistorico.dbo.datoscovid WHERE ENTIDAD_RES NOT IN (''07'',''12'',''20'',''27'',''31'',''23'',''04'',''08'',''05'',''10'',''32'',''24'',''25'',''26'',''18'',''02'',''03'',''09'',''13'',''21'',''22'',''15'',''17'',''29'',''30'')');

-- E6_NODO_SUR
CREATE DATABASE e6_covid_sur;
go
USE e6_covid_sur;
go
DROP TABLE IF EXISTS datoscovid;
SELECT * INTO datoscovid FROM OPENQUERY(E6_NODO_ORIGINAL, 'SELECT * FROM covidHistorico.dbo.datoscovid WHERE ENTIDAD_RES IN (''07'',''12'',''20'',''27'',''31'',''23'',''04'');');