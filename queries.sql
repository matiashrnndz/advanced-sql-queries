/*
CONSULTA 1

Listar la razon social y telefono de los clientes que ingresaron en abril de 2016 y registraron
algun electrodomestico, y que dichos clientes no hayan tenido facturas en ese mes.
*/

(SELECT cli.RAZONSOCIAL AS "Razon social", cli.TELEFONO AS "Telefono"
 FROM CLIENTE cli
 JOIN PRODUCTO prod ON prod.RUT = cli.RUT
 WHERE cli.FCHING BETWEEN TO_DATE('01/04/2016', 'dd/mm/yyyy') AND TO_DATE('30/04/2016', 'dd/mm/yyyy')
       AND UPPER(prod.TIPO) = 'ELECTRODOMESTICO')
       
MINUS

(SELECT cli.RAZONSOCIAL, cli.TELEFONO
 FROM CLIENTE cli
 JOIN PRODUCTO prod ON prod.RUT = cli.RUT
 JOIN FACTURA fac ON fac.CODPROD = prod.CODPROD
 WHERE fac.FECHA BETWEEN TO_DATE('01/04/2016', 'dd/mm/yyyy') AND TO_DATE('30/04/2016', 'dd/mm/yyyy'));
 
---------------------------------------------------------------------------------------------------------
/*
CONSULTA 2

Listar el RUT y direccion de los clientes que hayan registrado productos durante la primera
quincena de marzo del corriente año del rubro informatica o electrodomesticos pero no ambos
tipos, y que se hayan almacenado en algun galpon donde el cliente Logistica & Distribucion.
almacena alguna vez alguno de sus productos de bazar.
*/

SELECT DISTINCT cli.RUT, cli.DIRECCION AS "Direccion"
FROM CLIENTE cli
JOIN PRODUCTO prod ON prod.RUT = cli.RUT
JOIN ALMACENA almac ON almac.CODPROD = prod.CODPROD
JOIN GALPON galp ON galp.NOMBRE = almac.NOMBRE
WHERE galp.NOMBRE IN (SELECT galp2.NOMBRE
                      FROM GALPON galp2
                      JOIN ALMACENA almac2 ON almac2.NOMBRE = galp2.NOMBRE
                      JOIN PRODUCTO prod2 ON prod2.CODPROD = almac2.CODPROD
                      JOIN CLIENTE cli2 ON cli2.RUT = prod2.RUT
                      WHERE UPPER(cli2.RAZONSOCIAL) = 'LOGISTICA Y DISTRIBUCION' AND
                            UPPER(prod2.TIPO) = 'BAZAR') AND
      UPPER(cli.RAZONSOCIAL) != 'LOGOSTICA Y DISTRIBUCION' AND
      prod.FDESDE BETWEEN TO_DATE('01/03/2016', 'dd/mm/yyyy') AND TO_DATE('15/03/2016', 'dd/mm/yyyy') AND
      cli.RUT NOT IN (SELECT cli2.RUT
                      FROM CLIENTE cli2
                      WHERE NOT EXISTS(SELECT 1
                                       FROM PRODUCTO prod2
                                       WHERE prod2.TIPO = 'ELECTRODOMESTICO' AND
                                       NOT EXISTS(SELECT 1
                                                  FROM CLIENTE cli3
                                                  JOIN PRODUCTO prod3 ON prod3.RUT = cli3.RUT
                                                  WHERE cli3.RUT = cli2.RUT AND 
                                                        prod3.TIPO = 'INFORMATICA'))) OR
      cli.RUT NOT IN (SELECT cli2.RUT
                      FROM CLIENTE cli2
                      WHERE NOT EXISTS(SELECT 1
                                       FROM PRODUCTO prod2
                                       WHERE prod2.TIPO = 'INFORMATICA' AND
                                       NOT EXISTS(SELECT 1
                                                  FROM CLIENTE cli3
                                                  JOIN PRODUCTO prod3 ON prod3.RUT = cli3.RUT
                                                  WHERE cli3.RUT = cli2.RUT AND 
                                                        prod3.TIPO = 'ELECTRODOMESTICO')));
                      
---------------------------------------------------------------------------------------------------------
/*
CONSULTA 3

Listar todos los datos de los clientes que solo hayan registrado productos de perfumeria y que
dichos productos se hayan almacenado en el galpon Logistica del Sur.
*/

(SELECT DISTINCT cli.RUT, cli.RAZONSOCIAL AS "Razon social", cli.TELEFONO AS "Telefono", cli.DIRECCION AS "Direccion", cli.FCHING AS "Fecha de ingreso"
 FROM CLIENTE cli
 JOIN PRODUCTO prod ON prod.RUT = cli.RUT
 JOIN ALMACENA almac ON almac.CODPROD = prod.CODPROD
 WHERE NOT EXISTS (SELECT 1
                   FROM GALPON galp
                   WHERE (UPPER(galp.NOMBRE) = 'LOGISTICA DEL SUR' AND
                          NOT EXISTS (SELECT 1
                                      FROM CLIENTE cli2
                                      JOIN PRODUCTO prod2 ON prod2.RUT = cli2.RUT
                                      JOIN ALMACENA almac2 ON almac2.CODPROD = prod2.CODPROD
                                      WHERE (cli2.RUT = cli.RUT AND
                                             almac2.NOMBRE = galp.NOMBRE)))))

MINUS

(SELECT DISTINCT cli.*
 FROM CLIENTE cli
 JOIN PRODUCTO prod ON prod.RUT = cli.RUT
 WHERE UPPER(prod.TIPO) != 'PERFUMERIA');

---------------------------------------------------------------------------------------------------------
/*
CONSULTA 4

Listar el codigo, descripcion y el precio de los productos de limpieza que fueron registrados por
el cliente que hace menos tiempo ingresa al sistema. En SQL ordenar el resultado de forma de
visualizar los de mayor precio primero, seguido por un orden alfabetico por descripcion.
*/


SELECT prod.CODPROD AS "Codigo producto", prod.DESCRIPCION AS "Descripcion", prod.PRECIO AS "Precio"
FROM PRODUCTO prod
JOIN CLIENTE cli ON prod.RUT = cli.RUT
WHERE UPPER(prod.TIPO) = 'LIMPIEZA'
      AND cli.FCHING = (SELECT MAX(FCHING)
                        FROM CLIENTE)
ORDER BY prod.PRECIO DESC, prod.DESCRIPCION;

---------------------------------------------------------------------------------------------------------
/*
CONSULTA 5

Listar la razon social y direccion de los clientes que hayan almacenado productos de
informatica en todos los galpones de la empresa, considerando aquellos galpones en los que
nunca se almacena algun producto con precio menor a 500.
*/

(SELECT DISTINCT cli.RAZONSOCIAL AS "Razon social", cli.DIRECCION AS "Direccion"
 FROM CLIENTE cli
 JOIN PRODUCTO prod ON prod.RUT = cli.RUT
 JOIN ALMACENA almac ON almac.CODPROD = prod.CODPROD
 WHERE NOT EXISTS (SELECT 1
                   FROM GALPON galp
                   WHERE NOT EXISTS (SELECT 1
                                     FROM CLIENTE cli2
                                     JOIN PRODUCTO prod2 ON prod2.RUT = cli2.RUT
                                     JOIN ALMACENA almac2 ON almac2.CODPROD = prod2.CODPROD
                                     WHERE (cli2.RUT = cli.RUT AND
                                            almac2.NOMBRE = galp.NOMBRE AND
                                            UPPER(prod.TIPO) = 'INFORMATICA') AND
                                            NOT EXISTS (SELECT 1
                                                        FROM CLIENTE cli2
                                                        JOIN PRODUCTO prod2 ON prod2.RUT = cli2.RUT
                                                        JOIN ALMACENA almac2 ON almac2.CODPROD = prod2.CODPROD
                                                        WHERE (cli2.RUT = cli.RUT AND
                                                               almac2.NOMBRE = galp.NOMBRE AND
                                                               prod2.PRECIO < 500)))));

---------------------------------------------------------------------------------------------------------
/*
CONSULTA 6

Listar el codigo, precio y tipo para los productos almacenados entre el 10 y el 20 de febrero de
2016. Para dichos productos, listar tambien la fila y estante en que fueron almacenados siempre
que haya sido en el galpon Distribucion S.A. Si el producto no fue almacenado en este
galpon en lugar de fila mostrar el texto Sin fila y estante Sin estante.
*/

SELECT prod.CODPROD AS "Codigo Producto", prod.PRECIO AS "Precio", prod.TIPO AS "Tipo",
       CASE
         WHEN UPPER(almac.NOMBRE) = 'DISTRIBUCION S.A'
         THEN to_char(almac.FILA) 
         ELSE 'Sin fila'
       END AS "Fila", 
        CASE
         WHEN UPPER(almac.NOMBRE) = 'DISTRIBUCION S.A'
         THEN to_char(almac.NUMESTANTE) 
         ELSE 'Sin estante'
       END AS "Estante"
FROM PRODUCTO prod
JOIN ALMACENA almac ON almac.CODPROD = prod.CODPROD
WHERE prod.FDESDE >= to_date('10/02/2016', 'dd/mm/yyyy')
      AND prod.FHASTA <= to_date('20/02/2016', 'dd/mm/yyyy');
      
---------------------------------------------------------------------------------------------------------
/*
CONSULTA 7

Listar el RUT, telefono y direccion del cliente al cual se le facturaron mas productos,
considerando solamente las facturas realizadas a clientes que ingresaron en febrero de 2016 y
que dicho cliente tenga almacenados al menos 3 productos actualmente en el galpon
Montevideo DistAdmin.
*/

(SELECT RUT,TELEFONO AS "Telefono", DIRECCION AS "Direccion" 
FROM CLIENTE 
WHERE RUT IN (SELECT cli.RUT
              FROM CLIENTE cli
              JOIN PRODUCTO prod ON prod.RUT = cli.RUT
              JOIN ALMACENA almac ON almac.CODPROD = prod.CODPROD
              JOIN GALPON galp ON galp.NOMBRE = almac.NOMBRE
              WHERE (UPPER(galp.NOMBRE) = 'MONTEVIDEO DISTADMIN' AND
                     cli.FCHING BETWEEN to_date('01/02/2016', 'dd/mm/yyyy') AND to_date('29/02/2016', 'dd/mm/yyyy') AND
                     prod.FDESDE <= SYSDATE AND prod.FHASTA IS NULL)
                     GROUP BY cli.RUT
                     HAVING COUNT (*) >= 3))
            
MINUS             
(SELECT RUT,TELEFONO AS "Telefono", DIRECCION AS "Direccion" 
FROM CLIENTE 
WHERE RUT IN (SELECT cli.RUT
              FROM CLIENTE cli
              JOIN PRODUCTO prod ON prod.RUT = cli.RUT
              JOIN FACTURA fac ON fac.CODPROD = prod.CODPROD
              GROUP BY cli.RUT
              HAVING COUNT(*) <> (SELECT MAX(COUNT(*))
                                  FROM CLIENTE cli
                                  JOIN PRODUCTO prod ON prod.RUT = cli.RUT
                                  JOIN FACTURA fac ON fac.CODPROD = prod.CODPROD
                                  GROUP BY cli.RUT)));
                                  
---------------------------------------------------------------------------------------------------------
/*
CONSULTA 8

Obtener los datos de los clientes que han registrado al menos un producto de cada tipo, tomando
en cuenta solo los tipos de productos de los registros dentro de los 2 primeros años de la
actividad del cliente en la empresa.
*/
                                        
SELECT cli.RUT, cli.RAZONSOCIAL AS "Razon social", cli.TELEFONO AS "Telefono", cli.DIRECCION AS "Direccion", cli.FCHING AS "Fecha de ingreso"
FROM CLIENTE cli
JOIN PRODUCTO prod ON prod.RUT = cli.RUT
WHERE prod.TIPO IN (SELECT DISTINCT prod3.TIPO
                    FROM PRODUCTO prod3
                    JOIN CLIENTE cli3 ON cli3.RUT = prod3.RUT
                    WHERE cli3.RUT = cli.RUT AND
                          prod3.FDESDE BETWEEN cli3.FCHING AND ADD_MONTHS(cli3.FCHING, 24))
GROUP BY cli.RUT, cli.RAZONSOCIAL, cli.TELEFONO, cli.DIRECCION, cli.FCHING
HAVING COUNT (DISTINCT prod.TIPO) = (SELECT COUNT (DISTINCT prod1.TIPO)
                                      FROM PRODUCTO prod1
                                      JOIN CLIENTE cli2 ON cli2.RUT = prod1.RUT
                                      WHERE prod1.FDESDE BETWEEN (SELECT MIN(FDESDE) FROM PRODUCTO) AND ADD_MONTHS(cli2.FCHING, 24));
                                      
---------------------------------------------------------------------------------------------------------
/*
CONSULTA 9

Obtener los tipos de productos que han permanecido en los galpones de la empresa por la mayor
cantidad de dias. Tener en cuenta solo los tipos que pertenezcan a productos que tengan al
menos 3 facturas y un importe facturado acumulado de al menos 10.000. Excluir del calculo a
los tipos de los productos que alguna vez hayan sido registrados por clientes con menos de 2
años de antiguedad. Mostrar la cantidad de dias.
*/

SELECT prod.TIPO AS "Tipo de producto", TRUNC(SUM(NVL(prod.FHASTA,SYSDATE) - prod.FDESDE),0)  AS "Cantidad de dias"
FROM PRODUCTO prod
JOIN ALMACENA almac ON almac.CODPROD = prod.CODPROD
WHERE prod.TIPO IN ((SELECT DISTINCT prod.TIPO
                     FROM PRODUCTO prod
                     JOIN CLIENTE cli on cli.RUT = prod.RUT
                     WHERE ADD_MONTHS(cli.FCHING, 24) < SYSDATE)
                     
                     MINUS
                     
                     ((SELECT DISTINCT TIPO
                      FROM PRODUCTO
                      WHERE CODPROD IN (SELECT prod.CODPROD
                                        FROM PRODUCTO prod
                                        JOIN ALMACENA almac ON almac.CODPROD = prod.CODPROD
                                        JOIN FACTURA fac ON fac.CODPROD = prod.CODPROD
                                        GROUP BY prod.CODPROD
                                        HAVING (COUNT(*) < 3) OR (SUM(fac.IMPORTE) < 10000)))))
GROUP BY prod.TIPO
HAVING TRUNC(SUM(NVL(prod.FHASTA,SYSDATE) - prod.FDESDE),0) =
      (SELECT TRUNC(MAX(SUM(NVL(prod.FHASTA,SYSDATE) - prod.FDESDE)),0)
       FROM PRODUCTO prod
       JOIN ALMACENA almac ON almac.CODPROD = prod.CODPROD
       WHERE prod.TIPO IN ((SELECT DISTINCT prod.TIPO
                            FROM PRODUCTO prod
                            JOIN CLIENTE cli on cli.RUT = prod.RUT
                            WHERE ADD_MONTHS(cli.FCHING, 24) < SYSDATE)
                             
                            MINUS
                             
                            ((SELECT DISTINCT TIPO
                             FROM PRODUCTO
                             WHERE CODPROD IN (SELECT prod.CODPROD
                                               FROM PRODUCTO prod
                                               JOIN ALMACENA almac ON almac.CODPROD = prod.CODPROD
                                               JOIN FACTURA fac ON fac.CODPROD = prod.CODPROD
                                               GROUP BY prod.CODPROD
                                               HAVING (COUNT(*) < 3) OR (SUM(fac.IMPORTE) < 10000)))))
       GROUP BY prod.TIPO);
                  
---------------------------------------------------------------------------------------------------------
/*
CONSULTA 10

Obtener para las estaciones de verano e invierno, la cantidad de productos registrados a lo largo
de la historia de la empresa, discriminando por cada tipo de producto, mostrando que porcentaje
representa esa cantidad sobre el total de productos registrados en cada estacion. Mostrar ademas
para cada estacion, el cliente que registra la mayor cantidad de productos en dicha estacion,
mostrando su razon social y su fecha de ingreso.
*/
 
((SELECT 'Invierno' AS "Estacion",
       TO_CHAR(total.CANTTOTAL) AS "Cantidad total de productos",
       TO_CHAR(prodInvierno.TIPO) AS "Tipo",
       TO_CHAR(prodInvierno.CANTPORTIPO) AS "Cantidad de productos por tipo",
       TO_CHAR((prodInvierno.CANTPORTIPO / total.CANTTOTAL)*100) AS "Porcentaje",
       TO_CHAR(cliMaxProd.RAZONSOC) AS "Razon social",
       TO_CHAR(cliMaxProd.FCHING) AS "Fecha Ingreso"
FROM (SELECT prod.TIPO AS TIPO, COUNT(*) AS CANTPORTIPO
      FROM PRODUCTO prod
      WHERE (((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
            (EXTRACT(MONTH FROM prod.FDESDE) > 6 AND EXTRACT(MONTH FROM prod.FHASTA) < 9) OR
            (EXTRACT(MONTH FROM prod.FDESDE) = 6 AND EXTRACT(DAY FROM prod.FDESDE) >= 21) OR
            (EXTRACT(MONTH FROM prod.FHASTA) = 9 AND EXTRACT(DAY FROM prod.FHASTA) < 21) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) > 6 )) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) = 6 ) AND EXTRACT(DAY FROM prod.FHASTA) >= 21))))
            OR
            ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) > 1))
            OR
            ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 1) AND
            ((EXTRACT(MONTH FROM prod.FDESDE) < 9) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) = 9) AND (EXTRACT(DAY FROM prod.FDESDE)<21)) OR
            (EXTRACT(MONTH FROM prod.FHASTA) > 6) OR
            ((EXTRACT(MONTH FROM prod.FHASTA) = 6) AND (EXTRACT(DAY FROM prod.FHASTA)> 21)))))
      GROUP BY prod.TIPO) prodInvierno
      
      CROSS JOIN 
      
      (SELECT COUNT(*) AS CANTTOTAL
      FROM PRODUCTO prod
      WHERE (((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
            (EXTRACT(MONTH FROM prod.FDESDE) > 6 AND EXTRACT(MONTH FROM prod.FHASTA) < 9) OR
            (EXTRACT(MONTH FROM prod.FDESDE) = 6 AND EXTRACT(DAY FROM prod.FDESDE) >= 21) OR
            (EXTRACT(MONTH FROM prod.FHASTA) = 9 AND EXTRACT(DAY FROM prod.FHASTA) < 21) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) > 6 )) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) = 6 ) AND EXTRACT(DAY FROM prod.FHASTA) >= 21))))
            OR
            ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) > 1))
            OR
            ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 1) AND
            ((EXTRACT(MONTH FROM prod.FDESDE) < 9) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) = 9) AND (EXTRACT(DAY FROM prod.FDESDE)<21)) OR
            (EXTRACT(MONTH FROM prod.FHASTA) > 6) OR
            ((EXTRACT(MONTH FROM prod.FHASTA) = 6) AND (EXTRACT(DAY FROM prod.FHASTA)>= 21)))))) total
            
      CROSS JOIN 
      
      (SELECT cli.RAZONSOCIAL AS RAZONSOC, cli.FCHING AS FCHING
      FROM PRODUCTO prod
      JOIN CLIENTE cli ON cli.RUT = prod.RUT
      WHERE (((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
            (EXTRACT(MONTH FROM prod.FDESDE) > 6 AND EXTRACT(MONTH FROM prod.FHASTA) < 9) OR
            (EXTRACT(MONTH FROM prod.FDESDE) = 6 AND EXTRACT(DAY FROM prod.FDESDE) >= 21) OR
            (EXTRACT(MONTH FROM prod.FHASTA) = 9 AND EXTRACT(DAY FROM prod.FHASTA) < 21) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) > 6 )) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) = 6 ) AND EXTRACT(DAY FROM prod.FHASTA) >= 21))))
            OR
            ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) > 1))
            OR
            ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 1) AND
            ((EXTRACT(MONTH FROM prod.FDESDE) < 9) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) = 9) AND (EXTRACT(DAY FROM prod.FDESDE)<21)) OR
            (EXTRACT(MONTH FROM prod.FHASTA) > 6) OR
            ((EXTRACT(MONTH FROM prod.FHASTA) = 6) AND (EXTRACT(DAY FROM prod.FHASTA)>= 21)))))
      GROUP BY cli.RAZONSOCIAL, cli.FCHING
      HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                         FROM PRODUCTO prod
                         JOIN CLIENTE cli ON cli.RUT = prod.RUT
                         WHERE (((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
                               (EXTRACT(MONTH FROM prod.FDESDE) > 6 AND EXTRACT(MONTH FROM prod.FHASTA) < 9) OR
                               (EXTRACT(MONTH FROM prod.FDESDE) = 6 AND EXTRACT(DAY FROM prod.FDESDE) >= 21) OR
                               (EXTRACT(MONTH FROM prod.FHASTA) = 9 AND EXTRACT(DAY FROM prod.FHASTA) < 21) OR
                               ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) > 6 )) OR
                               ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) = 6 ) AND EXTRACT(DAY FROM prod.FHASTA) >= 21))))
                               OR
                               ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) > 1))
                               OR
                               ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 1) AND
                               ((EXTRACT(MONTH FROM prod.FDESDE) < 9) OR
                               ((EXTRACT(MONTH FROM prod.FDESDE) = 9) AND (EXTRACT(DAY FROM prod.FDESDE)<21)) OR
                               (EXTRACT(MONTH FROM prod.FHASTA) > 6) OR
                               ((EXTRACT(MONTH FROM prod.FHASTA) = 6) AND (EXTRACT(DAY FROM prod.FHASTA)>= 21)))))
                         GROUP BY cli.RAZONSOCIAL)) cliMaxProd)
                         
UNION ALL

(SELECT 'Invierno' AS "Estacion",
        '0' AS "Cantidad total de productos",
        'Sin datos' AS "Tipo",
        '0' AS "Cantidad de productos por tipo",
        '0' AS "Porcentaje",
        'Sin datos' AS "Razon social",
        'Sin datos' AS "Fecha Ingreso"
 FROM dual
 WHERE NOT EXISTS (SELECT prod.CODPROD
                   FROM PRODUCTO prod
                   WHERE (((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
                           (EXTRACT(MONTH FROM prod.FDESDE) > 6 AND EXTRACT(MONTH FROM prod.FHASTA) < 9) OR
                           (EXTRACT(MONTH FROM prod.FDESDE) = 6 AND EXTRACT(DAY FROM prod.FDESDE) >= 21) OR
                           (EXTRACT(MONTH FROM prod.FHASTA) = 9 AND EXTRACT(DAY FROM prod.FHASTA) < 21) OR
                         ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) > 6 )) OR
                         ((EXTRACT(MONTH FROM prod.FDESDE) < 6) AND ((EXTRACT(MONTH FROM prod.FHASTA) = 6 ) AND EXTRACT(DAY FROM prod.FHASTA) >= 21))))
                         OR
                         ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) > 1))
                         OR
                         ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 1) AND
                         ((EXTRACT(MONTH FROM prod.FDESDE) < 9) OR
                         ((EXTRACT(MONTH FROM prod.FDESDE) = 9) AND (EXTRACT(DAY FROM prod.FDESDE)<21)) OR
                         (EXTRACT(MONTH FROM prod.FHASTA) > 6) OR
                         ((EXTRACT(MONTH FROM prod.FHASTA) = 6) AND (EXTRACT(DAY FROM prod.FHASTA)>= 21))))))))
                         
UNION

((SELECT 'Verano' AS "Estacion",
       TO_CHAR(total.CANTTOTAL) AS "Cantidad total de productos",
       TO_CHAR(prodVerano.TIPO) AS "Tipo",
       TO_CHAR(prodVerano.CANTPORTIPO) AS "Cantidad de productos por tipo",
       TO_CHAR((prodVerano.CANTPORTIPO / total.CANTTOTAL)*100) AS "Porcentaje",
       TO_CHAR(cliMaxProd.RAZONSOC) AS "Razon social",
       TO_CHAR(cliMaxProd.FCHING) AS "Fecha Ingreso"
FROM (SELECT prod.TIPO AS TIPO, COUNT(*) AS CANTPORTIPO
      FROM PRODUCTO prod
      WHERE ((((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
            (EXTRACT(MONTH FROM prod.FDESDE) < 3) OR
            (EXTRACT(MONTH FROM prod.FDESDE) = 3 AND EXTRACT(DAY FROM prod.FDESDE) < 21) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) = 12) AND (EXTRACT(DAY FROM prod.FDESDE) >= 21))) OR
            ((EXTRACT(MONTH FROM prod.FHASTA) = 12) AND (EXTRACT(DAY FROM prod.FHASTA) >= 21)))
            OR
            ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) >= 1)))
      GROUP BY prod.TIPO) prodVerano
      
      CROSS JOIN 
      
      (SELECT COUNT(*) AS CANTTOTAL
      FROM PRODUCTO prod
      WHERE ((((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
            (EXTRACT(MONTH FROM prod.FDESDE) < 3) OR
            (EXTRACT(MONTH FROM prod.FDESDE) = 3 AND EXTRACT(DAY FROM prod.FDESDE) < 21) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) = 12) AND (EXTRACT(DAY FROM prod.FDESDE) >= 21))) OR
            ((EXTRACT(MONTH FROM prod.FHASTA) = 12) AND (EXTRACT(DAY FROM prod.FHASTA) >= 21)))
            OR
            ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) >= 1)))) total
            
      CROSS JOIN 
      
      (SELECT cli.RAZONSOCIAL AS RAZONSOC, cli.FCHING AS FCHING
      FROM PRODUCTO prod
      JOIN CLIENTE cli ON cli.RUT = prod.RUT
      WHERE ((((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
            (EXTRACT(MONTH FROM prod.FDESDE) < 3) OR
            (EXTRACT(MONTH FROM prod.FDESDE) = 3 AND EXTRACT(DAY FROM prod.FDESDE) < 21) OR
            ((EXTRACT(MONTH FROM prod.FDESDE) = 12) AND (EXTRACT(DAY FROM prod.FDESDE) >= 21))) OR
            ((EXTRACT(MONTH FROM prod.FHASTA) = 12) AND (EXTRACT(DAY FROM prod.FHASTA) >= 21)))
            OR
            ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) >= 1)))
      GROUP BY cli.RAZONSOCIAL, cli.FCHING
      HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                         FROM PRODUCTO prod
                         JOIN CLIENTE cli ON cli.RUT = prod.RUT
                         WHERE ((((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
                               (EXTRACT(MONTH FROM prod.FDESDE) < 3) OR
                               (EXTRACT(MONTH FROM prod.FDESDE) = 3 AND EXTRACT(DAY FROM prod.FDESDE) < 21) OR
                               ((EXTRACT(MONTH FROM prod.FDESDE) = 12) AND (EXTRACT(DAY FROM prod.FDESDE) >= 21))) OR
                               ((EXTRACT(MONTH FROM prod.FHASTA) = 12) AND (EXTRACT(DAY FROM prod.FHASTA) >= 21)))
                               OR
                               ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) >= 1)))
                         GROUP BY cli.RAZONSOCIAL)) cliMaxProd)
UNION ALL

((SELECT 'Verano' AS "Estacion",
        '0' AS "Cantidad total de productos",
        'Sin datos' AS "Tipo",
        '0' AS "Cantidad de productos por tipo",
        '0' AS "Porcentaje",
        'Sin datos' AS "Razon social",
        'Sin datos' AS "Fecha Ingreso"
 FROM dual
 WHERE NOT EXISTS (SELECT prod.CODPROD
                   FROM PRODUCTO prod
                   WHERE ((((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) = 0) AND
                               (EXTRACT(MONTH FROM prod.FDESDE) < 3) OR
                               (EXTRACT(MONTH FROM prod.FDESDE) = 3 AND EXTRACT(DAY FROM prod.FDESDE) < 21) OR
                               ((EXTRACT(MONTH FROM prod.FDESDE) = 12) AND (EXTRACT(DAY FROM prod.FDESDE) >= 21))) OR
                               ((EXTRACT(MONTH FROM prod.FHASTA) = 12) AND (EXTRACT(DAY FROM prod.FHASTA) >= 21)))
                               OR
                               ((EXTRACT(YEAR FROM prod.FHASTA) - EXTRACT(YEAR FROM prod.FDESDE) >= 1)))))));
          