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


INSERT INTO CLIENTE VALUES ('60001','PUNTOLUK','2341565','PARAGUAY 4015',to_date('19/10/2016','DD/MM/YYYY'));
INSERT INTO CLIENTE VALUES ('60002','INFORMATIC','2324155','PINTA 2014',to_date('24/11/2016','DD/MM/YYYY'));
INSERT INTO CLIENTE VALUES ('60003','INFOLAB S.A','2301001','CUAREIM 1923',to_date('22/12/2016','DD/MM/YYYY'));

INSERT INTO PRODUCTO VALUES ('1','MONITOR','60001',to_date('10/02/2016','DD/MM/YYYY'),to_date('18/02/2016','DD/MM/YYYY'),'10000','Informática');
INSERT INTO PRODUCTO VALUES ('2','COCINA','60001',to_date('12/02/2016','DD/MM/YYYY'),to_date('20/02/2016','DD/MM/YYYY'),'16000','Electrodoméstico');
INSERT INTO PRODUCTO VALUES ('3','FLORERO','60002',to_date('15/02/2016','DD/MM/YYYY'),to_date('18/02/2016','DD/MM/YYYY'),'200','Bazar');
INSERT INTO PRODUCTO VALUES ('4','MOUSE','60002',to_date('10/02/2016','DD/MM/YYYY'),to_date('20/02/2016','DD/MM/YYYY'),'300','Informática');
INSERT INTO PRODUCTO VALUES ('5','TECLADO','60002',to_date('10/01/2016','DD/MM/YYYY'),to_date('18/03/2016','DD/MM/YYYY'),'440','Informática');
INSERT INTO PRODUCTO VALUES ('6','HELADERA','60003',to_date('15/02/2016','DD/MM/YYYY'),to_date('21/08/2016','DD/MM/YYYY'),'20000','Electrodoméstico');

INSERT INTO GALPON VALUES ('Distribución S.A','50000');
INSERT INTO GALPON VALUES ('Logística del Sur','20000');

INSERT INTO ESTANTE VALUES ('Distribución S.A','1','1');
INSERT INTO ESTANTE VALUES ('Distribución S.A','1','2');
INSERT INTO ESTANTE VALUES ('Logística del Sur','1','1');
INSERT INTO ESTANTE VALUES ('Logística del Sur','1','2');

INSERT INTO ALMACENA VALUES ('Distribución S.A','1','1','2');
INSERT INTO ALMACENA VALUES ('Distribución S.A','1','2','1');
INSERT INTO ALMACENA VALUES ('Distribución S.A','1','2','3');
INSERT INTO ALMACENA VALUES ('Distribución S.A','1','2','6');
INSERT INTO ALMACENA VALUES ('Logística del Sur','1','1','4');
INSERT INTO ALMACENA VALUES ('Logística del Sur','1','1','5');

COMMIT; 