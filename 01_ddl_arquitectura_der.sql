/*
Proyecto: Gas Noel
Archivo : 01_ddl_arquitectura_der.sql

Crea la ARQUITECTURA MEDALLON sobre la base GasNoel:
  - Esquemas: bronce, plata, oro
  - bronce.* : copia cruda de la fuente (dbo). Todo como texto + metadatos de carga.
  - plata.*  : las 13 tablas del DER con tipos, PK, FK y restricciones CHECK.
  - plata.log_calidad : bitacora de reglas de calidad.
  - oro.*    : vistas analiticas (ver 04_vistas_gold_bi.sql)

Prerrequisito: haber ejecutado 00_script_original.sql (tablas fuente en dbo).
Es re-ejecutable: borra y vuelve a crear las tablas de bronce y plata.
*/
IF DB_ID('GasNoel') IS NULL CREATE DATABASE GasNoel;
GO
USE GasNoel;
GO
SET NOCOUNT ON;
GO

-- Esquemas
IF SCHEMA_ID('bronce') IS NULL EXEC('CREATE SCHEMA bronce');
IF SCHEMA_ID('plata')  IS NULL EXEC('CREATE SCHEMA plata');
IF SCHEMA_ID('oro')    IS NULL EXEC('CREATE SCHEMA oro');
GO

-- Limpieza previa (orden inverso por llaves foraneas)
DROP TABLE IF EXISTS plata.Servicio;
DROP TABLE IF EXISTS plata.Pago;
DROP TABLE IF EXISTS plata.Entrega;
DROP TABLE IF EXISTS plata.DetallePedido;
DROP TABLE IF EXISTS plata.Pedido;
DROP TABLE IF EXISTS plata.MetodoPago;
DROP TABLE IF EXISTS plata.Unidad;
DROP TABLE IF EXISTS plata.Empleado;
DROP TABLE IF EXISTS plata.Inventario;
DROP TABLE IF EXISTS plata.Producto;
DROP TABLE IF EXISTS plata.Domicilio;
DROP TABLE IF EXISTS plata.Cliente;
DROP TABLE IF EXISTS plata.Sucursal;
DROP TABLE IF EXISTS plata.log_calidad;
DROP TABLE IF EXISTS bronce.Servicio;
DROP TABLE IF EXISTS bronce.Pago;
DROP TABLE IF EXISTS bronce.Entrega;
DROP TABLE IF EXISTS bronce.DetallePedido;
DROP TABLE IF EXISTS bronce.Pedido;
DROP TABLE IF EXISTS bronce.MetodoPago;
DROP TABLE IF EXISTS bronce.Unidad;
DROP TABLE IF EXISTS bronce.Empleado;
DROP TABLE IF EXISTS bronce.Inventario;
DROP TABLE IF EXISTS bronce.Producto;
DROP TABLE IF EXISTS bronce.Domicilio;
DROP TABLE IF EXISTS bronce.Cliente;
DROP TABLE IF EXISTS bronce.Sucursal;
GO

-- =====================================================
-- CAPA BRONCE: datos crudos (todo VARCHAR) + metadatos
-- =====================================================
CREATE TABLE bronce.Sucursal (
    IdSucursal varchar(255) NULL,
    Sucursal varchar(255) NULL,
    Calle varchar(255) NULL,
    Colonia varchar(255) NULL,
    Telefono varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Cliente (
    IdCliente varchar(255) NULL,
    Nombre varchar(255) NULL,
    Apellido_Paterno varchar(255) NULL,
    Apellido_Materno varchar(255) NULL,
    Telefono varchar(255) NULL,
    Tipo_Cliente varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Domicilio (
    IdDomicilio varchar(255) NULL,
    IdCliente varchar(255) NULL,
    Calle varchar(255) NULL,
    NumeroExt varchar(255) NULL,
    Colonia varchar(255) NULL,
    Ciudad varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Producto (
    IdProducto varchar(255) NULL,
    Producto varchar(255) NULL,
    Precio varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Inventario (
    IdInventario varchar(255) NULL,
    IdSucursal varchar(255) NULL,
    IdProducto varchar(255) NULL,
    Existencia varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Empleado (
    IdEmpleado varchar(255) NULL,
    Nombre varchar(255) NULL,
    Apellido_Paterno varchar(255) NULL,
    Apellido_Materno varchar(255) NULL,
    Puesto varchar(255) NULL,
    IdSucursal varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Unidad (
    IdUnidad varchar(255) NULL,
    Placas varchar(255) NULL,
    Tipo varchar(255) NULL,
    IdSucursal varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.MetodoPago (
    IdMetodoPago varchar(255) NULL,
    Metodo varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Pedido (
    IdPedido varchar(255) NULL,
    IdCliente varchar(255) NULL,
    IdDomicilio varchar(255) NULL,
    IdSucursal varchar(255) NULL,
    FechaPedido varchar(255) NULL,
    Estado varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.DetallePedido (
    IdDetalle varchar(255) NULL,
    IdPedido varchar(255) NULL,
    IdProducto varchar(255) NULL,
    Cantidad varchar(255) NULL,
    PrecioUnitario varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Entrega (
    IdEntrega varchar(255) NULL,
    IdPedido varchar(255) NULL,
    IdEmpleado varchar(255) NULL,
    IdUnidad varchar(255) NULL,
    FechaEntrega varchar(255) NULL,
    Estado varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Pago (
    IdPago varchar(255) NULL,
    IdPedido varchar(255) NULL,
    IdMetodoPago varchar(255) NULL,
    Monto varchar(255) NULL,
    FechaPago varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

CREATE TABLE bronce.Servicio (
    IdServicio varchar(255) NULL,
    IdCliente varchar(255) NULL,
    IdEmpleado varchar(255) NULL,
    Descripcion varchar(255) NULL,
    FechaServicio varchar(255) NULL,
    Costo varchar(255) NULL,
    _fecha_carga datetime2 NOT NULL DEFAULT SYSDATETIME(),
    _origen varchar(50) NOT NULL DEFAULT 'dbo'
);
GO

-- =====================================================
-- CAPA PLATA: datos limpios, tipados y con integridad
-- =====================================================
CREATE TABLE plata.Sucursal (
    IdSucursal int CONSTRAINT PK_plata_Sucursal PRIMARY KEY,
    Sucursal varchar(50),
    Calle varchar(60),
    Colonia varchar(50),
    Telefono varchar(20),
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE plata.Cliente (
    IdCliente int CONSTRAINT PK_plata_Cliente PRIMARY KEY,
    Nombre varchar(60),
    Apellido_Paterno varchar(30),
    Apellido_Materno varchar(30),
    Telefono varchar(20),
    Tipo_Cliente varchar(15),
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE plata.Domicilio (
    IdDomicilio int CONSTRAINT PK_plata_Domicilio PRIMARY KEY,
    IdCliente int,
    Calle varchar(60),
    NumeroExt varchar(10),
    Colonia varchar(50),
    Ciudad varchar(30),
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_plata_Domicilio_IdCliente FOREIGN KEY (IdCliente) REFERENCES plata.Cliente (IdCliente)
);
GO

CREATE TABLE plata.Producto (
    IdProducto int CONSTRAINT PK_plata_Producto PRIMARY KEY,
    Producto varchar(60),
    Precio decimal(10,2),
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_plata_Producto_1 CHECK (Precio >= 0)
);
GO

CREATE TABLE plata.Inventario (
    IdInventario int CONSTRAINT PK_plata_Inventario PRIMARY KEY,
    IdSucursal int,
    IdProducto int,
    Existencia int,
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_plata_Inventario_IdSucursal FOREIGN KEY (IdSucursal) REFERENCES plata.Sucursal (IdSucursal),
    CONSTRAINT FK_plata_Inventario_IdProducto FOREIGN KEY (IdProducto) REFERENCES plata.Producto (IdProducto),
    CONSTRAINT CK_plata_Inventario_1 CHECK (Existencia >= 0)
);
GO

CREATE TABLE plata.Empleado (
    IdEmpleado int CONSTRAINT PK_plata_Empleado PRIMARY KEY,
    Nombre varchar(30),
    Apellido_Paterno varchar(30),
    Apellido_Materno varchar(30),
    Puesto varchar(20),
    IdSucursal int,
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_plata_Empleado_IdSucursal FOREIGN KEY (IdSucursal) REFERENCES plata.Sucursal (IdSucursal)
);
GO

CREATE TABLE plata.Unidad (
    IdUnidad int CONSTRAINT PK_plata_Unidad PRIMARY KEY,
    Placas varchar(10),
    Tipo varchar(15),
    IdSucursal int,
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_plata_Unidad_IdSucursal FOREIGN KEY (IdSucursal) REFERENCES plata.Sucursal (IdSucursal)
);
GO

CREATE TABLE plata.MetodoPago (
    IdMetodoPago int CONSTRAINT PK_plata_MetodoPago PRIMARY KEY,
    Metodo varchar(30),
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE plata.Pedido (
    IdPedido int CONSTRAINT PK_plata_Pedido PRIMARY KEY,
    IdCliente int,
    IdDomicilio int,
    IdSucursal int,
    FechaPedido date,
    Estado varchar(15),
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_plata_Pedido_IdCliente FOREIGN KEY (IdCliente) REFERENCES plata.Cliente (IdCliente),
    CONSTRAINT FK_plata_Pedido_IdDomicilio FOREIGN KEY (IdDomicilio) REFERENCES plata.Domicilio (IdDomicilio),
    CONSTRAINT FK_plata_Pedido_IdSucursal FOREIGN KEY (IdSucursal) REFERENCES plata.Sucursal (IdSucursal)
);
GO

CREATE TABLE plata.DetallePedido (
    IdDetalle int CONSTRAINT PK_plata_DetallePedido PRIMARY KEY,
    IdPedido int,
    IdProducto int,
    Cantidad int,
    PrecioUnitario decimal(10,2),
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_plata_DetallePedido_IdPedido FOREIGN KEY (IdPedido) REFERENCES plata.Pedido (IdPedido),
    CONSTRAINT FK_plata_DetallePedido_IdProducto FOREIGN KEY (IdProducto) REFERENCES plata.Producto (IdProducto),
    CONSTRAINT CK_plata_DetallePedido_1 CHECK (Cantidad > 0),
    CONSTRAINT CK_plata_DetallePedido_2 CHECK (PrecioUnitario >= 0)
);
GO

CREATE TABLE plata.Entrega (
    IdEntrega int CONSTRAINT PK_plata_Entrega PRIMARY KEY,
    IdPedido int,
    IdEmpleado int,
    IdUnidad int,
    FechaEntrega date,
    Estado varchar(15),
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_plata_Entrega_IdPedido FOREIGN KEY (IdPedido) REFERENCES plata.Pedido (IdPedido),
    CONSTRAINT FK_plata_Entrega_IdEmpleado FOREIGN KEY (IdEmpleado) REFERENCES plata.Empleado (IdEmpleado),
    CONSTRAINT FK_plata_Entrega_IdUnidad FOREIGN KEY (IdUnidad) REFERENCES plata.Unidad (IdUnidad)
);
GO

CREATE TABLE plata.Pago (
    IdPago int CONSTRAINT PK_plata_Pago PRIMARY KEY,
    IdPedido int,
    IdMetodoPago int,
    Monto decimal(10,2),
    FechaPago date,
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_plata_Pago_IdPedido FOREIGN KEY (IdPedido) REFERENCES plata.Pedido (IdPedido),
    CONSTRAINT FK_plata_Pago_IdMetodoPago FOREIGN KEY (IdMetodoPago) REFERENCES plata.MetodoPago (IdMetodoPago),
    CONSTRAINT CK_plata_Pago_1 CHECK (Monto > 0)
);
GO

CREATE TABLE plata.Servicio (
    IdServicio int CONSTRAINT PK_plata_Servicio PRIMARY KEY,
    IdCliente int,
    IdEmpleado int,
    Descripcion varchar(80),
    FechaServicio date,
    Costo decimal(10,2),
    _fecha_proceso datetime2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_plata_Servicio_IdCliente FOREIGN KEY (IdCliente) REFERENCES plata.Cliente (IdCliente),
    CONSTRAINT FK_plata_Servicio_IdEmpleado FOREIGN KEY (IdEmpleado) REFERENCES plata.Empleado (IdEmpleado),
    CONSTRAINT CK_plata_Servicio_1 CHECK (Costo >= 0)
);
GO

CREATE TABLE plata.log_calidad (
    IdLog int IDENTITY(1,1) PRIMARY KEY,
    FechaLog datetime2 NOT NULL DEFAULT SYSDATETIME(),
    Tabla varchar(50) NOT NULL,
    Regla varchar(100) NOT NULL,
    Detalle varchar(400) NULL
);
GO
