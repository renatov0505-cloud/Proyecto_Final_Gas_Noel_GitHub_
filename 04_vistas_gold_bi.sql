
-- ORO: una fila por cliente
SELECT c.IdCliente,
       c.Nombre + ' ' + c.Apellido_Paterno AS Cliente,
       c.Tipo_Cliente,
       COUNT(DISTINCT p.IdPedido)                       AS TotalPedidos,
       ISNULL(SUM(d.Subtotal), 0)                       AS TotalComprado,
       ISNULL((SELECT SUM(pg.Monto)
               FROM silver.Pago pg
               JOIN silver.Pedido p2 ON p2.IdPedido = pg.IdPedido
               WHERE p2.IdCliente = c.IdCliente), 0)    AS TotalPagado,
       ISNULL((SELECT SUM(Costo)
               FROM silver.Servicio s
               WHERE s.IdCliente = c.IdCliente), 0)     AS TotalServicios,
       MAX(p.FechaPedido)                               AS UltimoPedido
INTO gold.Customer360
FROM silver.Cliente c
LEFT JOIN silver.Pedido p        ON p.IdCliente = c.IdCliente
LEFT JOIN silver.DetallePedido d ON d.IdPedido  = p.IdPedido
GROUP BY c.IdCliente, c.Nombre, c.Apellido_Paterno, c.Tipo_Cliente;

SELECT * FROM gold.Customer360;
