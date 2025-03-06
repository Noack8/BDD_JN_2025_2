/*****************************************
1. Listar el top 5 de las entidades con más casos 
confirmados por cada uno de los años registrados en la base de datos.
Requisitos:
- Mostrar el nombre de la entidad.
- Mostrar solo los 5 primeros lugares por año.
Significado de los valores de los catálogos:
- CLASIFICACION_FINAL: 1, 2, 3, como nos interesan solo los CASOS CONFIRMADOS,
tomamos las primeras 3 clasificaciones que son de casos confirmados donde la diferencia entre si
era que organismo habia confirmado los casos. 
Responsable: Armando Eduardo Sánchez Herrera 
Comentarios:
- Se utiliza una CTE (Common Table Expression) para calcular el número
de casos confirmados por entidad y año.
	--Una CTE es una consulta temporal que se define dentro de una sentencia SQL 
	y que se puede referenciar dentro de la misma consulta
- Se hace un JOIN con la tabla de catálogo de entidades para obtener el nombre de la entidad.
- Se utiliza ROW_NUMBER() que es una función de ventana en SQL que asigna 
un número único a cada fila dentro de una partición de un conjunto de resultados. 
En este caso se uso para asignar un ranking a cada entidad dentro de cada año. 
Primero los ordene en orden descendente y con ranking solo desplegue los primeros 5. 
*****************************************/
WITH CasosPorEntidad AS (
    SELECT 
        ENTIDAD_RES, 
        YEAR(FECHA_INGRESO) AS año, 
        COUNT(*) AS num_casos_confirmados
    FROM 
        datoscovid
    WHERE 
        CLASIFICACION_FINAL IN ('1', '2', '3')  -- Casos confirmados
    GROUP BY 
        ENTIDAD_RES, YEAR(FECHA_INGRESO)
)
SELECT 
    ce.entidad AS nombre_entidad, 
    cpe.año, 
    cpe.num_casos_confirmados
FROM (
    SELECT 
        ENTIDAD_RES, 
        año, 
        num_casos_confirmados,
        ROW_NUMBER() OVER (PARTITION BY año ORDER BY num_casos_confirmados DESC) AS ranking
    FROM 
        CasosPorEntidad
) AS cpe
JOIN 
    cat_entidades ce ON cpe.ENTIDAD_RES = ce.clave
WHERE 
    ranking <= 5
ORDER BY 
    cpe.año, cpe.ranking;






/*****************************************
Vistas utilizadas
Responsable de la vista: Juan
*****************************************/


go --Vista para gente que se recupero
create view casos_recuperados as
select ENTIDAD_UM, ENTIDAD_NAC, ENTIDAD_RES, MUNICIPIO_RES, SEXO, EDAD, FECHA_INGRESO, FECHA_DEF, NEUMONIA, DIABETES, HIPERTENSION, OBESIDAD, TABAQUISMO, CLASIFICACION_FINAL
from casos_confirmados	--Todos los casos recuperados
where CAST(left(FECHA_DEF,4) as INT) = 9999 --Estos son los casos recuperados, lo tuve que hacer asi por que year no funciona con esta columna
--Sustrae los primeros 4 valores de una cadena y los tranforma a enteros para hacer la comparacion

go
create view casos_confirmados as
select ENTIDAD_UM, ENTIDAD_NAC, ENTIDAD_RES, MUNICIPIO_RES, SEXO, EDAD, FECHA_INGRESO, FECHA_DEF, NEUMONIA, DIABETES, HIPERTENSION, OBESIDAD, TABAQUISMO, CLASIFICACION_FINAL
from datoscovid
where CLASIFICACION_FINAL in ('1', '2', '3')	--Se utiliza esta 1,2,3 porque en el catalogo son las confirmaciones de la enfermedad


--Practica 1

--Hay el años que son entre 2020 2021 2022

select ENTIDAD_RES, year(FECHA_INGRESO) as año, count(*) as num_casos_confirmados
from datoscovid
where CLASIFICACION_FINAL in ('1', '2', '3') -- and ENTIDAD_RES in ('10','11') -- para pruebas
group by ENTIDAD_RES, year(FECHA_INGRESO)
having count(*) =   ( --autoreunion
					select max(num_casos_confirmados)
					from(
						select ENTIDAD_RES, year(FECHA_INGRESO) as año, count(*) as num_casos_confirmados
						from datoscovid
						where CLASIFICACION_FINAL in ('1', '2', '3') -- and ENTIDAD_RES in ('10','11') --Para pruebas
						group by ENTIDAD_RES, year(FECHA_INGRESO)
					    ) as T1
					)

/*****************************************
Consulta 02. Listar el municipio con más casos confirmados recuperados por estado y por año.
Requisitos: Agrupaciones por estado municipio y año
Significado de los valores de los catálogos: Hay que encontrar el monicipio top por estado y año
Responsable de la consulta: Juan
Comentarios: Estaba un poco ambiguo pero son detalles tecnicos
*****************************************/
select ENTIDAD_RES, entidad, MUNICIPIO_RES, YEAR(FECHA_INGRESO) as anio_Ingreso, COUNT(*) as total_Recuperados
from casos_recuperados
inner join cat_entidades on ENTIDAD_RES = clave
group by ENTIDAD_RES, MUNICIPIO_RES, YEAR(FECHA_INGRESO), entidad
having COUNT(*) = (
	select MAX(total_Recuperados)
	from (
		select ENTIDAD_RES, MUNICIPIO_RES, YEAR(FECHA_INGRESO) as anio_Ingreso, COUNT(*) as total_Recuperados
        from casos_recuperados
        group by ENTIDAD_RES, MUNICIPIO_RES, YEAR(FECHA_INGRESO)
     ) as subquery
     where subquery.anio_Ingreso = YEAR(casos_recuperados.FECHA_INGRESO)
     and subquery.ENTIDAD_RES = casos_recuperados.ENTIDAD_RES
)
	
/*****************************************
 3. Listar el porcentaje de casos confirmados en cada una de las siguientes morbilidades a nivel nacional: diabetes, obesidad e hipertensión.
 
 En CLASIFICACION_FINAL los valores 1, 2 y 3 son confirmados.
 DIABETES HIPERTENSION OBESIDAD son columnas de catálogo SI/NO donde 1 es SI
 
 Responsable de la consulta: Keb
 
 Comentarios:
 *****************************************/
SELECT
	CAST(COUNT(IIF(DIABETES = 1, 1, Null))*100.0/COUNT(*) as DECIMAL(4,2)) as Porcentaje_DIABETES,
	CAST(COUNT(IIF(HIPERTENSION = 1, 1, Null))*100.0/COUNT(*) as DECIMAL(4,2)) as Porcentaje_Hipertension,
	CAST(COUNT(IIF(OBESIDAD= 1, 1, Null))*100.0/COUNT(*) as DECIMAL(4,2)) as Porcentaje_Obesidad
FROM datoscovid
WHERE CLASIFICACION_FINAL IN (1, 2, 3);

/*****************************************
4. Listar los municipios que no tengan casos confirmados en todas las morbilidades: hipertensión, obesidad, diabetes y tabaquismo.
Requisitos:
- Mostrar el nombre del municipio.
- Mostrar solo los municipios que no tienen casos confirmados en ninguna de las morbilidades.
Significado de los valores de los catálogos:
- CLASIFICACION_FINAL: 1, 2, 3 = Casos confirmados.
- HIPERTENSION, OBESIDAD, DIABETES, TABAQUISMO: 1 = Sí, 0 = No.
Responsable de la consulta: Armando Eduardo Sánchez Herrera 
Comentarios:
- Se utiliza una CTE para calcular el número de casos confirmados para cada morbilidad por municipio.
- Se filtran los municipios que no tienen casos confirmados en ninguna de las morbilidades.
*****************************************/
WITH CasosMorbilidad AS (
    SELECT 
        MUNICIPIO_RES,
        SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS casos_hipertension,
        SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS casos_obesidad,
        SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS casos_diabetes,
        SUM(CASE WHEN TABAQUISMO = 1 THEN 1 ELSE 0 END) AS casos_tabaquismo
    FROM 
        datoscovid
    WHERE 
        CLASIFICACION_FINAL NOT IN ('1', '2', '3')  -- Casos NO confirmados (sospechosos o no confirmados)
    GROUP BY 
        MUNICIPIO_RES
)
SELECT 
    MUNICIPIO_RES
FROM 
    CasosMorbilidad
WHERE 
    casos_hipertension > 0 
    AND casos_obesidad > 0 
    AND casos_diabetes > 0 
    AND casos_tabaquismo > 0;
/*****************************************
Consulta 05. Listar los estados con más casos recuperados con neumonía.
Requisitos: Agrupaciones por estado y buscar los casos por neumonia
Significado de los valores de los catálogos: casos_Recuperados es una vista que cita a la gente que se curo
Responsable de la consulta: Juan
Comentarios: -- aquí, explicar las instrucciones adicionales
Utilizadas y no explicadas en clase.
*****************************************/
select ENTIDAD_RES, entidad, count(*) as numero_Casos --Resultados esperados
from casos_recuperados	--Todos los casos recuperados
inner join cat_entidades on ENTIDAD_RES = clave
where NEUMONIA = 1	--1 Significa que si tenian neumonia
group by ENTIDAD_RES, entidad	--Agrupamos por estados
order by numero_Casos desc	--Los acomodamos en orden porque YOLO

/*****************************************
 6. Listar el total de casos confirmados/sospechosos por estado en cada uno de los años registrados en la base de datos.
 
 Se usa la fecha de ingreso porque es el dato que mejor se adapta
 En CLASIFICACION_FINAL los valores 1, 2 y 3 son confirmados, 6 sospechoso.
 
 Responsable de la consulta: Keb
 
 Comentarios:
  
 *****************************************/


SELECT
	YEAR(FECHA_INGRESO) AS Año,
	entidad AS Entidad,
	COUNT(
		CASE
			WHEN CLASIFICACION_FINAL IN (1,2,3) THEN 1
		END
	) as CASOS_CONFIRMADOS,
	COUNT(
		CASE
			WHEN CLASIFICACION_FINAL = 6 THEN 1
		END
	) AS CASOS_SOSPECHOSOS
FROM datoscovid JOIN cat_entidades
	ON datoscovid.ENTIDAD_UM = cat_entidades.clave
GROUP BY entidad, YEAR(FECHA_INGRESO)
ORDER BY entidad, YEAR(FECHA_INGRESO);

/*****************************************

7. Para el año 2020 y 2021, cuál fue el mes con más casos registrados, confirmados y sospechosos, por estado registrado en la base de datos.

Requisitos:

- Mostrar el nombre de la entidad.

- Mostrar el mes con más casos por estado y año.

Significado de los valores de los catálogos:

- CLASIFICACION_FINAL: 1, 2, 3 = Casos confirmados; 6 = Casos sospechosos.

Responsable de la consulta: Armando Eduardo Sanchez Herrera

Comentarios:

- Se utiliza una CTE para calcular el número de casos confirmados y sospechosos por estado, año y mes.

- Se hace un JOIN con la tabla de catálogo de entidades para obtener el nombre de la entidad.

- Se utiliza ROW_NUMBER() para asignar un ranking a cada mes dentro de cada estado y año.

- Se filtran solo los meses con más casos por estado y año.

*****************************************/

WITH CasosPorMes AS (

    SELECT 

        ENTIDAD_RES, 

        YEAR(FECHA_INGRESO) AS año, 

        MONTH(FECHA_INGRESO) AS mes, 

        COUNT(*) AS total_casos

    FROM 

        datoscovid

    WHERE 

        CLASIFICACION_FINAL IN ('1', '2', '3', '6')  -- Casos confirmados y sospechosos

        AND YEAR(FECHA_INGRESO) IN (2020, 2021)

    GROUP BY 

        ENTIDAD_RES, YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)

)

SELECT 

    ce.entidad AS nombre_entidad, 

    cpm.año, 

    cpm.mes, 

    cpm.total_casos

FROM (

    SELECT 

        ENTIDAD_RES, 

        año, 

        mes, 

        total_casos,

        ROW_NUMBER() OVER (PARTITION BY ENTIDAD_RES, año ORDER BY total_casos DESC) AS ranking

    FROM 

        CasosPorMes

) AS cpm

JOIN 

    cat_entidades ce ON cpm.ENTIDAD_RES = ce.clave

WHERE 

    ranking = 1

ORDER BY 

    cpm.año, ce.entidad;

/*****************************************
Consulta 08. Listar el municipio con menos defunciones en el mes con más casos confirmados con neumonía en los años 2020 y 2021.
Requisitos: Agrupaciones por municipios y seleccionar por meses
Significado de los valores de los catálogos: casos_confirmados para separa la inf 
Responsable de la consulta: Juan
Comentarios: -- aquí, explicar las instrucciones adicionales
Utilizadas y no explicadas en clase.
*****************************************/
select *
from(
	select ENTIDAD_RES, MUNICIPIO_RES, YEAR(FECHA_INGRESO) as anio_Ingreso, MONTH(FECHA_INGRESO) as Mes_Ingreso, count(*) as casos_defunsion
	from casos_confirmados
	where NEUMONIA = 1 and YEAR(FECHA_INGRESO) in ('2021') and CAST(left(FECHA_DEF,4) as INT) != 9999
	--where NEUMONIA = 1 and YEAR(FECHA_INGRESO) in ('2020') and CAST(left(FECHA_DEF,4) as INT) != 9999
	and MONTH(FECHA_INGRESO) = 1 
	--and MONTH(FECHA_INGRESO) = 7
	group by MUNICIPIO_RES, YEAR(FECHA_INGRESO),  MONTH(FECHA_INGRESO), ENTIDAD_RES	--Agrupamos para poder valorar lo resultados
) as T2
where T2.casos_defunsion = 1
union
select *
from(
	select ENTIDAD_RES, MUNICIPIO_RES, YEAR(FECHA_INGRESO) as anio_Ingreso, MONTH(FECHA_INGRESO) as Mes_Ingreso, count(*) as casos_defunsion
	from casos_confirmados
	--where NEUMONIA = 1 and YEAR(FECHA_INGRESO) in ('2021') and CAST(left(FECHA_DEF,4) as INT) != 9999
	where NEUMONIA = 1 and YEAR(FECHA_INGRESO) in ('2020') and CAST(left(FECHA_DEF,4) as INT) != 9999
	--and MONTH(FECHA_INGRESO) = 1 
	and MONTH(FECHA_INGRESO) = 7
	group by MUNICIPIO_RES, YEAR(FECHA_INGRESO),  MONTH(FECHA_INGRESO), ENTIDAD_RES	--Agrupamos para poder valorar lo resultados
) as T3
where T3.casos_defunsion = 1

--Consulta para saber que mes es el top
having  count(*) = (
	select max(Casos_con_confirmados_Neumonia)
	from(
		select YEAR(FECHA_INGRESO) as Anio_Ingreso, MONTH(FECHA_INGRESO) as Mes_Ingreso,count(*) as Casos_con_confirmados_Neumonia
		from casos_confirmados
		where NEUMONIA = 1 and YEAR(FECHA_INGRESO) in ('2020')
		group by YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)
	) as T1
)

/*****************************************
 9. Listar el top 3 de municipios con menos casos recuperados en el año 2021.
 
 Año(FECHA_DEF) = 9999 son casos recuperados
 
 Responsable de la consulta: Keb
 
 Comentarios:
  CAST(left(FECHA_DEF,4) as INT) es para sacar el año
  IIF es el operador ternario, más simple que un CASE
 *****************************************/

select top 3
	MUNICIPIO_RES, count(IIF(CAST(left(FECHA_DEF,4) as INT) = 9999, 1, NULL)) as CASOS_RECUPERADOS
from datoscovid
where YEAR(FECHA_INGRESO) = 2021
group by MUNICIPIO_RES
order by CASOS_RECUPERADOS;

/*****************************************

10. Listar el porcentaje de casos confirmados por género en los años 2020 y 2021.

Requisitos:

- Mostrar el porcentaje de casos confirmados por género (1 = Mujer, 2 = Hombre) y por año.

Significado de los valores de los catálogos:

- CLASIFICACION_FINAL: 1, 2, 3 = Casos confirmados.

- SEXO: 1 = Mujer, 2 = Hombre.

Responsable de la consulta: Armando Eduardo Sánchez Herrera

Comentarios:

- Se utiliza una CTE para calcular el número de casos confirmados por género y año.

- Se calcula el porcentaje de casos por género y año dividiendo el número de casos por género y año entre el total de casos por año.

*****************************************/

WITH CasosPorGenero AS (
    SELECT 
        SEXO, 
        YEAR(FECHA_INGRESO) AS año, 
        COUNT(*) AS total_casos
    FROM 
        datoscovid
    WHERE 
        CLASIFICACION_FINAL IN ('1', '2', '3')  -- Casos confirmados
        AND YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY 
        SEXO, YEAR(FECHA_INGRESO)
),
TotalCasosPorAño AS (
    SELECT 
        YEAR(FECHA_INGRESO) AS año, 
        COUNT(*) AS total
    FROM 
        datoscovid
    WHERE 
        CLASIFICACION_FINAL IN ('1', '2', '3')  -- Casos confirmados
        AND YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY 
        YEAR(FECHA_INGRESO)
)
SELECT 
    cpg.año,
    CASE 
        WHEN cpg.SEXO = 1 THEN 'Mujer'
        WHEN cpg.SEXO = 2 THEN 'Hombre'
        ELSE 'No especificado'
    END AS género,
    cpg.total_casos AS cantidad_casos,  -- Cantidad de casos por género y año
    CAST(cpg.total_casos * 100.0 / tca.total AS DECIMAL(5, 2)) AS porcentaje  -- Porcentaje de casos
FROM 
    CasosPorGenero cpg
JOIN 
    TotalCasosPorAño tca ON cpg.año = tca.año
ORDER BY 
    cpg.año, cpg.SEXO; 
/*****************************************
Consulta 11. Listar el porcentaje de casos hospitalizados por estado en el año 2020.
Requisitos: Buscar la cantidad de casos para poder hacer calculos de porcentajes
Significado de los valores de los catálogos: Tenemos que usar los datos bases para poder sacar el inf de hospital
Responsable de la consulta: Juan
Comentarios: -- aquí, explicar las instrucciones adicionales
Utilizadas y no explicadas en clase.
*****************************************/
SELECT ENTIDAD_NAC, 
(COUNT(*) * 100.0 / (	--Calculo del procentaje usando numero*100%/Total
	SELECT SUM(T1.Casos_Hospitalizados)
	FROM (
		SELECT ENTIDAD_NAC, MONTH(FECHA_INGRESO) AS mes, COUNT(*) AS Casos_Hospitalizados --Contamos a los usuarios que fueron hospitalizados
		FROM datoscovid	--Mi vista no tiene los datos de hospital por eso lo hago asi
		WHERE CLASIFICACION_FINAL IN ('1', '2', '3')	-- Para solicitar los casos confirmados
		AND TIPO_PACIENTE = 2	--Paciente que fue hospitalizado
        AND YEAR(FECHA_INGRESO) = '2020'	--Restringuimos la busqueda en el año 2020
        GROUP BY MONTH(FECHA_INGRESO), ENTIDAD_NAC	--Agrupamos por entidades y meses para poder hacer la cuenta completa
     ) AS T1))
AS Porcentaje_Casos -- Variable que usamos para calcular el procentaje, total de persona hospiatalizada en 2020
FROM datoscovid
WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
AND TIPO_PACIENTE = 2 
AND YEAR(FECHA_INGRESO) = '2020'
GROUP BY ENTIDAD_NAC
order by Porcentaje_Casos desc	--Me gusta que vaya de mayor a menor siempre

/*****************************************
12. Listar total de casos negativos por estado en los años 2020 y 2021. 

CLASIFICACION_FINAL = 7 : Casos negativos

Responsable de la consulta: Keb

Comentarios:
 *****************************************/
SELECT
        entidad AS Entidad,
        COUNT(
                CASE
                        WHEN (
                                CLASIFICACION_FINAL = 7
                AND YEAR (FECHA_INGRESO) = 2020
                        ) THEN 1
                END
        ) as CASOS_NEGATIVOS_2020,
        COUNT(
                CASE
                        WHEN (
                                CLASIFICACION_FINAL = 7
                AND YEAR (FECHA_INGRESO) = 2021
                        ) THEN 1
                END
        ) as CASOS_NEGATIVOS_2021
FROM
        datoscovid
        JOIN cat_entidades ON datoscovid.ENTIDAD_UM = cat_entidades.clave
GROUP BY
        entidad
ORDER BY
        entidad;

/*****************************************
13. Listar porcentajes de casos confirmados por género en el rango de edades de 20 a 30 años, de 31 a 40 años, de 41 a 50 años, de 51 a 60 años y mayores a 60 años a nivel nacional.
Requisitos:
- Mostrar el porcentaje de casos confirmados por género en los rangos de edad especificados.
Significado de los valores de los catálogos:
- CLASIFICACION_FINAL: 1, 2, 3 = Casos confirmados.
- SEXO: 1 = Mujer, 2 = Hombre.
Responsable de la consulta: Armando Eduardo Sánchez Herrera 
Comentarios:
- Se utiliza una CTE para calcular el número de casos confirmados por género y rango de edad.
- Se utiliza una expresión CASE para definir los rangos de edad.
- Se calcula el porcentaje de casos por género y rango de edad.
*****************************************/
WITH CasosPorEdad AS (
    SELECT 
        SEXO, 
        CASE 
            WHEN EDAD BETWEEN 20 AND 30 THEN '20-30'
            WHEN EDAD BETWEEN 31 AND 40 THEN '31-40'
            WHEN EDAD BETWEEN 41 AND 50 THEN '41-50'
            WHEN EDAD BETWEEN 51 AND 60 THEN '51-60'
            ELSE '60+' 
        END AS rango_edad, 
        COUNT(*) AS total_casos
    FROM 
        datoscovid
    WHERE 
        CLASIFICACION_FINAL IN ('1', '2', '3')  -- Casos confirmados
    GROUP BY 
        SEXO, 
        CASE 
            WHEN EDAD BETWEEN 20 AND 30 THEN '20-30'
            WHEN EDAD BETWEEN 31 AND 40 THEN '31-40'
            WHEN EDAD BETWEEN 41 AND 50 THEN '41-50'
            WHEN EDAD BETWEEN 51 AND 60 THEN '51-60'
            ELSE '60+' 
        END
),
TotalCasos AS (
    SELECT 
        COUNT(*) AS total
    FROM 
        datoscovid
    WHERE 
        CLASIFICACION_FINAL IN ('1', '2', '3')  -- Casos confirmados
)
SELECT 
    CASE 
        WHEN SEXO = 1 THEN 'Mujer'    
        WHEN SEXO = 2 THEN 'Hombre'    
        ELSE 'No especificado'        
    END AS género,
    rango_edad, 
    total_casos AS cantidad_casos,  -- Cantidad de casos por género y rango de edad
    CAST(total_casos * 100.0 / (SELECT total FROM TotalCasos) AS DECIMAL(5, 2)) AS porcentaje  -- Porcentaje de casos
FROM 
    CasosPorEdad
ORDER BY 
    SEXO, rango_edad;
/*****************************************
Consulta 14. Listar el rango de edad con más casos confirmados y que fallecieron en los años 2020 y 2021.
Requisitos: categorizar por edades y contar para saber la cantidad de fallecidos y poder listar
Significado de los valores de los catálogos: usamos tecnicas de cast
Responsable de la consulta: Juan
Comentarios: -- aquí, explicar las instrucciones adicionales
Utilizadas y no explicadas en clase.
*****************************************/
select EDAD, count(*) as Cantidad_de_Fallecidos
from casos_confirmados
where CAST(left(FECHA_DEF,4) as INT) = 2020 or CAST(left(FECHA_DEF,4) as INT) = 2021
group by EDAD
order by Cantidad_de_Fallecidos desc
