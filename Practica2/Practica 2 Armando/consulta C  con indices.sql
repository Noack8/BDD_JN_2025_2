WITH ProductosOrden43676 AS (
    SELECT DISTINCT ProductID
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = 43676
),
OrdenesConTodosProductos AS (
    SELECT sod.SalesOrderID
    FROM Sales.SalesOrderDetail sod
    JOIN ProductosOrden43676 p ON sod.ProductID = p.ProductID
    GROUP BY sod.SalesOrderID
    HAVING COUNT(DISTINCT sod.ProductID) = (SELECT COUNT(*) FROM ProductosOrden43676)
)
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN OrdenesConTodosProductos otp ON soh.SalesOrderID = otp.SalesOrderID;