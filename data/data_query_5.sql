ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';
DROP TABLE FACTURA;
DROP TABLE ALMACENA;
DROP TABLE ESTANTE;
DROP TABLE GALPON;
DROP TABLE PRODUCTO;
DROP TABLE CLIENTE;

CREATE TABLE CLIENTE( 
RUT NUMBER(5) NOT NULL CONSTRAINT CLIENTE_pk PRIMARY KEY, 
RAZONSOCIAL VARCHAR2(120) CONSTRAINT CLIENTE_Ak UNIQUE NOT NULL, 
TELEFONO NUMBER(30) NOT NULL, 
DIRECCION VARCHAR2(80) NOT NULL, 
FCHING DATE NOT NULL);

CREATE TABLE PRODUCTO( 
CODPROD NUMBER(5) NOT NULL CONSTRAINT PRODUCTO_pk PRIMARY KEY, 
DESCRIPCION VARCHAR2(100) NOT NULL, 
RUT NUMBER(5) NOT NULL CONSTRAINT PRODUCTO_TO_CLIENTE_FK REFERENCES CLIENTE, 
FDESDE DATE NOT NULL,
FHASTA DATE,
PRECIO NUMBER(5) NOT NULL,
TIPO VARCHAR2(100) NOT NULL);

CREATE TABLE GALPON( 
NOMBRE VARCHAR2(100) NOT NULL CONSTRAINT GALPON_pk PRIMARY KEY,
SUPERFICIE NUMBER(10) NOT NULL);

CREATE TABLE ESTANTE( 
NOMBRE VARCHAR2(100) NOT NULL CONSTRAINT ESTANTE_TO_GALPON_FK REFERENCES GALPON,
FILA NUMBER(5) NOT NULL,
NUMESTANTE NUMBER(5) NOT NULL,
CONSTRAINT ESTANTE_Pk PRIMARY KEY(NOMBRE, FILA, NUMESTANTE));

CREATE TABLE ALMACENA( 
NOMBRE VARCHAR2(100) NOT NULL,
FILA NUMBER(5) NOT NULL,
NUMESTANTE NUMBER(5) NOT NULL,
CODPROD NUMBER(5) NOT NULL CONSTRAINT ALMACENA_TO_PRODUCTO_FK REFERENCES PRODUCTO, 
CONSTRAINT ALMACENA_Pk PRIMARY KEY(NOMBRE, FILA, NUMESTANTE, CODPROD),
CONSTRAINT ALM_TO_EST_FK FOREIGN KEY(NOMBRE, FILA, NUMESTANTE) REFERENCES ESTANTE (NOMBRE, FILA, NUMESTANTE));

CREATE TABLE FACTURA( 
NUMFAC NUMBER(5) NOT NULL CONSTRAINT FACTURA_pk PRIMARY KEY, 
CODPROD NUMBER(5) NOT NULL CONSTRAINT FACTURA_TO_PRODUCTO_FK REFERENCES PRODUCTO,
FECHA DATE NOT NULL,
IMPORTE NUMBER(10) NOT NULL,
FCHVENCIMIENTO DATE NOT NULL);

INSERT INTO CLIENTE VALUES ('50001','Logística y Distribución','22324546','Yaguaron 2014',to_date('15/02/16','DD/MM/RR'));
INSERT INTO CLIENTE VALUES ('50002','INFORMATIC','23241414','Yi 2340',to_date('24/01/16','DD/MM/RR'));
INSERT INTO CLIENTE VALUES ('50003','Infolab S.A','23124124','Lezica 2424',to_date('30/10/14','DD/MM/RR'));
INSERT INTO CLIENTE VALUES ('50004','Serviclean','23240198','HAITI 1609',to_date('15/02/16','DD/MM/RR'));
INSERT INTO CLIENTE VALUES ('50005','PUNTOLUK','23242424','Ciudadela 2014',to_date('10/04/16','DD/MM/RR'));


INSERT INTO PRODUCTO VALUES ('1','MONITOR','50002',to_date('01/03/16','DD/MM/RR'),to_date('20/06/16','DD/MM/RR'),'5000','INFORMÁTICA');
INSERT INTO PRODUCTO VALUES ('2','MOUSE','50002',to_date('15/03/16','DD/MM/RR'),to_date('10/05/16','DD/MM/RR'),'2000','INFORMÁTICA');
INSERT INTO PRODUCTO VALUES ('3','IMPRESORA','50002',to_date('10/01/16','DD/MM/RR'),to_date('30/06/16','DD/MM/RR'),'3300','INFORMÁTICA');
INSERT INTO PRODUCTO VALUES ('4','LAPTOP','50003',to_date('12/03/16','DD/MM/RR'),to_date('10/04/16','DD/MM/RR'),'1000','INFORMÁTICA');
INSERT INTO PRODUCTO VALUES ('5','IMPRESORA','50001',to_date('10/03/16','DD/MM/RR'),to_date('22/08/16','DD/MM/RR'),'4000','INFORMÁTICA');
INSERT INTO PRODUCTO VALUES ('6','LAPTOP','50001',to_date('09/03/16','DD/MM/RR'),to_date('27/09/16','DD/MM/RR'),'30000','INFORMÁTICA');
INSERT INTO PRODUCTO VALUES ('7','FLORERO','50004',to_date('10/03/16','DD/MM/RR'),to_date('24/04/16','DD/MM/RR'),'20000','BAZAR');
INSERT INTO PRODUCTO VALUES ('8','MANTEL','50004',to_date('02/01/16','DD/MM/RR'),to_date('24/04/16','DD/MM/RR'),'1000','BAZAR');
INSERT INTO PRODUCTO VALUES ('9','BALDE','50005',to_date('10/03/16','DD/MM/RR'),to_date('24/04/16','DD/MM/RR'),'300','LIMPIEZA');

INSERT INTO GALPON VALUES ('LOGÍSTICA DEL NORTE','200000');
INSERT INTO GALPON VALUES ('LOGÍSTICA DEL SUR','100000');
INSERT INTO GALPON VALUES ('LOGÍSTICA DEL ESTE','20000');

INSERT INTO ESTANTE VALUES ('LOGÍSTICA DEL ESTE','1','1');
INSERT INTO ESTANTE VALUES ('LOGÍSTICA DEL ESTE','1','2');
INSERT INTO ESTANTE VALUES ('LOGÍSTICA DEL ESTE','1','3');
INSERT INTO ESTANTE VALUES ('LOGÍSTICA DEL NORTE','1','1');
INSERT INTO ESTANTE VALUES ('LOGÍSTICA DEL NORTE','1','2');
INSERT INTO ESTANTE VALUES ('LOGÍSTICA DEL NORTE','1','3');
INSERT INTO ESTANTE VALUES ('LOGÍSTICA DEL SUR','1','1');
INSERT INTO ESTANTE VALUES ('LOGÍSTICA DEL SUR','1','2');
INSERT INTO ESTANTE VALUES ('LOGÍSTICA DEL SUR','1','3');

INSERT INTO ALMACENA VALUES ('LOGÍSTICA DEL ESTE','1','1','3');
INSERT INTO ALMACENA VALUES ('LOGÍSTICA DEL ESTE','1','2','9');
INSERT INTO ALMACENA VALUES ('LOGÍSTICA DEL NORTE','1','1','1');
INSERT INTO ALMACENA VALUES ('LOGÍSTICA DEL NORTE','1','1','4');
INSERT INTO ALMACENA VALUES('LOGÍSTICA DEL NORTE','1','1','7');
INSERT INTO ALMACENA VALUES ('LOGÍSTICA DEL NORTE','1','3','5');
INSERT INTO ALMACENA VALUES ('LOGÍSTICA DEL SUR','1','1','2');
INSERT INTO ALMACENA VALUES ('LOGÍSTICA DEL SUR','1','2','6');
INSERT INTO ALMACENA VALUES ('LOGÍSTICA DEL SUR','1','3','8');

COMMIT; 