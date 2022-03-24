--> préalable
-- USE BD_Air_France;

IF NOT EXISTS ( SELECT  *
                FROM    sys.schemas
                WHERE   name = N'COURS' )
    EXEC('CREATE SCHEMA [COURS]');
GO


IF OBJECT_ID('COURS.T_qualifs_qlf','U') IS NOT NULL
   DROP TABLE COURS.T_qualifs_qlf;
GO
IF OBJECT_ID('COURS.T_pilote_pil','U') IS NOT NULL
   DROP TABLE COURS.T_pilote_pil;
GO
IF OBJECT_ID('COURS.T_compagnie_cmp','U') IS NOT NULL
   DROP TABLE COURS.T_compagnie_cmp;
GO
IF OBJECT_ID('COURS.T_avion_avi','U') IS NOT NULL
   DROP TABLE COURS.T_avion_avi;
GO


CREATE TABLE COURS.T_avion_avi
(avi_immat VARCHAR(6), avi_type CHAR(4), avi_hvol DECIMAL(7,2), cmp_comp VARCHAR(4));

CREATE TABLE COURS.T_compagnie_cmp
(cmp_comp VARCHAR(4), cmp_pays CHAR(3), cmp_nom VARCHAR(15),
 CONSTRAINT pk_compagnie PRIMARY KEY(cmp_comp));
GO

CREATE TABLE COURS.T_pilote_pil
(pil_brevet VARCHAR(6), pil_prenom VARCHAR(15), pil_nom VARCHAR(15), 
 pil_hvol DECIMAL(7,2), cmp_comp VARCHAR(4), pil_chef VARCHAR(6),
 CONSTRAINT pk_pilote PRIMARY KEY(pil_brevet),
 CONSTRAINT fk_pil_cmp FOREIGN KEY(cmp_comp) REFERENCES COURS.T_compagnie_cmp(cmp_comp),
 CONSTRAINT fk_pil_chef_pil FOREIGN KEY(pil_chef) REFERENCES COURS.T_pilote_pil(pil_brevet));
GO



INSERT INTO COURS.T_compagnie_cmp VALUES ('AF', 'fr', 'Air France');
INSERT INTO COURS.T_compagnie_cmp VALUES ('SING','sn', 'Singapore AL');
INSERT INTO COURS.T_compagnie_cmp VALUES ('CAST', 'fr', 'Castanet AL');


INSERT INTO COURS.T_pilote_pil VALUES ('PL-4', 'Henri','Alquié', 3400, 'AF', NULL);
INSERT INTO COURS.T_pilote_pil VALUES ('PL-1', 'Pierre','Lamothe', 450, 'AF','PL-4');
INSERT INTO COURS.T_pilote_pil VALUES ('PL-2', 'Didier','Linxe', 900, 'AF','PL-4');
INSERT INTO COURS.T_pilote_pil VALUES ('PL-3', 'Michel','Castaings', 1000, 'SING', NULL);
INSERT INTO COURS.T_pilote_pil VALUES ('PL-5', 'Pascal','Larrazet', 1500,NULL,NULL);


INSERT INTO COURS.T_avion_avi VALUES ('F-HVFR', 'A320', 1000, 'AF');
INSERT INTO COURS.T_avion_avi VALUES ('F-HRXM', 'A330', 1500, 'AF');
INSERT INTO COURS.T_avion_avi VALUES ('G-YGTR', 'A320', 550, 'SING');
INSERT INTO COURS.T_avion_avi VALUES ('N-345R', 'A340', 1800, 'SING');
INSERT INTO COURS.T_avion_avi VALUES ('F-GADE', 'A340', 200, 'AF');
INSERT INTO COURS.T_avion_avi VALUES ('F-HYZE', 'A330', 100, 'AF');



SELECT pil_brevet, pil_prenom, pil_nom
FROM   COURS.T_pilote_pil 
WHERE  cmp_comp =
   (SELECT cmp_comp
    FROM   COURS.T_compagnie_cmp
    WHERE  cmp_nom = 'Air France')
AND pil_hvol > 500;

SELECT pil_brevet,
       pil_nom, pil_hvol
FROM   COURS.T_pilote_pil
WHERE pil_hvol > 
    (SELECT pil_hvol 
     FROM COURS.T_pilote_pil WHERE pil_brevet = 'PL-2');



-- multi-lignes

SELECT  cmp_nom, cmp_pays
FROM    COURS.T_compagnie_cmp
WHERE   cmp_comp  IN
(SELECT  cmp_comp FROM COURS.T_pilote_pil
WHERE   pil_hvol > 950);

SELECT SUM(pil_hvol) AS "Total"
FROM   COURS.T_pilote_pil
WHERE  pil_chef IN 
(SELECT pil_brevet
 FROM   COURS.T_pilote_pil 
 WHERE  cmp_comp = 
 (SELECT cmp_comp
  FROM   COURS.T_compagnie_cmp
  WHERE  cmp_nom = 'Air France'));

SELECT   cmp_nom, cmp_pays
FROM     COURS.T_compagnie_cmp
WHERE    cmp_comp IN (SELECT cmp_comp FROM COURS.T_pilote_pil WHERE cmp_comp IS NOT NULL);

-- false retourné car un NULL...

SELECT   cmp_nom, cmp_pays
FROM     COURS.T_compagnie_cmp
WHERE    cmp_comp NOT IN (SELECT cmp_comp FROM COURS.T_pilote_pil);

SELECT   cmp_nom, cmp_pays
FROM     COURS.T_compagnie_cmp
WHERE    cmp_comp NOT IN (SELECT cmp_comp FROM COURS.T_pilote_pil WHERE cmp_comp IS NOT NULL);


-- ANY et ALL

SELECT avi_immat, avi_type, avi_hvol
FROM   COURS.T_avion_avi 
WHERE  avi_hvol <  ANY (SELECT avi_hvol FROM T_avion_avi WHERE avi_type='A320');

SELECT  avi_immat, avi_type, avi_hvol, cmp_comp
FROM    COURS.T_avion_avi 
WHERE   avi_hvol > ANY (SELECT avi_hvol FROM COURS.T_avion_avi WHERE cmp_comp= 'SING');

SELECT  avi_immat, avi_type, avi_hvol
FROM    COURS.T_avion_avi 
WHERE   avi_hvol < ALL (SELECT avi_hvol FROM COURS.T_avion_avi WHERE avi_type='A320');


SELECT  avi_immat, avi_type, avi_hvol, cmp_comp
FROM    COURS.T_avion_avi 
WHERE avi_hvol > ALL (SELECT avi_hvol FROM COURS.T_avion_avi WHERE cmp_comp= 'AF');

-- sous requete clause FROM


SELECT ta.cmp_comp AS "compagnie",
       CAST((CAST(ta.nbcomp AS REAL)/CAST(tb.total AS REAL))*100 
	   AS DECIMAL(4,2)) AS "% avion"
FROM   (SELECT cmp_comp, COUNT(*) nbcomp
        FROM COURS.T_avion_avi GROUP BY cmp_comp)     ta,
       (SELECT COUNT(*) total FROM COURS.T_avion_avi) tb;

-- synchronisé

SELECT t1.avi_immat, t1.avi_type, t1.avi_hvol
FROM   COURS.T_avion_avi t1
WHERE  t1.avi_hvol >
       (SELECT AVG(t2.avi_hvol) FROM COURS.T_avion_avi t2
        WHERE  t2.cmp_comp = t1.cmp_comp);

-- update synchronisé

ALTER TABLE COURS.T_compagnie_cmp 
ADD cmp_nb_avi SMALLINT;
GO

WITH t1 (cmp_comp, cmp_nb_avi) AS 
    (SELECT cmp_comp, cmp_nb_avi
      FROM   COURS.T_compagnie_cmp)
UPDATE t1 
SET    t1.cmp_nb_avi = 
       (SELECT COUNT(t2.avi_immat) FROM COURS.T_avion_avi t2
        WHERE  t2.cmp_comp = t1.cmp_comp);


/**
IF OBJECT_ID('COURS.T_qualifs_qlf','U') IS NOT NULL
   DROP TABLE COURS.T_qualifs_qlf;
GO
IF OBJECT_ID('COURS.T_pilote_pil','U') IS NOT NULL
   DROP TABLE COURS.T_pilote_pil;
GO
IF OBJECT_ID('COURS.T_compagnie_cmp','U') IS NOT NULL
   DROP TABLE COURS.T_compagnie_cmp;
GO
IF OBJECT_ID('COURS.T_avion_avi','U') IS NOT NULL
   DROP TABLE COURS.T_avion_avi;
GO
*/


