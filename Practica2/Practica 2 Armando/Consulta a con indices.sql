WITH VentasPorProducto AS (
    SELECT 
        pc.Name AS Categoria,
        p.ProductID,
        p.Name AS Producto,
        SUM(sod.OrderQty) AS CantidadVendida,
        RANK() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.OrderQty) DESC) AS Ranking
    FROM Production.ProductCategory pc
    JOIN Production.ProductSubcategory ps ON pc.ProductCategoryID = ps.ProductCategoryID
    JOIN Production.Product p ON ps.ProductSubcategoryID = p.ProductSubcategoryID
    JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
    GROUP BY pc.Name, p.ProductID, p.Name
)
SELECT Categoria, Producto, CantidadVendida
FROM VentasPorProducto
WHERE Ranking = 1;