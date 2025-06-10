-- SCRIPT PARA CONFIGURAR LINKED SERVERS EN LAB
go
EXEC sp_droplinkedsrvlogin 'E6_NODO_ORIGINAL', NULL;
EXEC sp_droplinkedsrvlogin 'E6_NODO_NORTE', NULL;
EXEC sp_droplinkedsrvlogin 'E6_NODO_OCCIDENTE_Y_OTROS', NULL;
EXEC sp_droplinkedsrvlogin 'E6_NODO_ORIENTE', NULL;
EXEC sp_droplinkedsrvlogin 'E6_NODO_SUR', NULL;
go

EXEC sp_dropserver 'E6_NODO_ORIGINAL';
EXEC sp_dropserver 'E6_NODO_NORTE';
EXEC sp_dropserver 'E6_NODO_OCCIDENTE_Y_OTROS';
EXEC sp_dropserver 'E6_NODO_ORIENTE';
EXEC sp_dropserver 'E6_NODO_SUR';
go

-- 1. Enlazar al nodo 
EXEC sp_addlinkedserver 
    @server = 'E6_NODO_ORIGINAL', -- Este nodo es opcional, unicamente sirve para la configuración inicial en caso de no tener la BD covidHistorico en todos los nodos
    @srvproduct = '',
    @provider = 'SQLNCLI',
    @datasrc = '192.168.229.3';

-- NODOS REALES
EXEC sp_addlinkedserver 
    @server = 'E6_NODO_NORTE',
    @srvproduct = '',
    @provider = 'SQLNCLI',
    @datasrc = '192.168.229.4';
EXEC sp_addlinkedserver 
    @server = 'E6_NODO_OCCIDENTE_Y_OTROS',
    @srvproduct = '',
    @provider = 'SQLNCLI',
    @datasrc = '192.168.229.6';
EXEC sp_addlinkedserver 
    @server = 'E6_NODO_ORIENTE', -- Nodo tunel con la instancia de MySQL, debe tener llos permisos de RPC
    @srvproduct = '',
    @provider = 'SQLNCLI',
    @datasrc = '192.168.229.26';
EXEC sp_addlinkedserver 
    @server = 'E6_NODO_SUR',
    @srvproduct = '',
    @provider = 'SQLNCLI',
    @datasrc = '192.168.229.5';

EXEC sp_addlinkedsrvlogin 'E6_NODO_ORIGINAL', 'false', NULL, 'Alumno', 'Estudiante';
EXEC sp_addlinkedsrvlogin 'E6_NODO_NORTE', 'false', NULL, 'Alumno', 'Estudiante';
EXEC sp_addlinkedsrvlogin 'E6_NODO_OCCIDENTE_Y_OTROS', 'false', NULL, 'Alumno', 'Estudiante';
EXEC sp_addlinkedsrvlogin 'E6_NODO_ORIENTE', 'false', NULL, 'Alumno', 'Estudiante';
EXEC sp_addlinkedsrvlogin 'E6_NODO_SUR', 'false', NULL, 'Alumno', 'Estudiante';

-- NODO MySQL (solo necesario configurar en el nodo ORIENTE)
-- Debe estar configurado el Linked Server a MySQL en el nodo SQL Server, para el desarrollo de la práctica se considera el nombre del Linked Server configurado como 'MYSQL_8'

