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
Significado de los valores de los catálogos: casos_Recuperados es una vista que cita a la gente que se curo
Responsable de la consulta: Juan
Comentarios: -- aquí, explicar las instrucciones adicionales
Utilizadas y no explicadas en clase.
*****************************************/
select ENTIDAD_NAC, MUNICIPIO_RES, YEAR(FECHA_INGRESO) as anio_Ingreso, count(*) as total_Recuperados --Sacamo los datos para que se vea shido
from casos_recuperados	--Uso de la vista de casos confirmados para disminuir la busqueda
group by MUNICIPIO_RES, YEAR(FECHA_INGRESO), ENTIDAD_NAC	--Agrupamos para poder valorar lo resultados
having  count(*) = (  --Autoreunion
	select max(casos_recuperados)	--Buscamos el municipio por estaddo y año con mayor numero de casos recuperados
	from(
		select ENTIDAD_NAC, MUNICIPIO_RES, YEAR(FECHA_INGRESO) as Anio_Ingreso,count(*) as Casos_Recuperados --Datos relevantes
		from casos_recuperados --Vista rapida
		group by MUNICIPIO_RES, YEAR(FECHA_INGRESO), ENTIDAD_NAC	--El orden de arupacion es importante
	) as T1 
	where T1.anio_Ingreso = YEAR(FECHA_INGRESO)	--Usamos la concordancia donde el anio corresponda 
	and T1.ENTIDAD_NAC = ENTIDAD_NAC  -- Usamos el estado en particular
)
	
/*****************************************
 3. Listar el porcentaje de casos confirmados en cada una de las siguientes morbilidades a nivel nacional: diabetes, obesidad e hipertensión.
 
 En CLASIFICACION_FINAL los valores 1, 2 y 3 son confirmados.
 DIABETES HIPERTENSION OBESIDAD son columnas de catálogo SI/NO donde 1 es SI
 
 Responsable de la consulta: Keb
 
 Comentarios:
  
 *****************************************/
DROP TABLE IF EXISTS CASOS_COMORBILIDADES;
DROP TABLE IF EXISTS CASOS_OBESIDAD;

SELECT
	DIABETES,
	HIPERTENSION,
	OBESIDAD,
	CASE
		WHEN CLASIFICACION_FINAL IN (1, 2, 3) then 1
		ELSE 0
	END AS CONFIRMADO_COVID,
	COUNT(1) AS CASOS
INTO CASOS_COMORBILIDADES
FROM datoscovid
GROUP BY
	OBESIDAD,
	DIABETES,
	HIPERTENSION,
	CLASIFICACION_FINAL
HAVING (OBESIDAD = 1 OR DIABETES = 1 OR HIPERTENSION = 1);

-- Obtener el total de casos por cada enfermedad
Declare @TOTAL_OBESIDAD int;
SELECT @TOTAL_OBESIDAD = sum(CASOS)
FROM CASOS_COMORBILIDADES
WHERE OBESIDAD = 1;


Declare @TOTAL_DIABETES int;
SELECT @TOTAL_DIABETES = sum(CASOS)
FROM CASOS_COMORBILIDADES
WHERE DIABETES = 1;


Declare @TOTAL_HIPERTENSION int;
SELECT @TOTAL_HIPERTENSION = sum(CASOS)
FROM CASOS_COMORBILIDADES
WHERE HIPERTENSION = 1;


WITH
	CASOS_COMOR_CONFIRMADA
	AS
	(
		SELECT
			*
		FROM
			CASOS_COMORBILIDADES
		WHERE CONFIRMADO_COVID = 1
	)

	SELECT
		'Obesidad' as Enfermedad,
		CAST(SUM(CASOS) * 100.0 / @TOTAL_OBESIDAD AS decimal(4, 2)) as PorcentajeConfirmadoCovid
	FROM CASOS_COMOR_CONFIRMADA
	GROUP BY OBESIDAD
	HAVING OBESIDAD = 1
UNION
	SELECT
		'Diabetes' as Enfermedad,
		CAST(SUM(CASOS) * 100.0 / @TOTAL_DIABETES AS decimal(4, 2)) as PorcentajeConfirmadoCovid
	FROM CASOS_COMOR_CONFIRMADA
	GROUP BY DIABETES
	HAVING DIABETES = 1
UNION
	SELECT
		'Hipertension' as Enfermedad,
		CAST(SUM(CASOS) * 100.0 / @TOTAL_DIABETES AS decimal(4, 2)) as PorcentajeConfirmadoCovid
	FROM CASOS_COMOR_CONFIRMADA
	GROUP BY HIPERTENSION
	HAVING HIPERTENSION = 1;

DROP TABLE IF EXISTS CASOS_COMORBILIDADES;
DROP TABLE IF EXISTS CASOS_OBESIDAD;

/*****************************************
Consulta 05. Listar los estados con más casos recuperados con neumonía.
Requisitos: Agrupaciones por estado y buscar los casos por neumonia
Significado de los valores de los catálogos: casos_Recuperados es una vista que cita a la gente que se curo
Responsable de la consulta: Juan
Comentarios: -- aquí, explicar las instrucciones adicionales
Utilizadas y no explicadas en clase.
*****************************************/
select ENTIDAD_NAC, count(*) as numero_Casos --Resultados esperados
from casos_recuperados	--Todos los casos recuperados
where NEUMONIA = 1	--1 Significa que si tenian neumonia
group by ENTIDAD_NAC	--Agrupamos por estados
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
			WHEN CLASIFICACION_FINAL = 4 THEN 1
		END
	) AS CASOS_SOSPECHOSOS
FROM datoscovid JOIN cat_entidades
	ON datoscovid.ENTIDAD_UM = cat_entidades.clave
GROUP BY entidad, YEAR(FECHA_INGRESO)
ORDER BY entidad, YEAR(FECHA_INGRESO);

/*****************************************
Consulta 08. Listar el municipio con menos defunciones en el mes con más casos confirmados con neumonía en los años 2020 y 2021.
Requisitos: Agrupaciones por municipios y seleccionar por meses
Significado de los valores de los catálogos: casos_confirmados para separa la inf 
Responsable de la consulta: Juan
Comentarios: -- aquí, explicar las instrucciones adicionales
Utilizadas y no explicadas en clase.
*****************************************/
select ENTIDAD_NAC, MUNICIPIO_RES, YEAR(FECHA_INGRESO) as anio_Ingreso, MONTH(FECHA_INGRESO) as Mes_Ingreso
from casos_confirmados
where NEUMONIA = 1 and YEAR(FECHA_INGRESO) in ('2020', '2021') and CAST(left(FECHA_DEF,4) as INT) != 9999
group by MUNICIPIO_RES, YEAR(FECHA_INGRESO),  MONTH(FECHA_INGRESO), ENTIDAD_NAC	--Agrupamos para poder valorar lo resultados
having  count(*) = (  
	select min(Casos_con_Defuncion)	--Busqueda de casos de defuncion que se les detectaron neumonia
	from(
		select ENTIDAD_NAC, MUNICIPIO_RES, YEAR(FECHA_INGRESO) as Anio_Ingreso, MONTH(FECHA_INGRESO) as Mes_Ingreso,count(*) as Casos_con_Defuncion
		from casos_confirmados
		where NEUMONIA = 1 and YEAR(FECHA_INGRESO) in ('2020', '2021') and CAST(left(FECHA_DEF,4) as INT) != 9999
		--Estrechamos la busqueda a valores que necesitamos detectar y eliminar los casos donde se curaron
		group by MUNICIPIO_RES, YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO), ENTIDAD_NAC	--El orden de agrupacion es importante
	) as T1
	where T1.anio_Ingreso = YEAR(FECHA_INGRESO)
	and T1.Mes_Ingreso = MONTH(FECHA_INGRESO) --Comparamos por mes para que se pueda listar
)
order by YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)

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
