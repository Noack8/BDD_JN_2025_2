go
-- MODIFICAR SI TIENE OTRO NOMBRE SU BD
use AdventureWorks2022
go
create database practicaPE
go
select * into practicaPE.dbo.SalesOrderHeader from Sales.SalesOrderHeader;
select * into practicaPE.dbo.SalesOrderDetail from Sales.SalesOrderDetail;
select * into practicaPE.dbo.Customer from Sales.Customer;
select * into practicaPE.dbo.SalesTerritory from Sales.SalesTerritory;
select * into practicaPE.dbo.Product from Production.Product;
select * into practicaPE.dbo.ProductCategory from Production.ProductCategory;
select * into practicaPE.dbo.ProductSubcategory from Production.ProductSubcategory;
select 
	BusinessEntityID,
	PersonType,
	NameStyle,
	Title,
	FirstName,
	MiddleName,
	LastName,
	Suffix,
	EmailPromotion,
	CONVERT(xml, AdditionalContactInfo) as AdditionalContactInfo,
	convert(xml, demographics) as Demographics,
	rowguid,
	ModifiedDate
into practicaPE.dbo.Person
from Person.Person;
