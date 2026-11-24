/*
Proyecto: Gas Noel
Archivo : 00_script_original.sql

BASE DE DATOS ORIGINAL (sistema fuente), tal como fue recibida.
Crea la base GasNoel y las 13 tablas en el esquema dbo, con sus datos de ejemplo.
Esta es la FUENTE de la que se alimenta la capa Bronce.
Ejecutar una sola vez (si las tablas ya existen, borrar la base y repetir).
*/
IF DB_ID('GasNoel') IS NULL CREATE DATABASE GasNoel;
GO
USE GasNoel;
GO

-- 1.- Sucursal

create table Sucursal (

IdSucursal int primary key,

Sucursal varchar(50),

Calle varchar(60),

Colonia varchar(50),

Telefono varchar(20)

)

insert into Sucursal (IdSucursal,Sucursal,Calle,Colonia,Telefono) values (1,'Planta Leon Norte','Paseo de los insurgentes 2415','Zona Industrial','4775550001')

insert into Sucursal (IdSucursal,Sucursal,Calle,Colonia,Telefono) values (2,'SucurSal Centro','Blvd. Antonio Madrazo 915','Centro','4775550002')

insert into Sucursal (IdSucursal,Sucursal,Calle,Colonia,Telefono) values (3,'Estacion Carburacion Sur','Blvd Hidalgo 3705',' Zona Sur','4775550003')

select * from Sucursal

GO

-- 2.- Cliente

create table Cliente (

IdCliente int primary key,

Nombre varchar(60),

Apellido_Paterno varchar(30),

Apellido_Materno varchar(30),

Telefono varchar(20),

Tipo_Cliente varchar(15)

)

insert into Cliente (IdCliente,Nombre,Apellido_Paterno,Apellido_Materno,Telefono,Tipo_Cliente) values (1,'RenaTo Giovani','Vela','Rocha','4776590498','Domestico')

insert into Cliente (IdCliente,Nombre,Apellido_Paterno,Apellido_Materno,Telefono,Tipo_Cliente) values (2,'Ruth Miranda','Rodriguez','Sanchez','4775550102','Domestico')

insert into Cliente (IdCliente,Nombre,Apellido_Paterno,Apellido_Materno,Telefono,Tipo_Cliente) values (3,'Allison Scarlett','Garcia','Moran','4775550103','Domestico')

insert into Cliente (IdCliente,Nombre,Apellido_Paterno,Apellido_Materno,Telefono,Tipo_Cliente) values (4,'Samara','  Medina','Espinoza','4775550104','Domestico')

insert into Cliente (IdCliente,Nombre,Apellido_Paterno,Apellido_Materno,Telefono,Tipo_Cliente) values (5,'Eric Ezequiel','Terrones','Hernandez','4775550105','Domestico')

insert into Cliente (IdCliente,Nombre,Apellido_Paterno,Apellido_Materno,Telefono,Tipo_Cliente) values (6,'Luis Fernando','Piña','Saucedo','4775550106','Domestico')

insert into Cliente (IdCliente,Nombre,Apellido_Paterno,Apellido_Materno,Telefono,Tipo_Cliente) values (7,'Antonio','Hernandez','Ontiveros','4775550107','Domestico')

select * from Cliente

GO

-- 3.- Domicilio

create table Domicilio (

IdDomicilio int primary key,

IdCliente int references Cliente (IdCliente),

Calle varchar(60),

NumeroExt varchar(10),

Colonia varchar(50),

Ciudad varchar(30)

)

insert into Domicilio (IdDomicilio,IdCliente,Calle,NumeroExt,Colonia,Ciudad) values (1,1,'Calle Hacienda del Rincón','147','Balcones del Campestre','León de los Aldama')

insert into Domicilio (IdDomicilio,IdCliente,Calle,NumeroExt,Colonia,Ciudad) values (2,2,'Calle Monte Albán','247','Balcones del Campestre','León')

insert into Domicilio (IdDomicilio,IdCliente,Calle,NumeroExt,Colonia,Ciudad) values (3,3,'Avenida Guanajuato','815','Jardines Del Moral','León')

insert into Domicilio (IdDomicilio,IdCliente,Calle,NumeroExt,Colonia,Ciudad) values (4,4,'Calle Río Lerma','136','La Martinica','León')

insert into Domicilio (IdDomicilio,IdCliente,Calle,NumeroExt,Colonia,Ciudad) values (5,5,'Boulevard  Campestre','492','Lomas del Campestre','León')

insert into Domicilio (IdDomicilio,IdCliente,Calle,NumeroExt,Colonia,Ciudad) values (6,6,'Calle Paseo de los Olivos','328','Valle del Campestre','León')

insert into Domicilio (IdDomicilio,IdCliente,Calle,NumeroExt,Colonia,Ciudad) values (7,7,'Calle San Sebastián','671','El Coecillo','León')

select * from Domicilio

GO

-- 4.- Producto

create table Producto (

IdProducto int primary key,

Producto varchar(60),

Precio decimal(10,2)

)

insert into Producto (IdProducto,Producto,Precio) values (1,'Cilindro 20 kg',380.00)

insert into Producto (IdProducto,Producto,Precio) values (2,'CiLindro 30 kg',570.00)

insert into Producto (IdProducto,Producto,Precio) values (3,'Cilindro 45 kg',855.00)

insert into Producto (IdProducto,Producto,Precio) values (4,'Gas estacionario por litro',11.50)

insert into Producto (IdProducto,Producto,Precio) values (5,'  Cilindro 10 kg',190.00)

select * from Producto

GO

-- 5.- Inventario

create table Inventario (

IdInventario int primary key,

IdSucursal int references Sucursal (IdSucursal),

IdProducto int references Producto (IdProducto),

Existencia int

)

insert into Inventario (IdInventario,IdSucursal,IdProducto,Existencia) values (1,1,1,200)

insert into Inventario (IdInventario,IdSucursal,IdProducto,Existencia) values (2,1,2,100)

insert into Inventario (IdInventario,IdSucursal,IdProducto,Existencia) values (3,1,3,60)

insert into Inventario (IdInventario,IdSucursal,IdProducto,Existencia) values (4,1,4,8000)

insert into Inventario (IdInventario,IdSucursal,IdProducto,Existencia) values (5,2,1,120)

insert into Inventario (IdInventario,IdSucursal,IdProducto,Existencia) values (6,2,5,80)

select * from Inventario

GO

-- 6.- Empleado

create table Empleado (

IdEmpleado int primary key,

Nombre varchar(30),

Apellido_Paterno varchar(30),

Apellido_Materno varchar(30),

Puesto varchar(20),

IdSucursal int references Sucursal (IdSucursal)

)

insert into Empleado (IdEmpleado,Nombre,Apellido_Paterno,Apellido_Materno,Puesto,IdSucursal) values (1,'Diego','Lopez','Sanchez','Administrador',1)

insert into Empleado (IdEmpleado,Nombre,Apellido_Paterno,Apellido_Materno,Puesto,IdSucursal) values (2,'Fabrizio','Dias','Ponciano','Repartidor',1)

insert into Empleado (IdEmpleado,Nombre,Apellido_Paterno,Apellido_Materno,Puesto,IdSucursal) values (3,'KarLo','Lobato','Pastrana','Repartidor',2)

insert into Empleado (IdEmpleado,Nombre,Apellido_Paterno,Apellido_Materno,Puesto,IdSucursal) values (4,'Frida Andree','Suarez',' Landin','Vendedor',2)

insert into Empleado (IdEmpleado,Nombre,Apellido_Paterno,Apellido_Materno,Puesto,IdSucursal) values (5,'Dana Camila','Mancillas','Rivas','Tecnico',1)

select * from Empleado

GO

-- 7.- Unidad

create table Unidad (

IdUnidad int primary key,

Placas varchar(10),

Tipo varchar(15),

IdSucursal int references Sucursal (IdSucursal)

)

insert into Unidad (IdUnidad,Placas,Tipo,IdSucursal) values (1,'GTO-101-A','Pipa',1)

insert into Unidad (IdUnidad,Placas,Tipo,IdSucursal) values (2,'GTO-102-B','CamIoneta',1)

insert into Unidad (IdUnidad,Placas,Tipo,IdSucursal) values (3,' GTO-103-C','Camioneta',2)

select * from Unidad

GO

-- 8.- MetodoPago

create table MetodoPago (

IdMetodoPago int primary key,

Metodo varchar(30)

)

insert into MetodoPago (IdMetodoPago,Metodo) values (1,'EfecTivo')

insert into MetodoPago (IdMetodoPago,Metodo) values (2,'Tarjeta')

insert into MetodoPago (IdMetodoPago,Metodo) values (3,' Transferencia')

select * from MetodoPago

GO

-- 9.- Pedido

create table Pedido (

IdPedido int primary key,

IdCliente int references Cliente (IdCliente),

IdDomicilio int references Domicilio (IdDomicilio),

IdSucursal int references Sucursal (IdSucursal),

FechaPedido date,

Estado varchar(15)

)

insert into Pedido (IdPedido,IdCliente,IdDomicilio,IdSucursal,FechaPedido,Estado) values (1,1,1,1,'2026-09-01','EntregAdo')

insert into Pedido (IdPedido,IdCliente,IdDomicilio,IdSucursal,FechaPedido,Estado) values (2,2,2,1,'2026-09-03','Entregado')

insert into Pedido (IdPedido,IdCliente,IdDomicilio,IdSucursal,FechaPedido,Estado) values (3,3,3,2,'2026-09-05','  Entregado')

insert into Pedido (IdPedido,IdCliente,IdDomicilio,IdSucursal,FechaPedido,Estado) values (4,5,5,1,'2026-09-10','Entregado')

insert into Pedido (IdPedido,IdCliente,IdDomicilio,IdSucursal,FechaPedido,Estado) values (5,4,4,1,'2026-10-02','Pendiente')

insert into Pedido (IdPedido,IdCliente,IdDomicilio,IdSucursal,FechaPedido,Estado) values (6,1,1,1,'2026-10-03','Pendiente')

select * from Pedido

GO

-- 10.- DetallePedido

create table DetallePedido (

IdDetalle int primary key,

IdPedido int references Pedido (IdPedido),

IdProducto int references Producto (IdProducto),

Cantidad int,

PrecioUnitario decimal(10,2)

)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (1,1,1,2,380.00)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (2,1,5,1,190.00)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (3,2,2,1,570.00)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (4,2,1,1,380.00)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (5,3,3,2,855.00)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (6,3,5,2,190.00)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (7,4,4,1000,11.50)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (8,5,1,2,380.00)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (9,5,3,1,855.00)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (10,6,5,3,190.00)

insert into DetallePedido (IdDetalle,IdPedido,IdProducto,Cantidad,PrecioUnitario) values (11,6,1,1,380.00)

select * from DetallePedido

GO

-- 11.- Entrega

create table Entrega (

IdEntrega int primary key,

IdPedido int references Pedido (IdPedido),

IdEmpleado int references Empleado (IdEmpleado),

IdUnidad int references Unidad (IdUnidad),

FechaEntrega date,

Estado varchar(15)

)

insert into Entrega (IdEntrega,IdPedido,IdEmpleado,IdUnidad,FechaEntrega,Estado) values (1,1,2,2,'2026-09-01','Realizada')

insert into Entrega (IdEntrega,IdPedido,IdEmpleado,IdUnidad,FechaEntrega,Estado) values (2,2,2,2,'2026-09-03','RealizAda')

insert into Entrega (IdEntrega,IdPedido,IdEmpleado,IdUnidad,FechaEntrega,Estado) values (3,3,3,3,'2026-09-05','Realizada')

insert into Entrega (IdEntrega,IdPedido,IdEmpleado,IdUnidad,FechaEntrega,Estado) values (4,4,2,1,'2026-09-10','Realizada')

select * from Entrega

GO

-- 12.- Pago

create table Pago (

IdPago int primary key,

IdPedido int references Pedido (IdPedido),

IdMetodoPago int references MetodoPago (IdMetodoPago),

Monto decimal(10,2),

FechaPago date

)

insert into Pago (IdPago,IdPedido,IdMetodoPago,Monto,FechaPago) values (1,1,1,950.00,'2026-09-01')

insert into Pago (IdPago,IdPedido,IdMetodoPago,Monto,FechaPago) values (2,2,3,950.00,'2026-09-03')

insert into Pago (IdPago,IdPedido,IdMetodoPago,Monto,FechaPago) values (3,3,2,2090.00,'2026-09-05')

insert into Pago (IdPago,IdPedido,IdMetodoPago,Monto,FechaPago) values (4,4,3,11500.00,'2026-09-11')

insert into Pago (IdPago,IdPedido,IdMetodoPago,Monto,FechaPago) values (5,5,1,500.00,'2026-10-02')

select * from Pago

GO

-- 13.- Servicio

create table Servicio (

IdServicio int primary key,

IdCliente int references Cliente (IdCliente),

IdEmpleado int references Empleado (IdEmpleado),

Descripcion varchar(80),

FechaServicio date,

Costo decimal(10,2)

)

insert into Servicio (IdServicio,IdCliente,IdEmpleado,Descripcion,FechaServicio,Costo) values (1,1,5,'Revision de Instalacion','2026-09-04',350.00)

insert into Servicio (IdServicio,IdCliente,IdEmpleado,Descripcion,FechaServicio,Costo) values (2,5,5,'Mantenimiento de tanque estacionario','2026-09-12',900.00)

insert into Servicio (IdServicio,IdCliente,IdEmpleado,Descripcion,FechaServicio,Costo) values (3,4,5,'  Instalacion de regulador','2026-10-07',450.00)

select * from Servicio
GO
