-- Crear base de datos
CREATE DATABASE practicaPE;
GO

-- Copiar tablas desde AdventureWorks
USE practicaPE;
GO
-- Para Consulta 3a (Productos m�s vendidos)
CREATE INDEX IX_ProductSubcategory_ProductCategoryID ON Production.ProductSubcategory(ProductCategoryID);
CREATE INDEX IX_Product_ProductSubcategoryID ON Production.Product(ProductSubcategoryID);
CREATE INDEX IX_SalesOrderDetail_ProductID ON Sales.SalesOrderDetail(ProductID);

-- Para Consulta 3b (Clientes con m�s �rdenes)
CREATE INDEX IX_SalesOrderHeader_TerritoryID_CustomerID ON Sales.SalesOrderHeader(TerritoryID, CustomerID);
CREATE INDEX IX_Customer_PersonID ON Sales.Customer(PersonID);

-- Para Consulta 3c (�rdenes con mismos productos)
CREATE INDEX IX_SalesOrderDetail_SalesOrderID_ProductID ON Sales.SalesOrderDetail(SalesOrderID, ProductID);