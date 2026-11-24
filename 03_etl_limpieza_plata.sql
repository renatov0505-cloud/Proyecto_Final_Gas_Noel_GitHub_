/*
Proyecto: Gas Noel
Archivo : 03_etl_limpieza_plata.sql

CAPA PLATA: limpieza, estandarizacion, deduplicacion y reglas de calidad.

Reglas de limpieza aplicadas:
  R1. Quitar espacios al inicio/fin y colapsar espacios dobles.
  R2. Estandarizar mayusculas: nombres/calles/colonias en formato Nombre Propio
      (articulos 'de', 'del', 'la'... en minuscula); catalogos y estados en formato oracion.
  R3. Placas en MAYUSCULAS.
  R4. Telefonos: solo digitos, validar 10 digitos (si no, NULL y se registra).
  R5. Ciudad: 'Leon de los Aldama' y variantes -> 'León'.
  R6. Conversion de tipos con TRY_CAST (valores invalidos -> NULL, fila sin llave se descarta).
  R7. Deduplicacion por llave primaria (se conserva la carga mas reciente).
  R8. Integridad referencial: filas con FK huerfana se rechazan y se registran.
  R9. Reglas de negocio validadas en plata.usp_validar_calidad (resultado en plata.log_calidad).
*/
IF DB_ID('GasNoel') IS NULL CREATE DATABASE GasNoel;
GO
USE GasNoel;
GO
SET NOCOUNT ON;
GO

-- ---------- Funciones de limpieza ----------
CREATE OR ALTER FUNCTION plata.fn_limpiar (@texto NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @r NVARCHAR(255) = LTRIM(RTRIM(@texto));
    WHILE CHARINDEX(N'  ', @r) > 0 SET @r = REPLACE(@r, N'  ', N' ');
    RETURN NULLIF(@r, N'');
END;
GO

CREATE OR ALTER FUNCTION plata.fn_oracion (@texto NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @s NVARCHAR(255) = LOWER(plata.fn_limpiar(@texto));
    IF @s IS NULL RETURN NULL;
    RETURN UPPER(LEFT(@s, 1)) + SUBSTRING(@s, 2, 255);
END;
GO

CREATE OR ALTER FUNCTION plata.fn_nombre_propio (@texto NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @s NVARCHAR(255) = LOWER(plata.fn_limpiar(@texto));
    IF @s IS NULL RETURN NULL;
    DECLARE @i INT = 1, @n INT = LEN(@s), @r NVARCHAR(255) = N'', @c NCHAR(1), @prev NCHAR(1) = N' ';
    WHILE @i <= @n
    BEGIN
        SET @c = SUBSTRING(@s, @i, 1);
        IF @prev = N' ' SET @c = UPPER(@c);
        SET @r = @r + @c;
        SET @prev = SUBSTRING(@s, @i, 1);
        SET @i += 1;
    END;
    -- Articulos y preposiciones en minuscula
    SET @r = REPLACE(@r, N' De ',  N' de ');
    SET @r = REPLACE(@r, N' Del ', N' del ');
    SET @r = REPLACE(@r, N' La ',  N' la ');
    SET @r = REPLACE(@r, N' Las ', N' las ');
    SET @r = REPLACE(@r, N' Los ', N' los ');
    SET @r = REPLACE(@r, N' El ',  N' el ');
    SET @r = REPLACE(@r, N' Y ',   N' y ');
    RETURN @r;
END;
GO

CREATE OR ALTER FUNCTION plata.fn_telefono (@texto NVARCHAR(255))
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @t NVARCHAR(255) = @texto;
    SET @t = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@t, N' ', N''), N'-', N''), N'(', N''), N')', N''), N'.', N''), N'+', N'');
    IF @t IS NULL OR LEN(@t) <> 10 OR @t LIKE N'%[^0-9]%' RETURN NULL;
    RETURN @t;
END;
GO

CREATE OR ALTER FUNCTION plata.fn_ciudad (@texto NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @s NVARCHAR(255) = plata.fn_limpiar(@texto);
    IF @s IS NULL RETURN NULL;
    IF @s LIKE N'le_n%' RETURN N'León';
    RETURN plata.fn_nombre_propio(@s);
END;
GO

-- ---------- Validacion de calidad ----------
CREATE OR ALTER PROCEDURE plata.usp_validar_calidad
AS
BEGIN
    SET NOCOUNT ON;

    -- V1. Filas rechazadas (bronce vs plata)
    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Sucursal', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Sucursal) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Sucursal) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Cliente', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Cliente) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Cliente) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Domicilio', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Domicilio) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Domicilio) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Producto', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Producto) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Producto) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Inventario', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Inventario) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Inventario) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Empleado', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Empleado) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Empleado) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Unidad', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Unidad) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Unidad) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'MetodoPago', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.MetodoPago) b CROSS JOIN (SELECT COUNT(*) c FROM plata.MetodoPago) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Pedido', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Pedido) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Pedido) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'DetallePedido', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.DetallePedido) b CROSS JOIN (SELECT COUNT(*) c FROM plata.DetallePedido) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Entrega', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Entrega) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Entrega) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Pago', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Pago) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Pago) p
    WHERE b.c <> p.c;

    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Servicio', 'Filas rechazadas', CONCAT('Bronce=', b.c, ' Plata=', p.c)
    FROM (SELECT COUNT(*) c FROM bronce.Servicio) b CROSS JOIN (SELECT COUNT(*) c FROM plata.Servicio) p
    WHERE b.c <> p.c;

    -- V2. Telefonos invalidos (no cumplen 10 digitos)
    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Cliente', 'Telefono invalido', CONCAT('IdCliente ', IdCliente) FROM plata.Cliente WHERE Telefono IS NULL;
    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Sucursal', 'Telefono invalido', CONCAT('IdSucursal ', IdSucursal) FROM plata.Sucursal WHERE Telefono IS NULL;

    -- V3. Pedidos entregados sin registro de entrega
    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Pedido', 'Entregado sin entrega', CONCAT('IdPedido ', p.IdPedido)
    FROM plata.Pedido p
    WHERE p.Estado = 'Entregado' AND NOT EXISTS (SELECT 1 FROM plata.Entrega e WHERE e.IdPedido = p.IdPedido);

    -- V4. Pedidos con saldo pendiente (pagado < total)
    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Pedido', 'Saldo pendiente', CONCAT('IdPedido ', p.IdPedido, ': total ', t.Total, ', pagado ', ISNULL(g.Pagado, 0))
    FROM plata.Pedido p
    JOIN (SELECT IdPedido, SUM(Cantidad * PrecioUnitario) Total FROM plata.DetallePedido GROUP BY IdPedido) t ON t.IdPedido = p.IdPedido
    LEFT JOIN (SELECT IdPedido, SUM(Monto) Pagado FROM plata.Pago GROUP BY IdPedido) g ON g.IdPedido = p.IdPedido
    WHERE ISNULL(g.Pagado, 0) < t.Total;

    -- V5. Precio del detalle distinto al precio de catalogo
    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'DetallePedido', 'Precio distinto al catalogo', CONCAT('IdDetalle ', d.IdDetalle)
    FROM plata.DetallePedido d JOIN plata.Producto pr ON pr.IdProducto = d.IdProducto
    WHERE d.PrecioUnitario <> pr.Precio;

    -- V6. Inventario duplicado por sucursal-producto
    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Inventario', 'Duplicado sucursal-producto', CONCAT('IdSucursal ', IdSucursal, ', IdProducto ', IdProducto)
    FROM plata.Inventario GROUP BY IdSucursal, IdProducto HAVING COUNT(*) > 1;

    -- V7. Pago anterior a la fecha del pedido
    INSERT INTO plata.log_calidad (Tabla, Regla, Detalle)
    SELECT 'Pago', 'Pago antes del pedido', CONCAT('IdPago ', g.IdPago)
    FROM plata.Pago g JOIN plata.Pedido p ON p.IdPedido = g.IdPedido
    WHERE g.FechaPago < p.FechaPedido;
END;
GO

-- ---------- Carga principal de Plata ----------
CREATE OR ALTER PROCEDURE plata.usp_cargar_plata
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE plata.log_calidad;
    BEGIN TRY
        BEGIN TRAN;

        -- Vaciar en orden inverso a las FK
        DELETE FROM plata.Servicio;
        DELETE FROM plata.Pago;
        DELETE FROM plata.Entrega;
        DELETE FROM plata.DetallePedido;
        DELETE FROM plata.Pedido;
        DELETE FROM plata.MetodoPago;
        DELETE FROM plata.Unidad;
        DELETE FROM plata.Empleado;
        DELETE FROM plata.Inventario;
        DELETE FROM plata.Producto;
        DELETE FROM plata.Domicilio;
        DELETE FROM plata.Cliente;
        DELETE FROM plata.Sucursal;

        -- Sucursal
        INSERT INTO plata.Sucursal (IdSucursal, Sucursal, Calle, Colonia, Telefono)
        SELECT TRY_CAST(IdSucursal AS int),
               plata.fn_nombre_propio(Sucursal),
               plata.fn_nombre_propio(Calle),
               plata.fn_nombre_propio(Colonia),
               plata.fn_telefono(Telefono)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdSucursal AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Sucursal
            WHERE TRY_CAST(IdSucursal AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1;

        -- Cliente
        INSERT INTO plata.Cliente (IdCliente, Nombre, Apellido_Paterno, Apellido_Materno, Telefono, Tipo_Cliente)
        SELECT TRY_CAST(IdCliente AS int),
               plata.fn_nombre_propio(Nombre),
               plata.fn_nombre_propio(Apellido_Paterno),
               plata.fn_nombre_propio(Apellido_Materno),
               plata.fn_telefono(Telefono),
               plata.fn_oracion(Tipo_Cliente)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdCliente AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Cliente
            WHERE TRY_CAST(IdCliente AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1;

        -- Domicilio
        INSERT INTO plata.Domicilio (IdDomicilio, IdCliente, Calle, NumeroExt, Colonia, Ciudad)
        SELECT TRY_CAST(IdDomicilio AS int),
               TRY_CAST(IdCliente AS int),
               plata.fn_nombre_propio(Calle),
               plata.fn_limpiar(NumeroExt),
               plata.fn_nombre_propio(Colonia),
               plata.fn_ciudad(Ciudad)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdDomicilio AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Domicilio
            WHERE TRY_CAST(IdDomicilio AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1
          AND EXISTS (SELECT 1 FROM plata.Cliente x WHERE x.IdCliente = TRY_CAST(b.IdCliente AS int));

        -- Producto
        INSERT INTO plata.Producto (IdProducto, Producto, Precio)
        SELECT TRY_CAST(IdProducto AS int),
               plata.fn_oracion(Producto),
               TRY_CAST(Precio AS decimal(10,2))
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdProducto AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Producto
            WHERE TRY_CAST(IdProducto AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1;

        -- Inventario
        INSERT INTO plata.Inventario (IdInventario, IdSucursal, IdProducto, Existencia)
        SELECT TRY_CAST(IdInventario AS int),
               TRY_CAST(IdSucursal AS int),
               TRY_CAST(IdProducto AS int),
               TRY_CAST(Existencia AS int)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdInventario AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Inventario
            WHERE TRY_CAST(IdInventario AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1
          AND EXISTS (SELECT 1 FROM plata.Sucursal x WHERE x.IdSucursal = TRY_CAST(b.IdSucursal AS int))
          AND EXISTS (SELECT 1 FROM plata.Producto x WHERE x.IdProducto = TRY_CAST(b.IdProducto AS int));

        -- Empleado
        INSERT INTO plata.Empleado (IdEmpleado, Nombre, Apellido_Paterno, Apellido_Materno, Puesto, IdSucursal)
        SELECT TRY_CAST(IdEmpleado AS int),
               plata.fn_nombre_propio(Nombre),
               plata.fn_nombre_propio(Apellido_Paterno),
               plata.fn_nombre_propio(Apellido_Materno),
               plata.fn_oracion(Puesto),
               TRY_CAST(IdSucursal AS int)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdEmpleado AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Empleado
            WHERE TRY_CAST(IdEmpleado AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1
          AND EXISTS (SELECT 1 FROM plata.Sucursal x WHERE x.IdSucursal = TRY_CAST(b.IdSucursal AS int));

        -- Unidad
        INSERT INTO plata.Unidad (IdUnidad, Placas, Tipo, IdSucursal)
        SELECT TRY_CAST(IdUnidad AS int),
               UPPER(plata.fn_limpiar(Placas)),
               plata.fn_oracion(Tipo),
               TRY_CAST(IdSucursal AS int)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdUnidad AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Unidad
            WHERE TRY_CAST(IdUnidad AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1
          AND EXISTS (SELECT 1 FROM plata.Sucursal x WHERE x.IdSucursal = TRY_CAST(b.IdSucursal AS int));

        -- MetodoPago
        INSERT INTO plata.MetodoPago (IdMetodoPago, Metodo)
        SELECT TRY_CAST(IdMetodoPago AS int),
               plata.fn_oracion(Metodo)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdMetodoPago AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.MetodoPago
            WHERE TRY_CAST(IdMetodoPago AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1;

        -- Pedido
        INSERT INTO plata.Pedido (IdPedido, IdCliente, IdDomicilio, IdSucursal, FechaPedido, Estado)
        SELECT TRY_CAST(IdPedido AS int),
               TRY_CAST(IdCliente AS int),
               TRY_CAST(IdDomicilio AS int),
               TRY_CAST(IdSucursal AS int),
               TRY_CAST(FechaPedido AS date),
               plata.fn_oracion(Estado)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdPedido AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Pedido
            WHERE TRY_CAST(IdPedido AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1
          AND EXISTS (SELECT 1 FROM plata.Cliente x WHERE x.IdCliente = TRY_CAST(b.IdCliente AS int))
          AND EXISTS (SELECT 1 FROM plata.Domicilio x WHERE x.IdDomicilio = TRY_CAST(b.IdDomicilio AS int))
          AND EXISTS (SELECT 1 FROM plata.Sucursal x WHERE x.IdSucursal = TRY_CAST(b.IdSucursal AS int));

        -- DetallePedido
        INSERT INTO plata.DetallePedido (IdDetalle, IdPedido, IdProducto, Cantidad, PrecioUnitario)
        SELECT TRY_CAST(IdDetalle AS int),
               TRY_CAST(IdPedido AS int),
               TRY_CAST(IdProducto AS int),
               TRY_CAST(Cantidad AS int),
               TRY_CAST(PrecioUnitario AS decimal(10,2))
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdDetalle AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.DetallePedido
            WHERE TRY_CAST(IdDetalle AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1
          AND EXISTS (SELECT 1 FROM plata.Pedido x WHERE x.IdPedido = TRY_CAST(b.IdPedido AS int))
          AND EXISTS (SELECT 1 FROM plata.Producto x WHERE x.IdProducto = TRY_CAST(b.IdProducto AS int));

        -- Entrega
        INSERT INTO plata.Entrega (IdEntrega, IdPedido, IdEmpleado, IdUnidad, FechaEntrega, Estado)
        SELECT TRY_CAST(IdEntrega AS int),
               TRY_CAST(IdPedido AS int),
               TRY_CAST(IdEmpleado AS int),
               TRY_CAST(IdUnidad AS int),
               TRY_CAST(FechaEntrega AS date),
               plata.fn_oracion(Estado)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdEntrega AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Entrega
            WHERE TRY_CAST(IdEntrega AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1
          AND EXISTS (SELECT 1 FROM plata.Pedido x WHERE x.IdPedido = TRY_CAST(b.IdPedido AS int))
          AND EXISTS (SELECT 1 FROM plata.Empleado x WHERE x.IdEmpleado = TRY_CAST(b.IdEmpleado AS int))
          AND EXISTS (SELECT 1 FROM plata.Unidad x WHERE x.IdUnidad = TRY_CAST(b.IdUnidad AS int));

        -- Pago
        INSERT INTO plata.Pago (IdPago, IdPedido, IdMetodoPago, Monto, FechaPago)
        SELECT TRY_CAST(IdPago AS int),
               TRY_CAST(IdPedido AS int),
               TRY_CAST(IdMetodoPago AS int),
               TRY_CAST(Monto AS decimal(10,2)),
               TRY_CAST(FechaPago AS date)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdPago AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Pago
            WHERE TRY_CAST(IdPago AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1
          AND EXISTS (SELECT 1 FROM plata.Pedido x WHERE x.IdPedido = TRY_CAST(b.IdPedido AS int))
          AND EXISTS (SELECT 1 FROM plata.MetodoPago x WHERE x.IdMetodoPago = TRY_CAST(b.IdMetodoPago AS int));

        -- Servicio
        INSERT INTO plata.Servicio (IdServicio, IdCliente, IdEmpleado, Descripcion, FechaServicio, Costo)
        SELECT TRY_CAST(IdServicio AS int),
               TRY_CAST(IdCliente AS int),
               TRY_CAST(IdEmpleado AS int),
               plata.fn_oracion(Descripcion),
               TRY_CAST(FechaServicio AS date),
               TRY_CAST(Costo AS decimal(10,2))
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(IdServicio AS int) ORDER BY _fecha_carga DESC) AS rn
            FROM bronce.Servicio
            WHERE TRY_CAST(IdServicio AS int) IS NOT NULL
        ) b
        WHERE b.rn = 1
          AND EXISTS (SELECT 1 FROM plata.Cliente x WHERE x.IdCliente = TRY_CAST(b.IdCliente AS int))
          AND EXISTS (SELECT 1 FROM plata.Empleado x WHERE x.IdEmpleado = TRY_CAST(b.IdEmpleado AS int));

        COMMIT TRAN;

        EXEC plata.usp_validar_calidad;
        PRINT 'Plata cargada y validada. Revisar plata.log_calidad.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO
