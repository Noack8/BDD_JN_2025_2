USE practicaPE; -- Asegúrate de usar la base correcta
GO
-- Para consulta 3a (Producto más vendido por categoría)
CREATE INDEX IX_ProductSubcategory_ProductCategoryID ON Production.ProductSubcategory(ProductCategoryID);
CREATE INDEX IX_Product_ProductSubcategoryID ON Production.Product(ProductSubcategoryID);
CREATE INDEX IX_SalesOrderDetail_ProductID ON Sales.SalesOrderDetail(ProductID);

-- Para consulta 3b (Clientes con más órdenes por territorio)
CREATE INDEX IX_SalesOrderHeader_TerritoryID_CustomerID ON Sales.SalesOrderHeader(TerritoryID, CustomerID);
CREATE INDEX IX_Customer_PersonID ON Sales.Customer(PersonID);

-- Para consulta 3c (Órdenes con mismos productos que 43676)
CREATE INDEX IX_SalesOrderDetail_SalesOrderID_ProductID ON Sales.SalesOrderDetail(SalesOrderID, ProductID);
-- Crear base de datos
CREATE DATABASE practicaPE;
GO

-- Copiar tablas desde AdventureWorks
USE practicaPE;
GO

-- Crear esquemas necesarios
CREATE SCHEMA Sales;
CREATE SCHEMA Production;
CREATE SCHEMA Person;
GO

-- Copiar tablas en orden de dependencias
SELECT * INTO Sales.SalesTerritory FROM AdventureWorks2022.Sales.SalesTerritory;
SELECT * INTO Production.ProductCategory FROM AdventureWorks2022.Production.ProductCategory;
SELECT * INTO Person.Person FROM AdventureWorks2022.Person.Person;
SELECT * INTO Production.ProductSubcategory FROM AdventureWorks2022.Production.ProductSubcategory;
SELECT * INTO Sales.Customer FROM AdventureWorks2022.Sales.Customer;
SELECT * INTO Production.Product FROM AdventureWorks2022.Production.Product;
SELECT * INTO Sales.SalesOrderHeader FROM AdventureWorks2022.Sales.SalesOrderHeader;
SELECT * INTO Sales.SalesOrderDetail FROM AdventureWorks2022.Sales.SalesOrderDetail;