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

--order by año desc--Esto genera un costo extra de procesamiento

--Consulta 2 por Juan:
--Listar el municipio con más casos confirmados recuperados por estado y por año.

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

/*Prueba 1
select ENTIDAD_NAC, YEAR(FECHA_INGRESO) as anio_Ingreso, count(*) as total_Recuperados --Sacamo los datos para que se vea shido
from casos_confirmados	--Uso de la vista de casos confirmados para disminuir la busqueda
where CAST(LEFT(FECHA_DEF, 4) AS INT) = 9999 --Seleccionamos solo los casos recuperados
group by ENTIDAD_NAC, YEAR(FECHA_INGRESO)	--Agrupamos para poder valorar lo resultados
having  count(*) = ( --Autoreunion
	select max(total_Recuperados) --Escogemos los valores maximos contados por año
	from(
		select ENTIDAD_NAC, YEAR(FECHA_INGRESO) as anio_Ingreso, count(*) as total_Recuperados --Resultados de interes
		from casos_confirmados	--Todos los casos recuperados
		where CAST(left(FECHA_DEF,4) as INT) = 9999 --Estos son los casos recuperados, lo tuve que hacer asi por que year no funciona con esta columna
		--Sustrae los primeros 4 valores de una cadena y los tranforma a enteros para hacer la comparacion
		group by ENTIDAD_NAC, YEAR(FECHA_INGRESO)	--Con ello podemos juntar los valores a tomar en cuenta
	)as T1
	where T1.anio_Ingreso = YEAR(FECHA_INGRESO)	--Relacionamos el año de la busqueda anterior con el maximo actual
)
/*

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

--Consulta 5 por Juan:
--Listar los estados con más casos recuperados con neumonía.

select ENTIDAD_NAC, count(*) as numero_Casos --Resultados esperados
from casos_recuperados	--Todos los casos recuperados
where NEUMONIA = 1	--1 Significa que si tenian neumonia
group by ENTIDAD_NAC	--Agrupamos por estados
order by numero_Casos desc	--Los acomodamos en orden porque YOLO

--Una vista de casos confirmados y columnas de interes
--Por Juan
/*
go --Vista para gente que se recupero
create view casos_recuperados as
select ENTIDAD_UM, ENTIDAD_NAC, ENTIDAD_RES, MUNICIPIO_RES, SEXO, EDAD, FECHA_INGRESO, FECHA_DEF, NEUMONIA, DIABETES, HIPERTENSION, OBESIDAD, TABAQUISMO, CLASIFICACION_FINAL
from casos_confirmados	--Todos los casos recuperados
where CAST(left(FECHA_DEF,4) as INT) = 9999 --Estos son los casos recuperados, lo tuve que hacer asi por que year no funciona con esta columna
--Sustrae los primeros 4 valores de una cadena y los tranforma a enteros para hacer la comparacion
*/
/*
go
create view casos_confirmados as
select ENTIDAD_UM, ENTIDAD_NAC, ENTIDAD_RES, MUNICIPIO_RES, SEXO, EDAD, FECHA_INGRESO, FECHA_DEF, NEUMONIA, DIABETES, HIPERTENSION, OBESIDAD, TABAQUISMO, CLASIFICACION_FINAL
from datoscovid
where CLASIFICACION_FINAL in ('1', '2', '3')	--Se utiliza esta 1,2,3 porque en el catalogo son las confirmaciones de la enfermedad
*/

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
