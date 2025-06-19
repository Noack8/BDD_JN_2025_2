# Bitácora

Documento interno, ***no lo lea profe*** (o bueno, no importa).

## Fragmentos

Se fragmentó la BD en 4 regiones, siguiendo juntando algunas de las regiones de [esta clasificación](https://descargarmapas.net/mexico/mapa-mexico-regiones-economicas).

Terminaron de la siguiente forma las regiones:

- Norte: incluyó Norte, Noreste y Noroeste
- Sur: incluyó Pacífico Sur, Península de Yucatán y Tabasco
- Oriente: incluyó Centro sur y Veracruz
- Occidente y otros: incluyó todo lo demás. (Aquí es donde se incluyen datos con regiones no consideradas)

En SQL maomeno se definen así las regiones:
```sql
-- NORTE
ENTIDAD_RES IN ('08','05','10','32','24','25','26','18','02','03')

-- SUR
ENTIDAD_RES IN ('07','12','20','27','31','23','04')

-- ORIENTE
ENTIDAD_RES IN ('09','13','21','22','15','17','29','30')

-- OCCIDENTE Y OTROS
ENTIDAD_RES NOT IN ('07','12','20','27','31','23','04','08','05','10','32','24','25','26','18','02','03','09','13','21','22','15','17','29','30')
```

## Estructura de red

Para cada fragmento se usó un servidor, 3 SQL Servers y uno MySQL. Para la implementación se intentó usar directamente la conexión a MySQL desde los tres nodos extra, pero se descartó porque sería necesario configurar en cada nodo el ODBC para MySQL, que no es automatizable y requería privilegios de administrador los cuales no se tienen acceso en el laboratorio.

Entonces analizando la situación del laboratorio:

- El ODBC y Linked Server ya está preconfigurado en cada máquina.
- Las máquinas están en una red local aislada.
- No se tienen permisos de administrador en el laboratorio.

Opté por usar un servidor SQL Server como proxy entre los nodos SQL Server y MySQL. Esta configuración permite reutilizar un nodo SQL Server, pero en esta implementación se usó un nodo extra que solo actua como proxy.

### Fragmentación de datos

Existen varios caminos para llevar a cabo la fragmentación y distribución de datos a cada nodo. Para el caso específico de servidores SQL Server:

1. Fragmentar, respaldar/copiar en un archivo y restaurar en el servidor destino. (Esto es bastante bueno si el acceso a las máquinas físicas es rápido) 
2. Copiar todos los datos de un servidor a otro y luego fragmentar en el servidor destino. (Esto es desperdicio de recursos, ya sea física o remota)
3. Fragmentar y luego insertar los datos de forma remota en el servidor destino. (Este es viable si no se tiene acceso físico a los servidores, pero está limitado por el ancho de banda y puede ser riesgoso/complejo en caso de fallo de red o de los servidores)  

En el laboratorio pude haber usado la primera opción, pero decidí usar la tercera para evitar la fatiga.

Por otra parte, para el caso de MySQL hay más retos, ya que no hay una forma tan sencilla de copiar los datos de SQL Server a MySQL. Y cualquier persona sin experiencia se topará con procesos lentos, complejos y con riesgos de fallos. Las opciones son:

1. Fragmentar, exportar los datos a CSV y restaurar en MySQL. Remoto o local.
2. Fragmentar e insertar de forma remota.
3. Exportar los datos a CSV, restaurar en MySQL y luego fragmentar.

Por la Estructura de Red se descartó la segunda opción ya que era complejo hacer la inserción desde el proxy (este no tiene los datos). La primera opción en su versión remota podría ser útil en un caso donde se tenga más libertad de permisos, pero al estar en el laboratorio la descarté, además de que estaría limitado por el ancho de banda. En cuanto a la versión local, la intenté, pero tuve algún error, probablemente debido a la falta de experiencia, y preferí usar la tercera opción.

Para la tercera opción también hubo problemas:
- Restaurarlo desde el Wizard de Workbench de MySQL era extremadamente lento, insertaba línea por línea.
- Restaurarlo por comando LOAD desde el Workbench de MySQL era un poco menos lento, pero trababa la aplicación y al final perdía la conexión, lo cual generó varios problemas de filas duplicadas.

Al final usé el comando LOAD desde la línea de comandos de MySQL, que es más rápido y no pierde la conexión. Más o menos tardé 3 minutos en restaurar los datos. (Se tiene que habilitar el comando LOAD en la configuración de MySQL, https://stackoverflow.com/questions/10762239/mysql-enable-load-data-local-infile)

## Distribución de las consultas

En primer instancia, fue intuitivo cambiar el origen de datos de las consultas ya desarrolladas a la unión de los datos de todos los nodos y esto funcionaba, sin embargo, era lento porque transmitía todas las filas de cada nodo al nodo que ejecutaba la consulta, lo cual no era distribuir la consulta sino hacerla remota. Una vez observado eso empecé a usar OPENQUERY para que los nodos hicieran un preprocesado de los datos para minimizar el número de filas a transmitir.

Al empezar a hacer el cambio fue donde salieron los detalles de cada consulta. Por ejemplo en la 3, se requiere hacer un conteo en cada nodo para obtener el total de casos por enfermedad y de los registrados, para después en el nodo inicial hacer el cálculo final uniendo los resultados de todos los nodos. También fue un problema que en la consulta original se usaba IIF que no es estandar y no existe en MySQL, por lo que se tuvo que adaptar la consulta para que funcione en ambos.

Otro problema principal es que los tipos de datos en los motores de SQL no fueron faciles de adaptar, por lo cual algunas columnas quedaron con tipos de datos incorrectos. Ej: las fechas se convirtieron a text, algunos que pudieron ser char se quedaron como text. Por esto surgieron otros problemas de tipo de datos que se solventaron con CAST.

### Proxy

Es de resaltar la forma en la que funciona el proxy, ya que en primer lugar pensé usar una vista para hacer la consulta y la descarté porque creí que esto causaría el mismo problema de consulta remota y no distribuida, en realidad no sé si hay alguna forma de hacerlo. Pudo haber sido un procedimiento almacenado, pero decidí mantenerlo simple y anidar dos OPENQUERY.

Para hacer la anidación se requiere que los Linked Servers tengan configurado el RPC y autenticación propia.

Ya configurado se puede anidar tal que así:

```sql
SELECT *  
FROM 
    OPENQUERY(E6_NODO_ORIENTE, 
    'SELECT * 
     FROM OPENQUERY(MYSQL_8, 
     ''
     SELECT 
        SUM(CASE WHEN DIABETES = 1 THEN 1 ELSE 0 END) AS CASOS_DIABETES, 
        SUM(CASE WHEN HIPERTENSION = 1 THEN 1 ELSE 0 END) AS CASOS_HIPERTENSION, 
        SUM(CASE WHEN OBESIDAD = 1 THEN 1 ELSE 0 END) AS CASOS_OBESIDAD, 
        COUNT(*) AS CASOS_TOTALES, 
        ''''ORIENTE'''' AS REGION 
     FROM e6_covid_oriente.datoscovid
     WHERE CLASIFICACION_FINAL IN (1, 2, 3)
     '')
') 
```

## Consultas

### Consulta 3

No es mucha ciencia el cambio, simplemente la suma se hace por nodo y al final el nodo invocador hace el cálculo final.

### Consulta 4

Más allá del CAST en la columna de MySQL, acá hay un detalle importante en los GROUP BY, anteriormente se usaba un WHERE final validando los casos directamente:

```sql
WHERE casos_hipertension > 0 
  AND casos_obesidad > 0 
  AND casos_diabetes > 0 
  AND casos_tabaquismo > 0
GROUP BY MUNICIPIO_RES;
```

Sin embargo al hacer la fragmentación algunos municipios se encuentran en varios nodos (no sabemos por qué, simplemente los datos vienen así) y por ende los registros no quedaban compactados correctamente en los resultados de las consultas distribuidas, esto hacía que se descartaran ciertos datos y el resultado fuera erróneo, entonces decidimos modificarlo para que se agruparan todos los datos sin importar los casos y posteriormente filtrarlos con el HAVING.

```sql
GROUP BY MUNICIPIO_RES
HAVING SUM(casos_hipertension) > 0 
  AND SUM(casos_obesidad) > 0 
  AND SUM(casos_diabetes) > 0 
  AND SUM(casos_tabaquismo) > 0;
```

### Consulta 5

El detalle más notable de esta consulta es el CAST de la fecha (el cual ya se hacía antes), solo que en MySQL INT es SIGNED. 

```sql
CAST(left(C.fecha_def,4) as signed) = 9999
```

Más allá de eso está el CAST para ENTIDAD_NAC en MySQL que es tipo TEXT originalmente, pero se convirtió a CHAR(2) para que funcionen las operaciones de SQL.

```sql
CAST(c.ENTIDAD_NAC as CHAR(2))
```

### Consulta 7

Acá el detalle es el CAST (en MySQL) de la fecha que es TEXT, pero lo pasamos como DECIMAL(4,0) para que funcionen las operaciones de SQL.

```sql
CAST(c.ENTIDAD_RES as CHAR(2)),
CAST(YEAR(c.fecha_ingreso) as decimal(4,0)) AS anio,
CAST(MONTH(c.fecha_ingreso) as decimal(4,0)) AS mes,
COUNT(*) AS total_casos
```

Nota: el "anio" es porque teníamos duda que causara problema, pero creo que podría ser "año" sin problema. De igual forma creo que el mes podría ser DECIMAL(2,0).