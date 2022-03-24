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

IF EXISTS ( SELECT  *
                FROM    sys.schemas
                WHERE   name = N'COURS' )
    EXEC('DROP SCHEMA [COURS]');
GO