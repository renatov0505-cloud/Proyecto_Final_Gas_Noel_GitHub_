/*
Proyecto: Gas Noel
Archivo : 04_vistas_gold_bi.sql

CAPA ORO: vistas analiticas listas para BI (Power BI, Excel, etc.).
Todas se construyen SOLO sobre la capa Plata (datos limpios).

Vistas:
  oro.vw_ventas_pedido        Detalle de cada pedido: total, pagado, saldo y estatus de pago
  oro.vw_cliente_360          Vista 360 del cliente: compras, pagos, saldo y servicios
  oro.vw_ventas_producto      Unidades e ingresos por producto
  oro.vw_ventas_sucursal_mes  Ventas por sucursal y mes
  oro.vw_inventario_sucursal  Existencias y valor de inventario por sucursal
  oro.vw_pagos_metodo         Participacion de cada metodo de pago
  oro.vw_desempeno_repartidor Entregas por empleado y unidad
  oro.vw_servicios            Servicios tecnicos con cliente y empleado
  oro.vw_kpi_resumen          KPIs generales del negocio (una sola fila)
*/
USE GasNoel;
GO
SET NOCOUNT ON;
GO

-- 1. Ventas por pedido
CREATE OR ALTER VIEW oro.vw_ventas_pedido AS
SELECT
    p.IdPedido,
    p.FechaPedido,
    p.Estado                                         AS EstadoPedido,
    CONCAT(c.Nombre, ' ', c.Apellido_Paterno, ' ', c.Apellido_Materno) AS Cliente,
    c.Tipo_Cliente,
    s.Sucursal,
    d.Colonia                                        AS ColoniaEntrega,
    d.Ciudad,
    t.Articulos,
    t.Total                                          AS TotalPedido,
    ISNULL(g.Pagado, 0)                              AS TotalPagado,
    t.Total - ISNULL(g.Pagado, 0)                    AS Saldo,
    CASE WHEN ISNULL(g.Pagado, 0) = 0        THEN 'Sin pago'
         WHEN ISNULL(g.Pagado, 0) < t.Total  THEN 'Pago parcial'
         ELSE 'Pagado' END                           AS EstatusPago
FROM plata.Pedido p
JOIN plata.Cliente   c ON c.IdCliente   = p.IdCliente
JOIN plata.Sucursal  s ON s.IdSucursal  = p.IdSucursal
LEFT JOIN plata.Domicilio d ON d.IdDomicilio = p.IdDomicilio
LEFT JOIN (SELECT IdPedido, SUM(Cantidad) AS Articulos, SUM(Cantidad * PrecioUnitario) AS Total
           FROM plata.DetallePedido GROUP BY IdPedido) t ON t.IdPedido = p.IdPedido
LEFT JOIN (SELECT IdPedido, SUM(Monto) AS Pagado
           FROM plata.Pago GROUP BY IdPedido) g ON g.IdPedido = p.IdPedido;
GO

-- 2. Vista 360 del cliente
CREATE OR ALTER VIEW oro.vw_cliente_360 AS
SELECT
    c.IdCliente,
    CONCAT(c.Nombre, ' ', c.Apellido_Paterno, ' ', c.Apellido_Materno) AS Cliente,
    c.Tipo_Cliente,
    c.Telefono,
    d.Colonia,
    d.Ciudad,
    ISNULL(v.Pedidos, 0)         AS NumPedidos,
    ISNULL(v.TotalComprado, 0)   AS TotalComprado,
    ISNULL(v.TotalPagado, 0)     AS TotalPagado,
    ISNULL(v.Saldo, 0)           AS SaldoPendiente,
    v.UltimoPedido,
    ISNULL(sv.NumServicios, 0)   AS NumServicios,
    ISNULL(sv.CostoServicios, 0) AS CostoServicios
FROM plata.Cliente c
LEFT JOIN plata.Domicilio d ON d.IdCliente = c.IdCliente
LEFT JOIN (SELECT Cliente_Id = IdCliente, COUNT(*) AS Pedidos, SUM(ISNULL(Total,0)) AS TotalComprado,
                  SUM(Pagado) AS TotalPagado, SUM(Saldo) AS Saldo, MAX(FechaPedido) AS UltimoPedido
           FROM (SELECT p.IdCliente, p.FechaPedido, t.Total, ISNULL(g.Pagado,0) AS Pagado, ISNULL(t.Total,0) - ISNULL(g.Pagado,0) AS Saldo
                 FROM plata.Pedido p
                 LEFT JOIN (SELECT IdPedido, SUM(Cantidad*PrecioUnitario) AS Total FROM plata.DetallePedido GROUP BY IdPedido) t ON t.IdPedido = p.IdPedido
                 LEFT JOIN (SELECT IdPedido, SUM(Monto) AS Pagado FROM plata.Pago GROUP BY IdPedido) g ON g.IdPedido = p.IdPedido) x
           GROUP BY IdCliente) v ON v.Cliente_Id = c.IdCliente
LEFT JOIN (SELECT IdCliente, COUNT(*) AS NumServicios, SUM(Costo) AS CostoServicios
           FROM plata.Servicio GROUP BY IdCliente) sv ON sv.IdCliente = c.IdCliente;
GO

-- 3. Ventas por producto
CREATE OR ALTER VIEW oro.vw_ventas_producto AS
SELECT
    pr.IdProducto,
    pr.Producto,
    pr.Precio                          AS PrecioCatalogo,
    ISNULL(SUM(d.Cantidad), 0)         AS UnidadesVendidas,
    ISNULL(SUM(d.Cantidad * d.PrecioUnitario), 0) AS Ingreso,
    COUNT(DISTINCT d.IdPedido)         AS PedidosConProducto
FROM plata.Producto pr
LEFT JOIN plata.DetallePedido d ON d.IdProducto = pr.IdProducto
GROUP BY pr.IdProducto, pr.Producto, pr.Precio;
GO

-- 4. Ventas por sucursal y mes
CREATE OR ALTER VIEW oro.vw_ventas_sucursal_mes AS
SELECT
    s.Sucursal,
    YEAR(p.FechaPedido)  AS Anio,
    MONTH(p.FechaPedido) AS Mes,
    COUNT(DISTINCT p.IdPedido)                 AS Pedidos,
    SUM(d.Cantidad * d.PrecioUnitario)         AS Ventas
FROM plata.Pedido p
JOIN plata.Sucursal s ON s.IdSucursal = p.IdSucursal
LEFT JOIN plata.DetallePedido d ON d.IdPedido = p.IdPedido
GROUP BY s.Sucursal, YEAR(p.FechaPedido), MONTH(p.FechaPedido);
GO

-- 5. Inventario por sucursal
CREATE OR ALTER VIEW oro.vw_inventario_sucursal AS
SELECT
    s.Sucursal,
    pr.Producto,
    i.Existencia,
    pr.Precio,
    i.Existencia * pr.Precio AS ValorInventario
FROM plata.Inventario i
JOIN plata.Sucursal s  ON s.IdSucursal  = i.IdSucursal
JOIN plata.Producto pr ON pr.IdProducto = i.IdProducto;
GO

-- 6. Metodos de pago
CREATE OR ALTER VIEW oro.vw_pagos_metodo AS
SELECT
    m.Metodo,
    COUNT(g.IdPago)              AS NumPagos,
    ISNULL(SUM(g.Monto), 0)      AS MontoTotal,
    CAST(100.0 * ISNULL(SUM(g.Monto), 0) / NULLIF(SUM(SUM(g.Monto)) OVER (), 0) AS decimal(5,2)) AS PctMonto
FROM plata.MetodoPago m
LEFT JOIN plata.Pago g ON g.IdMetodoPago = m.IdMetodoPago
GROUP BY m.Metodo;
GO

-- 7. Desempeno de repartidores
CREATE OR ALTER VIEW oro.vw_desempeno_repartidor AS
SELECT
    CONCAT(e.Nombre, ' ', e.Apellido_Paterno) AS Empleado,
    e.Puesto,
    s.Sucursal,
    u.Placas,
    u.Tipo                                   AS TipoUnidad,
    COUNT(en.IdEntrega)                      AS Entregas,
    MIN(en.FechaEntrega)                     AS PrimeraEntrega,
    MAX(en.FechaEntrega)                     AS UltimaEntrega
FROM plata.Entrega en
JOIN plata.Empleado e  ON e.IdEmpleado = en.IdEmpleado
JOIN plata.Sucursal s  ON s.IdSucursal = e.IdSucursal
JOIN plata.Unidad   u  ON u.IdUnidad   = en.IdUnidad
GROUP BY e.Nombre, e.Apellido_Paterno, e.Puesto, s.Sucursal, u.Placas, u.Tipo;
GO

-- 8. Servicios tecnicos
CREATE OR ALTER VIEW oro.vw_servicios AS
SELECT
    sv.IdServicio,
    sv.FechaServicio,
    sv.Descripcion,
    sv.Costo,
    CONCAT(c.Nombre, ' ', c.Apellido_Paterno) AS Cliente,
    CONCAT(e.Nombre, ' ', e.Apellido_Paterno) AS Tecnico
FROM plata.Servicio sv
JOIN plata.Cliente  c ON c.IdCliente  = sv.IdCliente
JOIN plata.Empleado e ON e.IdEmpleado = sv.IdEmpleado;
GO

-- 9. KPIs generales (una fila)
CREATE OR ALTER VIEW oro.vw_kpi_resumen AS
SELECT
    COUNT(*)                                                   AS TotalPedidos,
    SUM(CASE WHEN EstadoPedido = 'Entregado' THEN 1 ELSE 0 END) AS PedidosEntregados,
    SUM(CASE WHEN EstadoPedido = 'Pendiente' THEN 1 ELSE 0 END) AS PedidosPendientes,
    SUM(ISNULL(TotalPedido, 0))                                AS VentasTotales,
    SUM(TotalPagado)                                           AS CobradoTotal,
    SUM(Saldo)                                                 AS CuentasPorCobrar,
    CAST(AVG(TotalPedido) AS decimal(12,2))                    AS TicketPromedio,
    CAST(100.0 * SUM(TotalPagado) / NULLIF(SUM(TotalPedido), 0) AS decimal(5,2)) AS PctCobranza,
    (SELECT ISNULL(SUM(Costo), 0) FROM plata.Servicio)         AS IngresosServicios,
    (SELECT COUNT(*) FROM plata.Cliente)                       AS TotalClientes
FROM oro.vw_ventas_pedido;
GO
