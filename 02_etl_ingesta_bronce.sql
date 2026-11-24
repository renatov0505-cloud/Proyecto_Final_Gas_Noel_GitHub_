/*
Proyecto: Gas Noel
Archivo : 02_etl_ingesta_bronce.sql

CAPA BRONCE: ingesta de los datos de la fuente (dbo) hacia bronce.*
- Copia fiel: NO se limpia nada (se conservan espacios, mayusculas raras, etc.).
- Todo se guarda como texto y se agregan metadatos (_fecha_carga, _origen).
- Carga completa (full load): TRUNCATE + INSERT en cada ejecucion.
*/
IF DB_ID('GasNoel') IS NULL CREATE DATABASE GasNoel;
GO
USE GasNoel;
GO
SET NOCOUNT ON;
GO

CREATE OR ALTER PROCEDURE bronce.usp_cargar_bronce
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        TRUNCATE TABLE bronce.Sucursal;
        INSERT INTO bronce.Sucursal (IdSucursal, Sucursal, Calle, Colonia, Telefono)
        SELECT CONVERT(varchar(20), IdSucursal),
                CAST(Sucursal AS varchar(255)),
                CAST(Calle AS varchar(255)),
                CAST(Colonia AS varchar(255)),
                CAST(Telefono AS varchar(255))
        FROM dbo.Sucursal;

        TRUNCATE TABLE bronce.Cliente;
        INSERT INTO bronce.Cliente (IdCliente, Nombre, Apellido_Paterno, Apellido_Materno, Telefono, Tipo_Cliente)
        SELECT CONVERT(varchar(20), IdCliente),
                CAST(Nombre AS varchar(255)),
                CAST(Apellido_Paterno AS varchar(255)),
                CAST(Apellido_Materno AS varchar(255)),
                CAST(Telefono AS varchar(255)),
                CAST(Tipo_Cliente AS varchar(255))
        FROM dbo.Cliente;

        TRUNCATE TABLE bronce.Domicilio;
        INSERT INTO bronce.Domicilio (IdDomicilio, IdCliente, Calle, NumeroExt, Colonia, Ciudad)
        SELECT CONVERT(varchar(20), IdDomicilio),
                CONVERT(varchar(20), IdCliente),
                CAST(Calle AS varchar(255)),
                CAST(NumeroExt AS varchar(255)),
                CAST(Colonia AS varchar(255)),
                CAST(Ciudad AS varchar(255))
        FROM dbo.Domicilio;

        TRUNCATE TABLE bronce.Producto;
        INSERT INTO bronce.Producto (IdProducto, Producto, Precio)
        SELECT CONVERT(varchar(20), IdProducto),
                CAST(Producto AS varchar(255)),
                CONVERT(varchar(20), Precio)
        FROM dbo.Producto;

        TRUNCATE TABLE bronce.Inventario;
        INSERT INTO bronce.Inventario (IdInventario, IdSucursal, IdProducto, Existencia)
        SELECT CONVERT(varchar(20), IdInventario),
                CONVERT(varchar(20), IdSucursal),
                CONVERT(varchar(20), IdProducto),
                CONVERT(varchar(20), Existencia)
        FROM dbo.Inventario;

        TRUNCATE TABLE bronce.Empleado;
        INSERT INTO bronce.Empleado (IdEmpleado, Nombre, Apellido_Paterno, Apellido_Materno, Puesto, IdSucursal)
        SELECT CONVERT(varchar(20), IdEmpleado),
                CAST(Nombre AS varchar(255)),
                CAST(Apellido_Paterno AS varchar(255)),
                CAST(Apellido_Materno AS varchar(255)),
                CAST(Puesto AS varchar(255)),
                CONVERT(varchar(20), IdSucursal)
        FROM dbo.Empleado;

        TRUNCATE TABLE bronce.Unidad;
        INSERT INTO bronce.Unidad (IdUnidad, Placas, Tipo, IdSucursal)
        SELECT CONVERT(varchar(20), IdUnidad),
                CAST(Placas AS varchar(255)),
                CAST(Tipo AS varchar(255)),
                CONVERT(varchar(20), IdSucursal)
        FROM dbo.Unidad;

        TRUNCATE TABLE bronce.MetodoPago;
        INSERT INTO bronce.MetodoPago (IdMetodoPago, Metodo)
        SELECT CONVERT(varchar(20), IdMetodoPago),
                CAST(Metodo AS varchar(255))
        FROM dbo.MetodoPago;

        TRUNCATE TABLE bronce.Pedido;
        INSERT INTO bronce.Pedido (IdPedido, IdCliente, IdDomicilio, IdSucursal, FechaPedido, Estado)
        SELECT CONVERT(varchar(20), IdPedido),
                CONVERT(varchar(20), IdCliente),
                CONVERT(varchar(20), IdDomicilio),
                CONVERT(varchar(20), IdSucursal),
                CONVERT(varchar(10), FechaPedido, 23),
                CAST(Estado AS varchar(255))
        FROM dbo.Pedido;

        TRUNCATE TABLE bronce.DetallePedido;
        INSERT INTO bronce.DetallePedido (IdDetalle, IdPedido, IdProducto, Cantidad, PrecioUnitario)
        SELECT CONVERT(varchar(20), IdDetalle),
                CONVERT(varchar(20), IdPedido),
                CONVERT(varchar(20), IdProducto),
                CONVERT(varchar(20), Cantidad),
                CONVERT(varchar(20), PrecioUnitario)
        FROM dbo.DetallePedido;

        TRUNCATE TABLE bronce.Entrega;
        INSERT INTO bronce.Entrega (IdEntrega, IdPedido, IdEmpleado, IdUnidad, FechaEntrega, Estado)
        SELECT CONVERT(varchar(20), IdEntrega),
                CONVERT(varchar(20), IdPedido),
                CONVERT(varchar(20), IdEmpleado),
                CONVERT(varchar(20), IdUnidad),
                CONVERT(varchar(10), FechaEntrega, 23),
                CAST(Estado AS varchar(255))
        FROM dbo.Entrega;

        TRUNCATE TABLE bronce.Pago;
        INSERT INTO bronce.Pago (IdPago, IdPedido, IdMetodoPago, Monto, FechaPago)
        SELECT CONVERT(varchar(20), IdPago),
                CONVERT(varchar(20), IdPedido),
                CONVERT(varchar(20), IdMetodoPago),
                CONVERT(varchar(20), Monto),
                CONVERT(varchar(10), FechaPago, 23)
        FROM dbo.Pago;

        TRUNCATE TABLE bronce.Servicio;
        INSERT INTO bronce.Servicio (IdServicio, IdCliente, IdEmpleado, Descripcion, FechaServicio, Costo)
        SELECT CONVERT(varchar(20), IdServicio),
                CONVERT(varchar(20), IdCliente),
                CONVERT(varchar(20), IdEmpleado),
                CAST(Descripcion AS varchar(255)),
                CONVERT(varchar(10), FechaServicio, 23),
                CONVERT(varchar(20), Costo)
        FROM dbo.Servicio;

        COMMIT TRAN;
        PRINT 'Bronce cargada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO
