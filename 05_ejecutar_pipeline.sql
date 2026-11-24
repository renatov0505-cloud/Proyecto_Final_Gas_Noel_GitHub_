/*
Proyecto: Gas Noel
Archivo : 05_ejecutar_pipeline.sql

Ejecuta el pipeline completo Bronce -> Plata -> Oro y muestra resultados.

ORDEN DE EJECUCION DEL PROYECTO (primera vez):
  1) 00_script_original.sql      (fuente en dbo)
  2) 01_ddl_arquitectura_der.sql (esquemas, bronce y plata)
  3) 02_etl_ingesta_bronce.sql   (procedimiento de ingesta)
  4) 03_etl_limpieza_plata.sql   (funciones y procedimientos de limpieza)
  5) 04_vistas_gold_bi.sql       (vistas de oro)
  6) 05_ejecutar_pipeline.sql    (este archivo)
*/
USE GasNoel;
GO

EXEC bronce.usp_cargar_bronce;
EXEC plata.usp_cargar_plata;
GO

-- ---- Verificacion Bronce (datos crudos: se ven espacios y mayusculas raras) ----
SELECT TOP 5 '[' + Nombre + ']' AS NombreBronce, '[' + Apellido_Paterno + ']' AS ApPaternoBronce FROM bronce.Cliente;
-- ---- Verificacion Plata (datos limpios) ----
SELECT TOP 5 '[' + Nombre + ']' AS NombrePlata,  '[' + Apellido_Paterno + ']' AS ApPaternoPlata  FROM plata.Cliente;

-- ---- Bitacora de calidad ----
SELECT * FROM plata.log_calidad ORDER BY IdLog;

-- ---- Capa Oro ----
SELECT * FROM oro.vw_kpi_resumen;
SELECT * FROM oro.vw_ventas_pedido ORDER BY IdPedido;
SELECT * FROM oro.vw_cliente_360 ORDER BY TotalComprado DESC;
SELECT * FROM oro.vw_ventas_producto ORDER BY Ingreso DESC;
SELECT * FROM oro.vw_ventas_sucursal_mes ORDER BY Sucursal, Anio, Mes;
SELECT * FROM oro.vw_inventario_sucursal;
SELECT * FROM oro.vw_pagos_metodo;
SELECT * FROM oro.vw_desempeno_repartidor;
SELECT * FROM oro.vw_servicios;
