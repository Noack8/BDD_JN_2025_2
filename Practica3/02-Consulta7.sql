-- Consulta ejecutada desde el nodo principal (SQL Server)
WITH CasosPorMes AS (
	SELECT *
	FROM OPENQUERY(E6_NODO_NORTE, 
	'SELECT 
		c.ENTIDAD_RES,
		YEAR(c.fecha_ingreso) AS anio,
		MONTH(c.fecha_ingreso) AS mes,
		COUNT(*) AS total_casos
	FROM e6_covid_norte.dbo.datoscovid c
	WHERE c.CLASIFICACION_FINAL IN (1, 2, 3, 6) -- Confirmados y sospechosos
	  AND YEAR(c.fecha_ingreso) IN (2020, 2021)
	GROUP BY c.ENTIDAD_RES, YEAR(c.fecha_ingreso), MONTH(c.fecha_ingreso)')
 
	UNION ALL
 
	SELECT *
	FROM OPENQUERY(E6_NODO_OCCIDENTE_Y_OTROS, 
	'SELECT 
		c.ENTIDAD_RES,
		YEAR(c.fecha_ingreso) AS anio,
		MONTH(c.fecha_ingreso) AS mes,
		COUNT(*) AS total_casos
	FROM e6_covid_occidente_y_otros.dbo.datoscovid c
	WHERE c.CLASIFICACION_FINAL IN (1, 2, 3, 6) -- Confirmados y sospechosos
	  AND YEAR(c.fecha_ingreso) IN (2020, 2021)
	GROUP BY c.ENTIDAD_RES, YEAR(c.fecha_ingreso), MONTH(c.fecha_ingreso)')

	UNION ALL
	
	SELECT *
	FROM OPENQUERY(E6_NODO_SUR, 
	'SELECT 
		c.ENTIDAD_RES,
		YEAR(c.fecha_ingreso) AS anio,
		MONTH(c.fecha_ingreso) AS mes,
		COUNT(*) AS total_casos
	FROM e6_covid_sur.dbo.datoscovid c
	WHERE c.CLASIFICACION_FINAL IN (1, 2, 3, 6) -- Confirmados y sospechosos
	  AND YEAR(c.fecha_ingreso) IN (2020, 2021)
	GROUP BY c.ENTIDAD_RES, YEAR(c.fecha_ingreso), MONTH(c.fecha_ingreso)')
	
	UNION ALL
	
	SELECT *
	FROM OPENQUERY(E6_NODO_ORIENTE, 
		'SELECT *
		FROM OPENQUERY(MYSQL_8,
			''SELECT
				CAST(c.ENTIDAD_RES as CHAR(2)),
				CAST(YEAR(c.fecha_ingreso) as decimal(4,0)) AS anio,
				CAST(MONTH(c.fecha_ingreso) as decimal(4,0)) AS mes,
				COUNT(*) AS total_casos
			FROM e6_covid_oriente.datoscovid c
			WHERE c.CLASIFICACION_FINAL IN (1, 2, 3, 6) -- Confirmados y sospechosos
			  AND YEAR(c.fecha_ingreso) IN (2020, 2021)
			GROUP BY CAST(c.ENTIDAD_RES as CHAR(2)), YEAR(c.fecha_ingreso), MONTH(c.fecha_ingreso)''
		);'
	)
),

RankingMeses AS (
	SELECT 
		ENTIDAD_RES,
		anio,
		mes,
		total_casos,
		ROW_NUMBER() OVER (PARTITION BY ENTIDAD_RES, anio ORDER BY total_casos DESC) AS ranking
	FROM CasosPorMes
)

SELECT 
	ENTIDAD_RES AS clave_entidad,
	anio,
	mes,
	total_casos
FROM RankingMeses 
WHERE ranking = 1
ORDER BY anio;
