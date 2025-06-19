-- Consulta ejecutada desde el nodo principal (SQL Server)
SELECT 
    ENTIDAD_NAC, 
    SUM(numero_Casos) AS total_casos_recuperados_neumonia
FROM (
    SELECT * 
    FROM OPENQUERY(E6_NODO_NORTE, 
	'SELECT 
        c.ENTIDAD_NAC, 
        COUNT(*) AS numero_Casos
	FROM e6_covid_norte.dbo.datoscovid c
    WHERE c.NEUMONIA = 1 
      AND c.CLASIFICACION_FINAL IN (1, 2, 3) -- Casos confirmados
	  AND CAST(left(C.fecha_def ,4) as INT) = 9999
    GROUP BY c.ENTIDAD_NAC')
    
	UNION ALL
    
	SELECT * 
    FROM OPENQUERY(E6_NODO_OCCIDENTE_Y_OTROS, 
	'SELECT 
        c.ENTIDAD_NAC, 
        COUNT(*) AS numero_Casos
	FROM e6_covid_occidente_y_otros.dbo.datoscovid c
    WHERE c.NEUMONIA = 1 
      AND c.CLASIFICACION_FINAL IN (1, 2, 3) -- Casos confirmados
	  AND CAST(left(C.fecha_deF ,4) as INT) = 9999
  -- Casos recuperados (sin fecha de defunción)
    GROUP BY c.ENTIDAD_NAC')

    UNION ALL
    
	SELECT * 
    FROM OPENQUERY(E6_NODO_SUR, 
	'SELECT 
        c.ENTIDAD_NAC, 
        COUNT(*) AS numero_Casos
	FROM e6_covid_sur.dbo.datoscovid c
    WHERE c.NEUMONIA = 1 
      AND c.CLASIFICACION_FINAL IN (1, 2, 3) -- Casos confirmados
    -- Casos recuperados (sin fecha de defunción)
    AND CAST(left(C.fecha_def ,4) as INT) = 9999
    GROUP BY c.ENTIDAD_NAC')

    UNION ALL

    SELECT * 
    FROM OPENQUERY(E6_NODO_ORIENTE, 
		'SELECT *
		FROM OPENQUERY(MYSQL_8, 
			''SELECT 
				CAST(c.ENTIDAD_NAC as CHAR(2)), 
				COUNT(*) AS numero_Casos
			FROM e6_covid_oriente.datoscovid c
			WHERE c.NEUMONIA = 1 
			  AND c.CLASIFICACION_FINAL IN (1, 2, 3) -- Casos confirmados
 -- Casos recuperados (sin fecha de defunción)
 	  AND CAST(left(C.fecha_def,4) as signed) = 9999
			GROUP BY c.ENTIDAD_NAC''
		);'
	)
) AS casos_union
GROUP BY ENTIDAD_NAC
ORDER BY SUM(numero_Casos) DESC;