-- Consulta ejecutada desde el nodo principal (SQL Server)
SELECT 
    ENTIDAD_RES, 
    SUM(numero_Casos) AS total_casos_recuperados_neumonia
FROM (
    SELECT * 
    FROM OPENQUERY(E6_NODO_NORTE, 
	'SELECT 
        c.ENTIDAD_RES, 
        COUNT(*) AS numero_Casos
	FROM e6_covid_norte.dbo.datoscovid c
    WHERE c.NEUMONIA = 1 
      AND c.CLASIFICACION_FINAL IN (1, 2, 3) -- Casos confirmados
      AND c.FECHA_DEF IS NULL -- Casos recuperados (sin fecha de defunción)
    GROUP BY c.ENTIDAD_RES')
    
	UNION ALL
    
	SELECT * 
    FROM OPENQUERY(E6_NODO_OCCIDENTE_Y_OTROS, 
	'SELECT 
        c.ENTIDAD_RES, 
        COUNT(*) AS numero_Casos
	FROM e6_covid_occidente_y_otros.dbo.datoscovid c
    WHERE c.NEUMONIA = 1 
      AND c.CLASIFICACION_FINAL IN (1, 2, 3) -- Casos confirmados
      AND c.FECHA_DEF IS NULL -- Casos recuperados (sin fecha de defunción)
    GROUP BY c.ENTIDAD_RES')

    UNION ALL
    
	SELECT * 
    FROM OPENQUERY(E6_NODO_SUR, 
	'SELECT 
        c.ENTIDAD_RES, 
        COUNT(*) AS numero_Casos
	FROM e6_covid_sur.dbo.datoscovid c
    WHERE c.NEUMONIA = 1 
      AND c.CLASIFICACION_FINAL IN (1, 2, 3) -- Casos confirmados
      AND c.FECHA_DEF IS NULL -- Casos recuperados (sin fecha de defunción)
    GROUP BY c.ENTIDAD_RES')

    UNION ALL

    SELECT * 
    FROM OPENQUERY(E6_NODO_ORIENTE, 
		'SELECT *
		FROM OPENQUERY(MYSQL_8, 
			''SELECT 
				c.ENTIDAD_RES, 
				COUNT(*) AS numero_Casos
			FROM e6_covid_sur.datoscovid c
			WHERE c.NEUMONIA = 1 
			  AND c.CLASIFICACION_FINAL IN (1, 2, 3) -- Casos confirmados
			  AND c.FECHA_DEF IS NULL -- Casos recuperados (sin fecha de defunción)
			GROUP BY c.ENTIDAD_RES''
		);'
	)
) AS casos_union
GROUP BY ENTIDAD_RES
ORDER BY total_casos_recuperados_neumonia DESC;