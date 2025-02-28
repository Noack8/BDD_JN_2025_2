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


--Una vista de casos confirmados

