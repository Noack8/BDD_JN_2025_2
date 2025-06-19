WITH 
CasosMorbilidad AS (
    -- Noroeste
    SELECT *
    FROM OPENQUERY(E6_NODO_NORTE, 
	'SELECT 
        MUNICIPIO_RES,
        SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS casos_hipertension,
        SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS casos_obesidad,
        SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS casos_diabetes,
        SUM(CASE WHEN TABAQUISMO = 1 THEN 1 ELSE 0 END) AS casos_tabaquismo
	FROM e6_covid_norte.dbo.datoscovid
    WHERE CLASIFICACION_FINAL NOT IN (1,2,3)
    GROUP BY MUNICIPIO_RES')
    UNION ALL
	SELECT *
    FROM OPENQUERY(E6_NODO_OCCIDENTE_Y_OTROS, 
	'SELECT 
        MUNICIPIO_RES,
        SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS casos_hipertension,
        SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS casos_obesidad,
        SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS casos_diabetes,
        SUM(CASE WHEN TABAQUISMO = 1 THEN 1 ELSE 0 END) AS casos_tabaquismo
	FROM e6_covid_occidente_y_otros.dbo.datoscovid
    WHERE CLASIFICACION_FINAL NOT IN (1,2,3)
    GROUP BY MUNICIPIO_RES')
	UNION ALL
	SELECT *
    FROM OPENQUERY(E6_NODO_SUR, 
	'SELECT 
        MUNICIPIO_RES,
        SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS casos_hipertension,
        SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS casos_obesidad,
        SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS casos_diabetes,
        SUM(CASE WHEN TABAQUISMO = 1 THEN 1 ELSE 0 END) AS casos_tabaquismo
	FROM e6_covid_sur.dbo.datoscovid
    WHERE CLASIFICACION_FINAL NOT IN (1,2,3)
    GROUP BY MUNICIPIO_RES')
	UNION ALL
	SELECT *
    FROM OPENQUERY(E6_NODO_ORIENTE, 
	'SELECT
		CAST(MUNICIPIO_RES as CHAR(3)),
        casos_hipertension,
        casos_obesidad,
        casos_diabetes,
        casos_tabaquismo
	FROM OPENQUERY( MYSQL_8,
	''SELECT
        MUNICIPIO_RES,
        SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS casos_hipertension,
        SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS casos_obesidad,
        SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS casos_diabetes,
        SUM(CASE WHEN TABAQUISMO = 1 THEN 1 ELSE 0 END) AS casos_tabaquismo
	FROM e6_covid_oriente.datoscovid
    WHERE CLASIFICACION_FINAL NOT IN (1,2,3)
    GROUP BY MUNICIPIO_RES'')')
)
SELECT MUNICIPIO_RES
FROM CasosMorbilidad
GROUP BY MUNICIPIO_RES
HAVING SUM(casos_hipertension) > 0 
  AND SUM(casos_obesidad) > 0 
  AND SUM(casos_diabetes) > 0 
  AND SUM(casos_tabaquismo) > 0;