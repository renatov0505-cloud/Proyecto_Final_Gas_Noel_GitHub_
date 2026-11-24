# Gas Noel
### Integración de Datos en SQL Server

**Materia:** Integración de Datos | Universidad Iberoamericana León
**Equipo:** [1] | **Tablero Trello: https://trello.com/invite/b/6ac47c2b61659e31eb1547e9/ATTI0b751c651650599a23bcb95cb34c14a29BAFA31C/id-gas-noel**

<img width="512" height="512" alt="image" src="https://github.com/user-attachments/assets/0a770cfc-b854-4845-bb77-7cdb3f8e9646" />

## 1. Descripción del Proyecto

Gas Noel es un negocio de distribución de gas LP en León, Guanajuato. Cuenta con 3 sucursales (Planta León Norte, Sucursal Centro y Estación de Carburación Sur) y vende cilindros de 10, 20, 30 y 45 kg y gas estacionario por litro. Atiende a clientes domésticos con entregas en pipa y camioneta, además de servicios técnicos de instalación y mantenimiento.

La fuente de datos original es un sistema transaccional propio, creado por el equipo en SQL Server (base `GasNoel`, esquema `dbo`). Tiene 13 tablas y 68 registros, con 19 fallas de calidad sembradas a propósito: mayúsculas aleatorias y espacios sobrantes.

El objetivo analítico es integrar, limpiar y validar esos datos mediante arquitectura Medallón implementada en **Microsoft SQL Server**. Con ello se obtienen vistas listas para BI: ventas, cobranza, saldo por cliente, inventario, métodos de pago y desempeño de repartidores.

## 2. Arquitectura de Integración (SQL Server)


* **Esquema `bronce` (Ingesta):** 13 tablas espejo con carga cruda desde `dbo`. Todas las columnas son `varchar(255)` y se agregan los metadatos `_fecha_carga` y `_origen`. La carga es completa (`TRUNCATE` + `INSERT`) dentro de una transacción y no limpia nada: conserva espacios y mayúsculas raras.
* **Esquema `plata` (Transformación y QA):** 13 tablas con tipos reales (`int`, `decimal`, `date`), `PRIMARY KEY`, `FOREIGN KEY` y restricciones `CHECK`. Aplica las reglas de limpieza R1 a R9:
  * Estandarización de textos (`fn_limpiar`, `fn_oracion`, `fn_nombre_propio`).
  * Validación de teléfonos a 10 dígitos y normalización de la ciudad.
  * Conversión de tipos con `TRY_CAST`.
  * Eliminación de duplicados con `ROW_NUMBER()`.
  * Rechazo de registros con llave foránea huérfana.

  El proceso es re-ejecutable sin duplicar datos, y la bitácora `plata.log_calidad` registra 7 validaciones de negocio.
* **Esquema `oro` (Consumo y BI):** 9 vistas construidas solo sobre Plata:
  * `vw_ventas_pedido`
  * `vw_cliente_360` (**Vista 360°**)
  * `vw_ventas_producto`
  * `vw_ventas_sucursal_mes`
  * `vw_inventario_sucursal`
  * `vw_pagos_metodo`
  * `vw_desempeno_repartidor`
  * `vw_servicios`
  * `vw_kpi_resumen`

  Las métricas agregadas responden preguntas como cuánto se vende, cuánto se ha cobrado, qué clientes tienen saldo pendiente y qué producto genera más ingreso.

## 3. Modelo Entidad-Relación (DER)


El DER (notación pata de gallo) modela 15 entidades: 9 maestras (azul) y 6 transaccionales (naranja). La versión implementada en SQL Server conserva 13 tablas con sus llaves primarias y foráneas.

## 4. Estructura del Repositorio (`/src`)

* `00_script_original.sql`: Base de datos fuente `GasNoel` (esquema `dbo`) con las 13 tablas y sus datos de ejemplo.
* `01_ddl_arquitectura_der.sql`: Creación de base de datos, esquemas `bronce`, `plata` y `oro`, y tablas relacionales con PK, FK y `CHECK`.
* `02_etl_ingesta_bronce.sql`: Procedimiento `bronce.usp_cargar_bronce` de carga cruda (`TRUNCATE` / `INSERT`).
* `03_etl_limpieza_plata.sql`: Funciones y procedimientos almacenados de limpieza y reglas de calidad (`plata.usp_cargar_plata`, `plata.usp_validar_calidad`).
* `04_vistas_gold_bi.sql`: Vistas finales y consultas KPI.
* `05_ejecutar_pipeline.sql`: Ejecución del pipeline completo Bronce → Plata → Oro y consultas de verificación.

## 5. Integrantes y Roles (4 Roles Oficiales)

* **Data Architect / SQL Specialist:** Allison Scarlett Morán García
* **Data Engineer / Pipeline Lead:** Renato Giovani Vela Rocha
* **Data Quality & QA Specialist:** Samara Medina Espinosa
* **Líder de Proyecto & BI Specialist:** Ruth Miranda Rodríguez Sánchez *(En equipos de 5, dividir en Líder de Proyecto y BI Specialist)*
