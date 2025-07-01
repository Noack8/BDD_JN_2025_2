CREATE PROCEDURE consultaDinamica
(
    @ListaClasificacionFinal NVARCHAR(500)
)
AS
BEGIN
    Declare @SQLString NVARCHAR (5000)

SET @SQLString = N'SELECT 
    CAST(SUM(CASOS_DIABETES)*100.0/NULLIF(SUM(CASOS_TOTALES), 0) AS DECIMAL(4,2)) AS Porcentaje_Diabetes,
    CAST(SUM(CASOS_HIPERTENSION)*100.0/NULLIF(SUM(CASOS_TOTALES), 0) AS DECIMAL(4,2)) AS Porcentaje_Hipertension,
    CAST(SUM(CASOS_OBESIDAD)*100.0/NULLIF(SUM(CASOS_TOTALES), 0) AS DECIMAL(4,2)) AS Porcentaje_Obesidad
FROM
(SELECT *  
FROM 
    OPENQUERY(E6_NODO_ORIENTE, 
    ''SELECT * 
     FROM OPENQUERY(MYSQL_8, 
     ''''
     SELECT 
         SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS CASOS_DIABETES, 
         SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS CASOS_HIPERTENSION, 
         SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS CASOS_OBESIDAD, 
         COUNT(*) AS CASOS_TOTALES, 
         ''''''''ORIENTE'''''''' AS REGION 
     FROM e6_covid_oriente.datoscovid 
     WHERE CLASIFICACION_FINAL IN (
        SELECT val FROM JSON_TABLE(CONCAT(''''''''["'''''''', REPLACE(''''''''@ListaClasificacionFinal'''''''', '''''''','''''''', ''''''''","''''''''), ''''''''"]''''''''), ''''''''$[*]'''''''' COLUMNS(val INT PATH ''''''''$''''''''))
     '''')
    '') 
UNION
SELECT *
FROM OPENQUERY(E6_NODO_NORTE, 
	''
	SELECT 
         SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS CASOS_DIABETES, 
         SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS CASOS_HIPERTENSION, 
         SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS CASOS_OBESIDAD, 
         COUNT(*) AS CASOS_TOTALES, 
         ''''NORTE'''' AS REGION 
     FROM e6_covid_norte.dbo.datoscovid 
     WHERE CLASIFICACION_FINAL IN (
        SELECT value FROM STRING_SPLIT(@ListaClasificacionFinal, '''','''')
    )
	'')
UNION
SELECT *
FROM OPENQUERY(E6_NODO_OCCIDENTE_Y_OTROS, 
	''
	SELECT 
         SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS CASOS_DIABETES, 
         SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS CASOS_HIPERTENSION, 
         SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS CASOS_OBESIDAD, 
         COUNT(*) AS CASOS_TOTALES, 
         ''''OCCIDENTE Y OTROS'''' AS REGION 
     FROM e6_covid_occidente_y_otros.dbo.datoscovid 
     WHERE CLASIFICACION_FINAL IN (
        SELECT value FROM STRING_SPLIT(@ListaClasificacionFinal, '''','''')
    )
	'')
UNION
SELECT *
FROM OPENQUERY(E6_NODO_SUR, 
	''
	SELECT 
         SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS CASOS_DIABETES, 
         SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS CASOS_HIPERTENSION, 
         SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS CASOS_OBESIDAD, 
         COUNT(*) AS CASOS_TOTALES, 
         ''''SUR'''' AS REGION 
     FROM e6_covid_sur.dbo.datoscovid 
     WHERE CLASIFICACION_FINAL IN (
        SELECT value FROM STRING_SPLIT(@ListaClasificacionFinal, '''','''')
    )
	'')
 ) AS d'

    DECLARE @ParmDefinition NVARCHAR (500) = N'@ListaClasificacionFinal NVARCHAR(500)';
    
    EXECUTE sp_executesql
        @SQLString,
        @ParmDefinition,
        @ListaClasificacionFinal ;
END

-- Consulta 3 con consulta dinámica a partir de procedimiento almacenado
EXEC consultaDinamica @ListaClasificacionFinal = '1,2,3'
