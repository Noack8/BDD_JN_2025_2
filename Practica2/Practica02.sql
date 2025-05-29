-- 1.Crear una base de datos con el nombre practicaPE
create database practicaPE

--------------------------------------------------------------------------------------------------------------------------
	
--2.Copiar a la base de datos practicaPE las siguientes tablas de la base de datos
--AdvetureWorks

select * into SalesOrderHeader from AdventureWorks.Sales.SalesOrderHeader

select * into SalesOrderDetail from AdventureWorks.Sales.SalesOrderDetail

select * into Customer from AdventureWorks.Sales.Customer

select * into SalesTerritory from AdventureWorks.Sales.SalesTerritory

select * into Product from AdventureWorks.Production.Product

select * into ProductCategory from AdventureWorks.Production.ProductCategory

select * into ProductSubcategory from AdventureWorks.Production.ProductSubcategory

select BusinessEntityID, FirstName, LastName into Person
from AdventureWorks.Person.Person

----------------------------------------------------------------------------------------------------------------
	
--3.Codificar las siguientes consultas
	--A.Listar el producto mas vendido de cada una de las categorias registradas en la base
	--de datos
	
--Consulta final A v2.2
select PS.ProductCategoryID, PS.ProductID, PS.Total
from ( select T4.ProductID, T4.ProductCategoryID, sum(T3.OrderQty) Total
       from SalesOrderDetail as T3
       inner join ( select T1.ProductID, T1.ProductSubcategoryID, T2.ProductCategoryID
                    from Product as T1
                    inner join ProductSubcategory as T2
                    on T1.ProductSubcategoryID = T2.ProductSubcategoryID) as T4 
       on T3.ProductID = T4.ProductID
       group by T4.ProductID, T4.ProductCategoryID) as PS
where PS.Total = ( select max(SUM_TQ)
                   from ( select T4b.ProductCategoryID, sum(T3b.OrderQty) as SUM_TQ
                          from SalesOrderDetail as T3b
                          inner join ( select T1b.ProductID, T1b.ProductSubcategoryID, T2b.ProductCategoryID
                                       from Product as T1b
                                       inner join ProductSubcategory as T2b
                                       on T1b.ProductSubcategoryID = T2b.ProductSubcategoryID) as T4b 
						  on T3b.ProductID = T4b.ProductID
                          where T4b.ProductCategoryID = PS.ProductCategoryID
                          group by T4b.ProductID, T4b.ProductCategoryID) as CategorySales)

	--B.Listar el nombre de los clientes con mas ordenes por cada uno de los territorios
	--registrados en la base de datos
	
--Consulta final B v1.2
select TerritoryID, FirstName, LastName, Compras_realizadas
from ( select T1.TerritoryID, T4.FirstName, T4.LastName, 
              count(*) as Compras_realizadas, 
			  row_number() over (partition by T1.TerritoryID order by count(*) desc) as rn
       from SalesOrderHeader as T1
       inner join Customer as T3 
	   on T1.CustomerID = T3.CustomerID
       inner join Person as T4 
	   on T3.PersonID = T4.BusinessEntityID
       group by T1.TerritoryID, T3.CustomerID, T4.FirstName, T4.LastName ) as rango
where rn = 1


	--C.Listar los datos generales de las ordenes que tengan al menos los mismos productos
	--de la orden con SalesOrderId = 43676
--Consulta final C version profesor
SELECT DISTINCT Salesorderid
FROM SalesOrderDetail AS OD
WHERE NOT EXISTS (SELECT *
				  FROM (select ProductID
						from SalesOrderDetail
						where salesorderid = 43676) as P
				  WHERE NOT EXISTS (SELECT *
									FROM SalesOrderDetail AS OD2
									WHERE OD.SalesOrderID = OD2.SalesOrderID
									AND OD2.ProductID = P.ProductID ))

-------------------------------------------------------------------------------------------------------------------------
	
--4. Generar los planes de ejecucion de las consultas en la base de datos practicaPE y proponer
--indices para mejorar el rendimiento de las consultas.

--Indices relacionados a la consulta A
create clustered index IC_P_PRODUCTID on Product (ProductID)
create clustered index IC_PSC_PRODUCTSUBCATEGORY on ProductSubcategory (ProductSubcategoryID)
create nonclustered index INC_SOD_OQTY_PID on SalesOrderDetail (OrderQty) include (ProductID)

--Indices relacionados a la consulta B
create clustered index IC_C_CUSTOMERID on Customer (CustomerID)

create clustered index IC_SOH_SalesOrderID on SalesOrderHeader (SalesOrderID)
create nonclustered index INC_SOH_TerritoryID on SalesOrderHeader (TerritoryID)

create clustered index IC_P_BusinessEntityID on Person (BusinessEntityID)
create nonclustered index IC_P_FIRSTNAME_LAST on Person (FirstName) include (LastName)

--Indices relacionados a la consulta C
create clustered index IC_SOD_SalesOrderDetailID on SalesOrderDetail (SalesOrderDetailID)
create nonclustered index INC_SOD_SalesOrderID on SalesOrderDetail (SalesOrderID)
	
------------------------------------------------------------------------------------------------------------------

--5. Generar los planes de ejecucion de las consultas en la base de datos AdventureWorks y
--y comparar con los planes de ejecucion del punto 4.

--Consulta final A adventureWorks
select PS.ProductCategoryID, PS.ProductID, PS.Total
from ( select T4.ProductID, T4.ProductCategoryID, sum(T3.OrderQty) Total
       from Sales.SalesOrderDetail as T3
       inner join ( select T1.ProductID, T1.ProductSubcategoryID, T2.ProductCategoryID
                    from Production.Product as T1
                    inner join Production.ProductSubcategory as T2
                    on T1.ProductSubcategoryID = T2.ProductSubcategoryID) as T4 
       on T3.ProductID = T4.ProductID
       group by T4.ProductID, T4.ProductCategoryID) as PS
where PS.Total = ( select max(SUM_TQ)
                   from ( select T4b.ProductCategoryID, sum(T3b.OrderQty) as SUM_TQ
                          from Sales.SalesOrderDetail as T3b
                          inner join ( select T1b.ProductID, T1b.ProductSubcategoryID, T2b.ProductCategoryID
                                       from Production.Product as T1b
                                       inner join Production.ProductSubcategory as T2b
                                       on T1b.ProductSubcategoryID = T2b.ProductSubcategoryID) as T4b 
						  on T3b.ProductID = T4b.ProductID
                          where T4b.ProductCategoryID = PS.ProductCategoryID
                          group by T4b.ProductID, T4b.ProductCategoryID) as CategorySales)

--Consulta final B adventureWorks
select TerritoryID, FirstName, LastName, Compras_realizadas
from ( select T1.TerritoryID, T4.FirstName, T4.LastName, 
              count(*) as Compras_realizadas, 
			  row_number() over (partition by T1.TerritoryID order by count(*) desc) as rn
       from Sales.SalesOrderHeader as T1
       inner join Sales.Customer as T3 
	   on T1.CustomerID = T3.CustomerID
       inner join Person.Person as T4 
	   on T3.PersonID = T4.BusinessEntityID
       group by T1.TerritoryID, T3.CustomerID, T4.FirstName, T4.LastName ) as rango
where rn = 1

--Consulta final C adventureWorks
SELECT DISTINCT Salesorderid
FROM Sales.SalesOrderDetail AS OD
WHERE NOT EXISTS (SELECT *
				  FROM (select ProductID
						from Sales.SalesOrderDetail
						where salesorderid = 43676) as P
				  WHERE NOT EXISTS (SELECT *
									FROM Sales.SalesOrderDetail AS OD2
									WHERE OD.SalesOrderID = OD2.SalesOrderID
									AND OD2.ProductID = P.ProductID ))
	
---------------------------------------------------------------------------------------------------------------------

--6. Generar los planes de ejecucion de las consultas 3, 4 y 5 de la practica de consultas en la
--base de datos Covid y proponer indices para mejorar el rendimiento.

--Consulta 3: Listar el porcentaje de casos confirmados en cada una de las siguientes morbilidades 
--a nivel nacional: diabetes, obesidad e hipertensión.  [Hecho por Keb]
    
SELECT
	CAST(COUNT(IIF(DIABETES = 1, 1, Null))*100.0/COUNT(*) as DECIMAL(4,2)) as Porcentaje_DIABETES,
	CAST(COUNT(IIF(HIPERTENSION = 1, 1, Null))*100.0/COUNT(*) as DECIMAL(4,2)) as Porcentaje_Hipertension,
	CAST(COUNT(IIF(OBESIDAD= 1, 1, Null))*100.0/COUNT(*) as DECIMAL(4,2)) as Porcentaje_Obesidad
FROM datoscovid
WHERE CLASIFICACION_FINAL IN (1, 2, 3);

CREATE NONCLUSTERED INDEX INC_DC_CF_3 ON datoscovid (CLASIFICACION_FINAL) INCLUDE ([DIABETES],[HIPERTENSION],[OBESIDAD])
create clustered index IC_DC_ID_REGSTRO on datoscovid (ID_REGISTRO)
create nonclustered index INC_DC_CLASIFICACION on datoscovid (CLASIFICACION_FINAL)


--Consulta 4: Listar los municipios que no tengan casos confirmados en todas las morbilidades: 
--hipertensión, obesidad, diabetes y tabaquismo.        [Hecho por Armando]

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


CREATE NONCLUSTERED INDEX INC_DC_CF_5 ON datoscovid ([CLASIFICACION_FINAL]) INCLUDE ([MUNICIPIO_RES],[DIABETES],[HIPERTENSION],[OBESIDAD],[TABAQUISMO])


--Consulta 5: Listar los estados con más casos recuperados con neumonía.    [Hecha por Juan]

select ENTIDAD_RES, entidad, count(*) as numero_Casos --Resultados esperados
from (select ENTIDAD_UM, ENTIDAD_NAC, ENTIDAD_RES, MUNICIPIO_RES, SEXO, EDAD, FECHA_INGRESO, FECHA_DEF, NEUMONIA, DIABETES, HIPERTENSION, OBESIDAD, TABAQUISMO, CLASIFICACION_FINAL
      from (select ENTIDAD_UM, ENTIDAD_NAC, ENTIDAD_RES, MUNICIPIO_RES, SEXO, EDAD, FECHA_INGRESO, FECHA_DEF, NEUMONIA, DIABETES, HIPERTENSION, OBESIDAD, TABAQUISMO, CLASIFICACION_FINAL
            from datoscovid
            where CLASIFICACION_FINAL in ('1', '2', '3')) as A
      where CAST(left(FECHA_DEF,4) as INT) = 9999) as B	--Todos los casos recuperados
inner join cat_entidades on ENTIDAD_RES = clave
where NEUMONIA = 1	--1 Significa que si tenian neumonia
group by ENTIDAD_RES, entidad	--Agrupamos por estados

CREATE NONCLUSTERED INDEX INC_DC_NEU_CF_2 ON datoscovid ([NEUMONIA],[CLASIFICACION_FINAL]) INCLUDE ([ENTIDAD_RES],[FECHA_DEF])
create clustered index IC_CE_ENTIDAD on cat_entidades (clave)


-------------------------------------------------------------------------------------------------------------------

--7. Comparar los planes de ejecucion del punto 6 con los planes de ejecucion de otro equipo.

--8. Conclusiones por equipo argumentando la seleccion de los indices.
