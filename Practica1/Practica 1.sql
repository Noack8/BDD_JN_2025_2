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


--Una vista de casos confirmados y columnas de interes
--Por Juan
/*
go
create view casos_confirmados as
select ENTIDAD_UM, ENTIDAD_NAC, ENTIDAD_RES, MUNICIPIO_RES, SEXO, EDAD, FECHA_INGRESO, FECHA_DEF, NEUMONIA, DIABETES, HIPERTENSION, OBESIDAD, TABAQUISMO, CLASIFICACION_FINAL
from datoscovid
where CLASIFICACION_FINAL in ('1', '2', '3')	--Se utiliza esta 1,2,3 porque en el catalogo son las confirmaciones de la enfermedad
*/
