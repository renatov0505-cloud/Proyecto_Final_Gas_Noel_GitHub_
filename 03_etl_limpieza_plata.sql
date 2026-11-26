
      
-- PLATA: limpieza basica (espacios y mayusculas)
SELECT IdCliente,
       UPPER(LEFT(TRIM(Nombre),1)) + LOWER(SUBSTRING(TRIM(Nombre),2,60)) AS Nombre,
       TRIM(Apellido_Paterno) AS Apellido_Paterno,
       TRIM(Apellido_Materno) AS Apellido_Materno,
       Telefono,
       Tipo_Cliente
INTO silver.Cliente
FROM bronze.Cliente;

SELECT IdPedido, IdCliente, FechaPedido,
       UPPER(LEFT(TRIM(Estado),1)) + LOWER(SUBSTRING(TRIM(Estado),2,15)) AS Estado
INTO silver.Pedido
FROM bronze.Pedido;

SELECT IdPedido, Cantidad * PrecioUnitario AS Subtotal
INTO silver.DetallePedido
FROM bronze.DetallePedido;

SELECT IdPedido, Monto
INTO silver.Pago
FROM bronze.Pago;

SELECT IdCliente, Costo
INTO silver.Servicio
FROM bronze.Servicio;
