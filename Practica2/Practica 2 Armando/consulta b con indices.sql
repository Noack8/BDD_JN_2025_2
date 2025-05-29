WITH OrdenesPorCliente AS (
    SELECT 
        st.Name AS Territorio,
        c.CustomerID,
        p.FirstName + ' ' + p.LastName AS NombreCliente,
        COUNT(soh.SalesOrderID) AS NumeroOrdenes,
        RANK() OVER (PARTITION BY st.Name ORDER BY COUNT(soh.SalesOrderID) DESC) AS Ranking
    FROM Sales.SalesTerritory st
    JOIN Sales.SalesOrderHeader soh ON st.TerritoryID = soh.TerritoryID
    JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    GROUP BY st.Name, c.CustomerID, p.FirstName, p.LastName
)
SELECT Territorio, NombreCliente, NumeroOrdenes
FROM OrdenesPorCliente
WHERE Ranking = 1;