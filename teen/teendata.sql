IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'teendata')
	DROP DATABASE [teendata]
GO

CREATE DATABASE [teendata]  ON (NAME = N'teendata_Data', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL$GORDIN\Data\teendata_data.mdf' , SIZE = 2, FILEGROWTH = 10%) LOG ON (NAME = N'teendata_Log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL$GORDIN\Data\teendata_log.LDF' , FILEGROWTH = 10%)
 COLLATE Cyrillic_General_CI_AS
GO

exec sp_dboption N'teendata', N'autoclose', N'false'
GO

exec sp_dboption N'teendata', N'bulkcopy', N'false'
GO

exec sp_dboption N'teendata', N'trunc. log', N'false'
GO

exec sp_dboption N'teendata', N'torn page detection', N'true'
GO

exec sp_dboption N'teendata', N'read only', N'false'
GO

exec sp_dboption N'teendata', N'dbo use', N'false'
GO

exec sp_dboption N'teendata', N'single', N'false'
GO

exec sp_dboption N'teendata', N'autoshrink', N'false'
GO

exec sp_dboption N'teendata', N'ANSI null default', N'false'
GO

exec sp_dboption N'teendata', N'recursive triggers', N'false'
GO

exec sp_dboption N'teendata', N'ANSI nulls', N'false'
GO

exec sp_dboption N'teendata', N'concat null yields null', N'false'
GO

exec sp_dboption N'teendata', N'cursor close on commit', N'false'
GO

exec sp_dboption N'teendata', N'default to local cursor', N'false'
GO

exec sp_dboption N'teendata', N'quoted identifier', N'false'
GO

exec sp_dboption N'teendata', N'ANSI warnings', N'false'
GO

exec sp_dboption N'teendata', N'auto create statistics', N'true'
GO

exec sp_dboption N'teendata', N'auto update statistics', N'true'
GO

use [teendata]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_trigD_autod]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[sp_trigD_autod]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_trigD_vastisikud]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[sp_trigD_vastisikud]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_calc_svod_saldod]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_calc_svod_saldod]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_change_konto]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_change_konto]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_create_saldo1_tabel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_create_saldo1_tabel]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_create_saldo1_tabel1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_create_saldo1_tabel1]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_create_saldo_tabel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_create_saldo_tabel]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_material_kaibed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_material_kaibed]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_recalc_saldo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_recalc_saldo]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_recalc_saldo1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_recalc_saldo1]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_recalc_saldo2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_recalc_saldo2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_save_copy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_save_copy]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_update_pohikonto_saldo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_update_pohikonto_saldo]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_update_pohikonto_saldo1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_update_pohikonto_saldo1]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_update_saldo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_update_saldo]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[aa]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[aa]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[arv]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[arv]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[arv1]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[arv1]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[arvtasu]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[arvtasu]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[asutus]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[asutus]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[comAuto]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[comAuto]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[comVastIsik]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[comVastIsik]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curAutod]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curAutod]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curJournal]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curJournal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curKoormus]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curKoormus]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curLaduArved]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curLaduArved]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curLaduJaak]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curLaduJaak]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curLepingud]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curLepingud]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curSorder]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curSorder]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curTeenused]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curTeenused]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curTellimus]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curTellimus]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curVastIsikud]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curVastIsikud]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curVorder]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curVorder]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[cur_doklausend]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[cur_doklausend]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curnomJaak]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curnomJaak]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curvara]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curvara]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curvaravaljamine]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curvaravaljamine]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[curvaravendor]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[curvaravendor]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dokprop]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[dokprop]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[journal]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[journal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[journal1]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[journal1]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[journal1tmp]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[journal1tmp]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[journaltmp]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[journaltmp]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[kontoinf]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[kontoinf]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ladu_ULEHIND]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ladu_ULEHIND]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ladu_config]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ladu_config]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ladu_grupp]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ladu_grupp]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ladu_jaak]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ladu_jaak]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ladu_minkogus]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ladu_minkogus]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ladu_oper]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ladu_oper]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[lausdok]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[lausdok]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[lausend]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[lausend]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[library]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[library]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nomenklatuur]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[nomenklatuur]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[raamat]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[raamat]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rekv]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[rekv]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sorder1]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[sorder1]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sorder2]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[sorder2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[userid]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[userid]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vorder1]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[vorder1]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vorder2]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[vorder2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[arv3]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[arv3]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[autod]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[autod]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[markused]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[markused]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tellimus]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tellimus]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vastisikud]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[vastisikud]
GO

if not exists (select * from dbo.sysusers where name = N'DBKASUTAJA' and uid > 16399)
	EXEC sp_addrole N'DBKASUTAJA'
GO

if not exists (select * from dbo.sysusers where name = N'dbpeakasutaja' and uid > 16399)
	EXEC sp_addrole N'dbpeakasutaja'
GO

if not exists (select * from dbo.sysusers where name = N'dbadmin' and uid > 16399)
	EXEC sp_addrole N'dbadmin'
GO

CREATE TABLE [dbo].[arv3] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[arvId] [int] NOT NULL ,
	[arv1id] [int] NOT NULL ,
	[autoid] [int] NOT NULL ,
	[isikid] [int] NOT NULL ,
	[lastupd] [timestamp] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[autod] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[omanikId] [int] NOT NULL ,
	[mark] [varchar] (254) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[regnum] [varchar] (12) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[idkood] [varchar] (11) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[tuubikood] [varchar] (40) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[vinkood] [varchar] (40) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[mootor] [varchar] (40) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[aasta] [smallint] NOT NULL ,
	[voimsus] [smallint] NOT NULL ,
	[kindlustus] [varchar] (40) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[kindlaeg] [datetime] NOT NULL ,
	[saadetud] [varchar] (40) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[status] [smallint] NOT NULL ,
	[muud] [text] COLLATE Cyrillic_General_CI_AS NULL ,
	[lastupd] [timestamp] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[markused] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[autoid] [int] NOT NULL ,
	[kuupaev] [datetime] NOT NULL ,
	[nimetus] [text] COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[status] [smallint] NOT NULL ,
	[muud] [text] COLLATE Cyrillic_General_CI_AS NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[tellimus] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[rekvid] [int] NOT NULL ,
	[kpv] [datetime] NOT NULL ,
	[aeg] [decimal](18, 3) NOT NULL ,
	[regnum] [varchar] (50) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[omanik] [varchar] (254) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[too] [text] COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[meister] [text] COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[status] [smallint] NOT NULL ,
	[timestamp] [timestamp] NULL ,
	[muud] [text] COLLATE Cyrillic_General_CI_AS NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[vastisikud] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[isikId] [int] NOT NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tellimus] WITH NOCHECK ADD 
	CONSTRAINT [PK_tellimus] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[vastisikud] WITH NOCHECK ADD 
	CONSTRAINT [IX_vastisikud] UNIQUE  CLUSTERED 
	(
		[isikId]
	)  ON [PRIMARY] 
GO

 CREATE  CLUSTERED  INDEX [IX_arv3] ON [dbo].[arv3]([arvId]) ON [PRIMARY]
GO

 CREATE  CLUSTERED  INDEX [IX_autod] ON [dbo].[autod]([omanikId]) ON [PRIMARY]
GO

 CREATE  CLUSTERED  INDEX [IX_markused] ON [dbo].[markused]([autoid]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[arv3] WITH NOCHECK ADD 
	CONSTRAINT [DF_arv3_arv1id] DEFAULT (0) FOR [arv1id],
	CONSTRAINT [DF_arv3_autoid] DEFAULT (0) FOR [autoid],
	CONSTRAINT [DF_arv3_isikid] DEFAULT (0) FOR [isikid],
	CONSTRAINT [PK_arv3] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[autod] WITH NOCHECK ADD 
	CONSTRAINT [DF_autod_mark] DEFAULT (space(1)) FOR [mark],
	CONSTRAINT [DF_autod_regnum] DEFAULT (space(1)) FOR [regnum],
	CONSTRAINT [DF_autod_idkood] DEFAULT (space(1)) FOR [idkood],
	CONSTRAINT [DF_autod_tuubikood] DEFAULT (space(1)) FOR [tuubikood],
	CONSTRAINT [DF_autod_vinkood] DEFAULT (space(1)) FOR [vinkood],
	CONSTRAINT [DF_autod_mootor] DEFAULT (space(1)) FOR [mootor],
	CONSTRAINT [DF_autod_aasta] DEFAULT (2000) FOR [aasta],
	CONSTRAINT [DF_autod_voimsus] DEFAULT (100) FOR [voimsus],
	CONSTRAINT [DF_autod_kindlustus] DEFAULT (space(1)) FOR [kindlustus],
	CONSTRAINT [DF_autod_kindlaeg] DEFAULT (getdate()) FOR [kindlaeg],
	CONSTRAINT [DF_autod_saadetud] DEFAULT (space(1)) FOR [saadetud],
	CONSTRAINT [DF_autod_status] DEFAULT (1) FOR [status],
	CONSTRAINT [PK_autod] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[markused] WITH NOCHECK ADD 
	CONSTRAINT [DF_markused_autoid] DEFAULT (0) FOR [autoid],
	CONSTRAINT [DF_markused_kuupaev] DEFAULT (getdate()) FOR [kuupaev],
	CONSTRAINT [DF_markused_nimetus] DEFAULT (space(1)) FOR [nimetus],
	CONSTRAINT [DF_markused_status] DEFAULT (1) FOR [status],
	CONSTRAINT [PK_markused] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tellimus] WITH NOCHECK ADD 
	CONSTRAINT [DF_tellimus_kpv] DEFAULT (getdate()) FOR [kpv],
	CONSTRAINT [DF_tellimus_aeg] DEFAULT (1) FOR [aeg],
	CONSTRAINT [DF_tellimus_regnum] DEFAULT (space(1)) FOR [regnum],
	CONSTRAINT [DF_tellimus_omanik] DEFAULT (space(1)) FOR [omanik],
	CONSTRAINT [DF_tellimus_too] DEFAULT (space(1)) FOR [too],
	CONSTRAINT [DF_tellimus_meister] DEFAULT (space(1)) FOR [meister],
	CONSTRAINT [DF_tellimus_status] DEFAULT (1) FOR [status]
GO

ALTER TABLE [dbo].[vastisikud] WITH NOCHECK ADD 
	CONSTRAINT [PK_vastisikud] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

 CREATE  INDEX [IX_arv3_1] ON [dbo].[arv3]([isikid]) ON [PRIMARY]
GO

 CREATE  INDEX [IX_arv3_2] ON [dbo].[arv3]([lastupd]) ON [PRIMARY]
GO

 CREATE  INDEX [IX_arv3_3] ON [dbo].[arv3]([autoid]) ON [PRIMARY]
GO

 CREATE  INDEX [IX_autod_1] ON [dbo].[autod]([lastupd]) ON [PRIMARY]
GO

 CREATE  INDEX [IX_tellimus] ON [dbo].[tellimus]([rekvid]) ON [PRIMARY]
GO

 CREATE  INDEX [IX_tellimus_1] ON [dbo].[tellimus]([kpv]) ON [PRIMARY]
GO

 CREATE  INDEX [IX_tellimus_2] ON [dbo].[tellimus]([regnum]) ON [PRIMARY]
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[arv3]  TO [DBKASUTAJA]
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[arv3]  TO [dbpeakasutaja]
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[arv3]  TO [dbadmin]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view aa
as
select * from buhdata5.dbo.aa

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view arv
as
select * from buhdata5.dbo.arv

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view arv1
as
select * from buhdata5.dbo.arv1

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view arvtasu
as
select * from buhdata5.dbo.arvtasu

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view asutus
as
select * from buhdata5.dbo.asutus

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.comAuto
AS
SELECT     autod.id, autod.regnum, asutus.nimetus, autod.omanikId, asutus.rekvid
FROM         autod INNER JOIN    asutus ON autod.omanikId = asutus.id


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.comVastIsik
AS
SELECT     dbo.vastisikud.id, dbo.vastisikud.isikId, dbo.asutus.rekvid, dbo.asutus.nimetus
FROM         dbo.vastisikud INNER JOIN    dbo.asutus ON dbo.vastisikud.isikId = dbo.asutus.id


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW curAutod
AS
SELECT     autod.id, autod.mark, autod.regnum, autod.mootor, autod.aasta, autod.voimsus, autod.vinkood, autod.idkood, 
                      autod.tuubikood, asutus.rekvid, asutus.nimetus, autod.omanikId
FROM         autod INNER JOIN asutus ON autod.omanikid = asutus.id




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view curJournal
as
select * from buhdata5.dbo.curJournal

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE view curKoormus
as
select arv.rekvid, arv.kpv, arv.number, asutus.id as asutusId, asutus.nimetus as asutus,
nom.id as nomId, nom.nimetus as teenus, nom.kood,
arv1.kogus, arv1.summa, 
autod.regnum, autod.mark,
isik.nimetus as isik, isik.id as isikid
from arv inner join arv1 on arv.id = arv1.parentid
inner join arv3 on arv3.arv1id = arv1.id
inner join nomenklatuur nom on nom.id = arv1.nomid
inner join autod on autod.id = arv3.autoid
inner join asutus on arv.asutusid = asutus.id
inner join asutus isik on isik.id = arv3.isikId
where nom.dok = 'ARV'



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[curKoormus]  TO [public]
GO

GRANT  SELECT  ON [dbo].[curKoormus]  TO [dbpeakasutaja]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view curLaduArved
as
select * from buhdata5.dbo.curLaduArved

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE  view curLaduJaak
as
select * from buhdata5.dbo.curLaduJaak


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view curLepingud
as
select * from buhdata5.dbo.curLepingud

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view curSorder
as
select * from buhdata5.dbo.curSorder

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.curTeenused
AS
SELECT     arv.rekvId, arv3.autoid, arv.id, arv.number, vastisikud.id as isikid, isikud.nimetus as vastisik, asutus.id as omanikid, nomenklatuur.id as teenusid, nomenklatuur.nimetus, nomenklatuur.kood, arv1.summa, arv.kpv, autod.regnum, asutus.nimetus AS Asutus
FROM         dbo.arv INNER JOIN
                      dbo.arv1 ON dbo.arv1.parentid = dbo.arv.id INNER JOIN
                      dbo.arv3 ON dbo.arv.id = dbo.arv3.arvId INNER JOIN
                      dbo.asutus ON dbo.arv.asutusid = dbo.asutus.id INNER JOIN
                      dbo.autod ON dbo.arv3.autoid = dbo.autod.id INNER JOIN
                      dbo.nomenklatuur ON dbo.arv1.nomid = dbo.nomenklatuur.id
INNER join vastisikud on arv3.isikId = vastisikud.id 
INNER JOIN ASUTUS ISIKUD ON VASTISIKUD.ISIKID = ISIKUD.ID
WHERE ARV1.NOMID NOT IN (SELECT DISTINCT NOMID FROM LADU_GRUPP)









GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.curTellimus
AS
SELECT     id, rekvid, kpv, DATEPART(hh, kpv) AS tund, DATEPART(mm, kpv) AS minute, aeg, regnum, omanik, too, CAST(meister AS varchar(120)) AS meister, 
                      status
FROM         dbo.tellimus

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.curVastIsikud
AS
SELECT     dbo.vastisikud.isikId, dbo.asutus.rekvid, dbo.asutus.regkood, dbo.asutus.nimetus, dbo.asutus.id, dbo.vastisikud.id AS VastisikId
FROM         dbo.vastisikud INNER JOIN dbo.asutus ON dbo.vastisikud.isikId = dbo.asutus.id


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view curVorder
as
select * from buhdata5.dbo.curVorder

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view cur_doklausend
as
select * from buhdata5.dbo.cur_doklausend

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view curnomJaak
as
select * from buhdata5.dbo.curnomjaak

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view curvara
as
select * from buhdata5.dbo.curVara

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view curvaravaljamine
as
select * from buhdata5.dbo.curvaravaljamine

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view curvaravendor
as
select * from buhdata5.dbo.curvaravendor

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view dokprop	
as
select * from buhdata5.dbo.dokprop

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view journal
as
select * from buhdata5.dbo.journal

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view journal1
as
select * from buhdata5.dbo.journal1

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view journal1tmp
as
select * from buhdata5.dbo.journal1tmp

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view journaltmp
as
select * from buhdata5.dbo.journaltmp

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view kontoinf
as
select * from buhdata5.dbo.kontoinf

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view ladu_ULEHIND	
as
select * from buhdata5.dbo.ladu_ulehind



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view ladu_config
as
select * from buhdata5.dbo.ladu_config

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view ladu_grupp
as
select * from buhdata5.dbo.ladu_grupp

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view ladu_jaak
as
select * from buhdata5.dbo.ladu_jaak

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view ladu_minkogus
as
select * from buhdata5.dbo.ladu_minkogus



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view ladu_oper
as
select * from buhdata5.dbo.ladu_oper

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view lausdok
as
select * from buhdata5.dbo.lausdok

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view lausend
as
select * from buhdata5.dbo.lausend

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view library
as
select * from buhdata5.dbo.library

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view nomenklatuur
as
select * from buhdata5.dbo.nomenklatuur

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view raamat
as
select * from buhdata5.dbo.raamat

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view rekv
as
select * from buhdata5.dbo.rekv

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view sorder1
as
select * from buhdata5.dbo.sorder1

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view sorder2
as
select * from buhdata5.dbo.sorder2

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view userid
as
select * from buhdata5.dbo.userid

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view vorder1
as
select * from buhdata5.dbo.vorder2

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view vorder2
as
select * from buhdata5.dbo.vorder2

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_calc_svod_saldod
@rekvId		int,
@kuu			int,
@aasta			int,
@konto		varchar(20)
AS
declare 	@saldoId	int,
	@kpv		datetime,
	@kood		varchar(20),
	@algsaldo	money,
	@dbkaibed 	money,
	@krkaibed	money,
	@pohikonto	varchar
select @pohikonto = kood  from library inner join kontoinf on kontoinf.parentId = library.id 
	where left ( kood, 3) = left ( @konto , 3)  and kontoinf.liik = 2 and kontoinf.aasta = @aasta
set @pohikonto = isnull ( @pohikonto, space(1))
if len ( ltrim ( rtrim ( @pohikonto) )  ) > 1
	begin 
		select @algsaldo = sum ( saldo ) , @dbkaibed = sum ( dbkaibed ) , @krkaibed = sum ( krkaibed ) 
			from saldo
		where konto in (  select kood 
			from library inner join kontoinf on kontoinf.parentId = library.id 
			where left ( kood, 3) = left ( @konto , 3)  and kontoinf.liik = 3 and kontoinf.aasta = @aasta )
		set @algsaldo = isnull ( @algsaldo , 0)
		set @dbkaibed = isnull ( @dbkaibed , 0)
		set @krkaibed = isnull ( @krkaibed, 0)
		update saldo set 
			saldo = @algsaldo,
			dbkaibed = @dbkaibed,
			krkaibed = @krkaibed
			where konto = @konto
	end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_change_konto 
@vanakonto 	varchar( 20 ),
@uuskonto	varchar ( 20 ) 
AS
declare @liik	int,
	@count	int
select @liik = liik from library inner join kontoinf on kontoinf.parentid = library.id where ltrim ( rtrim ( library.kood ) )  = ltrim ( rtrim ( @uuskonto ) )
set @liik = isnull(@liik,0)
if @liik = 2 	
	begin
		update kontoinf set pohikonto = @uuskonto where ltrim ( rtrim ( pohikonto) )  = ltrim ( rtrim ( @vanakonto) ) 
	end
update saldo set konto = @uuskonto where ltrim ( rtrim ( konto ) )  = ltrim ( rtrim ( @vanakonto ) ) 
select top 1 @count = id from saldo1 where ltrim ( rtrim ( konto ) )  = ltrim( rtrim ( @vanakonto) )  order by id desc
set @count = isnull ( @count, 0)
if @count > 0
	update saldo1 set konto = @uuskonto where ltrim( rtrim ( konto ) )  = ltrim ( rtrim ( @vanakonto ) ) 
select top 1 @count = id from lausend where deebet = ltrim ( rtrim ( @vanakonto) )  or ltrim ( rtrim ( kreedit) ) = ltrim ( rtrim ( @vanakonto ) ) order by id desc
set @count = isnull ( @count, 0)
if @count > 0
	begin
		update lausend set deebet = @uuskonto where ltrim ( rtrim ( deebet ) ) = ltrim ( rtrim ( @vanakonto ) )
		update lausend set kreedit = @uuskonto where ltrim ( rtrim ( kreedit) ) = ltrim ( rtrim ( @vanakonto ) )
	end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_create_saldo1_tabel 
@rekvId	int,
@aasta		int,
@konto		varchar ( 20) 
AS
declare @nMonth int,
	@cMonth	varchar(20),
	@kpv	datetime,
	@kood	varchar ( 20 ),
	@saldoid int,
	@cKpv	varchar ( 20 ),
	@asutusId	int
declare cur_konto cursor
for select   kood, asutusId  from library inner join kontoinf on kontoinf.parentid = library.id 
	inner join subkonto on subkonto.kontoid = library.id
	where rekvid = @rekvid
	and library = 'KONTOD'
	and kood like @konto
	order by library.kood
open cur_konto
fetch cur_konto into @kood, @asutusId
while @@fetch_status = 0
begin
	set @nMonth = 1
	while @nMonth < 13
		begin
			set @cMonth = ltrim ( rtrim ( str ( @nMonth ,2) ) ) 
			if len ( @cMonth ) = 1
				set @cMonth = '0'+@cMonth
			
			set @kpv = CAST ( str (@aasta, 4) + @cMonth +  '01'  AS DATETIME )			
			select  @saldoId =count  ( id )  from saldo1 
			where datepart ( year , period) = datepart ( year, @kpv )
			and datepart ( month, period ) = datepart ( month , @kpv)
			and konto = @kood
			and rekvId = @rekvId
			and asutusId = @asutusId
			set @SaldoId =  isnull(@SaldoId,0)
			if  @SaldoId = 0
				insert into saldo1  ( rekvid, asutusid, period, konto, saldo ) values (@rekvId, @asutusId, @KPV, @kood, 0)
			set @nMonth = @nMonth + 1				
		end
	fetch cur_konto into @kood, @asutusid
end
close cur_konto
deallocate cur_konto


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_create_saldo1_tabel1 
@rekvId	int,
@aasta		int,
@konto		varchar(20),
@asutusid	int
AS
declare @nMonth int,
	@cMonth	varchar(20),
	@kpv	datetime,
	@id	int
select  top 1  id   from saldo1 
where asutusid = @asutusid 
and konto = @konto 
and rekvId = @rekvId
order by id desc
if @@ROWCOUNT  < 1
begin
	set @nMonth = 1
	while @nMonth < 13
	begin
		set @cMonth = ltrim ( rtrim ( str ( @nMonth ,2) ) ) 
		if len ( @cMonth ) = 1
			set @cMonth = '0'+@cMonth			
		set @kpv = CAST ( str (@aasta, 4) + @cMonth +  '01'  AS DATETIME )			
		insert into saldo1  ( rekvid, asutusid, period, konto, saldo ) values (@rekvId, @asutusId, @KPV, @konto, 0)
		set @nMonth = @nMonth + 1				
	end
end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_create_saldo_tabel 
@rekvId	int,
@aasta		int,
@konto		varchar ( 20) 
AS
declare @nMonth int,
	@cMonth	varchar(20),
	@kpv	datetime,
	@kood	varchar ( 20 ),
	@saldoid int,
	@cKpv	varchar ( 20 )
declare cur_konto cursor
for select   kood  from library inner join kontoinf on kontoinf.parentid = library.id 
	where rekvid = @rekvid
	and library = 'KONTOD'
	and kood like @konto
	order by library.kood
open cur_konto
fetch cur_konto into @kood
while @@fetch_status = 0
begin
	set @nMonth = 1
	while @nMonth < 13
		begin
			set @cMonth = ltrim ( rtrim ( str ( @nMonth ,2) ) ) 
			if len ( @cMonth ) = 1
				set @cMonth = '0'+@cMonth
			
			set @kpv = CAST ( str (@aasta, 4) + @cMonth +  '01'  AS DATETIME )			
			select  @saldoId =count  ( id )  from saldo 
			where datepart ( year , period) = datepart ( year, @kpv )
			and datepart ( month, period ) = datepart ( month , @kpv)
			and konto = @kood
			and rekvId = @rekvId
			set @SaldoId =  isnull(@SaldoId,0)
			if  @SaldoId = 0
				insert into saldo (rekvid, period, konto, saldo ) values (@rekvId, @KPV, @kood, 0)
			set @nMonth = @nMonth + 1				
		end
	fetch cur_konto into @kood
end
close cur_konto
deallocate cur_konto


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_material_kaibed 
@kpv1		datetime,
@kpv2		datetime
AS
SELECT sum(kogus) as kogus,  sum(summa) as summa,  nomid
into #algsisetulik
FROM curladuArved
where liik = 1 and kpv <@kpv1
group by nomid
order by nomid
SELECT sum(kogus) as kogus,  sum(summa) as summa, nomid
into #algvaljminek
FROM curladuArved
where liik = 2 and kpv <@kpv1
group by nomid
order by nomid
SELECT sum(kogus) as kogus,  sum(summa) as summa,nomid
into #kreedit
FROM curladuArved
where liik = 2 
and kpv >=@kpv1 
and kpv <= @kpv2
group by nomid
order by nomid
SELECT sum(kogus) as kogus,  sum(summa) as summa, nomid
into #deebet
FROM curladuArved
where liik = 1 
and kpv >=@kpv1 
and kpv <= @kpv2
group by nomid
order by nomid
SELECT nomenklatuur.id, nomenklatuur.kood, 
    	nomenklatuur.nimetus, nomenklatuur.uhik, grupp.nimetus as grupp,
	isnull(algdeebet.kogus,0)  - isnull(algkreedit.kogus,0) as algkogus, isnull(algdeebet.summa,0) - isnull(algkreedit.summa,0) as algsumma,
	isnull(deebet.kogus,0) as dbkogus, isnull(deebet.summa,0) as dbsumma,
	isnull(kreedit.kogus,0) as krkogus, isnull(kreedit.summa,0) as krsumma
	FROM nomenklatuur INNER JOIN  ladu_grupp ON nomenklatuur.id = ladu_grupp.nomid
	inner join library grupp on grupp.id = ladu_grupp.parentid
	left outer join #algsisetulik algdeebet on nomenklatuur.id = algdeebet.nomid
	left outer join #algvaljminek algkreedit on nomenklatuur.id = algkreedit.nomid
	left outer join #deebet deebet on nomenklatuur.id = deebet.nomid
	left outer join #kreedit kreedit on nomenklatuur.id = kreedit.nomid


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_recalc_saldo 
	@rekvId	int,
	@kpv1	datetime,
	@kpv2	datetime,
	@pohikonto	varchar ( 20 )
AS
declare 	@id	int,
	@dbkaibed	money,
	@krkaibed	money,
	@saldo		money,
	@period	datetime,
	@lastsaldo	money,
	@viimanekonto varchar ( 20 ),
	@count int,
	@aasta	int,
	@konto	varchar( 20 )
set @lastsaldo = 0
set @viimanekonto = space (1)
declare cur_saldod cursor
for select   id, konto,period, saldo, dbkaibed, krkaibed   
	from saldo 
	where rekvid = @rekvid
	and datepart (year, period ) >= datepart ( year, @kpv1 )
	and datepart (month, period ) >= datepart ( month, @kpv1 )
	and datepart (year, period ) <= datepart ( year, @kpv2 )
	and datepart (month, period ) <= datepart ( month, @kpv2 )	
	and konto like @pohikonto
	order by saldo.konto, period
set @count = 0
open cur_saldod
fetch cur_saldod into @id, @konto, @period, @saldo, @dbkaibed, @krkaibed
while @@fetch_status = 0
begin
	if @viimanekonto <> @konto
		begin
			set @count = 1
			set @lastsaldo = @saldo
		end
	update saldo set saldo = @lastsaldo where id = @id
	select @lastsaldo =  @lastsaldo + @dbkaibed - @krkaibed, @viimanekonto = @konto	
	set @count = @count + 1
	fetch cur_saldod into @id, @konto, @period, @saldo, @dbkaibed, @krkaibed
end
close cur_saldod
deallocate cur_saldod
set @aasta = datepart (year, @kpv1 )
exec sp_update_pohikonto_saldo @rekvid, @aasta, 0 , @pohikonto		


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_recalc_saldo1 
	@rekvId	int,
	@kpv1	datetime,
	@kpv2	datetime,
	@pohikonto	varchar ( 20 )
AS
declare 	@id	int,
	@dbkaibed	money,
	@krkaibed	money,
	@saldo		money,
	@period	datetime,
	@lastsaldo	money,
	@viimanekonto varchar ( 20 ),
	@count int,
	@aasta	int,
	@konto	varchar( 20 ),
	@asutusid	int,
	@viimaneasutus	int
set @lastsaldo = 0
set @viimanekonto = space (1)
set @viimaneasutus = 0
declare cur_subkonto cursor
for select distinct asutusid from subkonto inner join library on library.id = subkonto.kontoId 
	where library.rekvid = @rekvId
	and subkonto.aasta = datepart ( year, @kpv1) 
	and library.kood like @pohikonto
	order by asutusId 
open cur_subkonto
fetch cur_subkonto into @asutusId
while @@fetch_status = 0
begin
	declare cur_saldod cursor
		for select   id, konto, period, saldo, dbkaibed, krkaibed   
		from saldo1 
		where rekvid = @rekvid
		and datepart (year, period ) >= datepart ( year, @kpv1 )
		and datepart (month, period ) >= datepart ( month, @kpv1 )
		and datepart (year, period ) <= datepart ( year, @kpv2 )
		and datepart (month, period ) <= datepart ( month, @kpv2 )	
		and asutusid = @asutusId
		order by asutusid, saldo1.konto, period
	set @count = 0
	open cur_saldod
	fetch cur_saldod into @id, @konto, @period, @saldo, @dbkaibed, @krkaibed
	while @@fetch_status = 0
	begin
		if @viimanekonto <> @konto or @viimaneAsutus <> @asutusId
			begin
				set @count = 1
				set @lastsaldo = @saldo
			end
		update saldo1 set saldo = @lastsaldo where id = @id
		select @lastsaldo =  @lastsaldo + @dbkaibed - @krkaibed, @viimanekonto = @konto, @viimaneasutus = @asutusId	
		set @count = @count + 1
		fetch cur_saldod into @id, @konto, @period, @saldo, @dbkaibed, @krkaibed
	end
	close cur_saldod
	deallocate cur_saldod
	set @lastsaldo = 0
	fetch cur_subkonto into @asutusId
end
close cur_subkonto
deallocate cur_subkonto
set @aasta = datepart (year, @kpv1 )
exec sp_update_pohikonto_saldo1 @rekvid, @aasta, 0, @pohikonto		


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_recalc_saldo2
	@rekvId	int,
	@kpv1	datetime,
	@kpv2	datetime,
	@pohikonto	varchar ( 20 ),
	@asutus	int
AS
declare 	@id	int,
	@asutusId	int,
	@dbkaibed	money,
	@krkaibed	money,
	@saldo		money,
	@period	datetime,
	@lastsaldo	money,
	@viimanekonto varchar ( 20 ),
	@count int,
	@aasta	int,
	@konto	varchar( 20 ),
	@viimaneasutus	int
set @lastsaldo = 0
set @viimanekonto = space (1)
set @viimaneasutus = 0
declare cur_subkonto cursor
for select distinct asutusid from subkonto inner join library on library.id = subkonto.kontoId 
	where library.rekvid = @rekvId
	and subkonto.aasta = datepart ( year, @kpv1) 
	and library.kood like @pohikonto
	and asutusId = @asutus
	order by asutusId 
open cur_subkonto
fetch cur_subkonto into @asutusId
while @@fetch_status = 0
begin
	declare cur_saldod cursor
		for select   id, konto, period, saldo, dbkaibed, krkaibed   
		from saldo1 
		where rekvid = @rekvid
		and datepart (year, period ) >= datepart ( year, @kpv1 )
		and datepart (month, period ) >= datepart ( month, @kpv1 )
		and datepart (year, period ) <= datepart ( year, @kpv2 )
		and datepart (month, period ) <= datepart ( month, @kpv2 )	
		and asutusid = @asutusId
		order by asutusid, saldo1.konto, period
	set @count = 0
	open cur_saldod
	fetch cur_saldod into @id, @konto, @period, @saldo, @dbkaibed, @krkaibed
	while @@fetch_status = 0
	begin
		if @viimanekonto <> @konto or @viimaneAsutus <> @asutusId
			begin
				set @count = 1
				set @lastsaldo = @saldo
			end
		update saldo1 set saldo = @lastsaldo where id = @id
		select @lastsaldo =  @lastsaldo + @dbkaibed - @krkaibed, @viimanekonto = @konto, @viimaneasutus = @asutusId	
		set @count = @count + 1
		fetch cur_saldod into @id, @konto, @period, @saldo, @dbkaibed, @krkaibed
	end
	close cur_saldod
	deallocate cur_saldod
	set @lastsaldo = 0
	fetch cur_subkonto into @asutusId
end
close cur_subkonto
deallocate cur_subkonto
set @aasta = datepart (year, @kpv1 )
exec sp_update_pohikonto_saldo1 @rekvid, @aasta, 0, @pohikonto		


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_save_copy 
@tnId	int
AS
declare 	@id	int,
	@rekvId	int,
	@kpv	datetime,	
	@asutusid int,
	@parentId	int,
	@lausendId	int,
	@deebet	varchar(20), 
	@kreedit	varchar(20),
	@kood1	int,
	@kood2	int, 
	@kood3	int, 
	@kood4	int, 
	@summa money,
	@copyid	int
declare cur_koopia cursor
for select   id, rekvId, kpv, asutusid  
	from journal  
	where id = @tnId
declare cur_koopia1 cursor
for select   parentid, lausendId, deebet, kreedit, kood1, kood2, kood3, kood4, summa
	from journal1  inner join lausend on lausendId = lausend.Id
	where Parentid = @tnId
open cur_koopia
fetch cur_koopia into @id, @rekvId, @kpv, @asutusId
while @@fetch_status = 0
begin
	insert into journalTmp (id, rekvid, kpv, asutusId)
		values (@id, @rekvId, @kpv, @asutusId)
	select top 1 @copyId = copyid from journalTmp order by copyid desc
	fetch cur_koopia into @id, @rekvId, @kpv, @asutusId
end
close cur_koopia
deallocate cur_koopia
open cur_koopia1
fetch cur_koopia1 into @parentid, @LausendId, @deebet, @kreedit, @kood1, @kood2, @kood3, @kood4, @summa
while @@fetch_status = 0
begin
	insert into journal1Tmp (copyid,  parentId, deebet, kreedit, kood1, kood2, kood3, kood4, summa)
		values (@copyid, @parentId, @deebet, @kreedit, @kood1, @kood2, @kood3, @kood4, @summa)
	fetch cur_koopia1 into @parentid, @LausendId, @deebet, @kreedit, @kood1, @kood2, @kood3, @kood4, @summa
end
close cur_koopia1
deallocate cur_koopia1
select 'copyId' = @copyId


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_update_pohikonto_saldo 
@rekvid	int,
@aasta		int,
@kuu		int,
@konto		varchar ( 20 )
AS
declare @kood		varchar ( 20),
	@saldo		money,
	@krkaibed	money,
	@dbkaibed	money,
	@period		varchar ( 20 ),
	@kuu1		int,
	@kuu2		int
if @kuu = 0
	begin
		select @kuu1 = 1, @kuu2 = 12
	end
else
	begin
		select @kuu1 = @kuu,  @kuu2 = @kuu
	end
declare cur_pohikonto cursor
for select kood 
	from library inner join kontoinf on kontoinf.parentid = library.id 
	where liik = 2
	and library.kood like @konto
	and library.rekvid = @rekvId
open cur_pohikonto
fetch cur_pohikonto into @kood
while @@fetch_status = 0
begin
	declare cur_kaibed cursor
		for  select str ( datepart ( year, period), 4) + str ( datepart (month, period ),2 ) period,
		sum ( saldo ) saldo, sum ( dbkaibed ) dbkaibed, sum (krkaibed ) krkaibed 
		from saldo inner join library on library.kood = saldo.konto
		inner join kontoinf on kontoinf.parentId = library.id
		where library.library = 'KONTOD'
		and kontoinf.pohikonto = @kood
		and saldo.rekvid = @rekvid
		and datepart ( year, period ) = @aasta
		and datepart ( month, period ) >= @kuu1
		and datepart ( month, period ) <= @kuu2
		group by str ( datepart ( year, period), 4) + str ( datepart (month, period ),2 )
		order by str ( datepart ( year, period), 4) + str ( datepart (month, period ),2 )
	open cur_kaibed
	fetch cur_kaibed into @period, @saldo, @dbkaibed, @krkaibed
	while @@fetch_status = 0
		begin
			update saldo set saldo = @saldo, 
				dbkaibed = @dbkaibed,
				krkaibed = @krkaibed
				where konto = @kood
				and str ( datepart ( year, period ),4 ) + str ( datepart (month, period ),2 )= @period  
				and saldo.rekvid = @rekvid
			fetch cur_kaibed into @period, @saldo, @dbkaibed, @krkaibed
		end
	close cur_kaibed
	deallocate cur_kaibed
	fetch cur_pohikonto into @kood
end
close cur_pohikonto
deallocate cur_pohikonto


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE sp_update_pohikonto_saldo1 
@rekvid	int,
@aasta		int,
@kuu		int,
@konto		varchar ( 20 )
AS
declare @kood		varchar ( 20),
	@saldo		money,
	@krkaibed	money,
	@dbkaibed	money,
	@period	varchar ( 20 ),
	@asutusId	int,
	@kuu1		int,
	@kuu2		int
if @kuu = 0
	begin
		select @kuu1 = 1, @kuu2 = 12
	end
else
	begin
		select @kuu1 = @kuu,  @kuu2 = @kuu
	end
declare cur_pohikonto cursor
for select kood, subkonto.asutusid
	from library inner join kontoinf on kontoinf.parentid = library.id 
	inner join subkonto on subkonto.kontoid = library.id
	where liik = 2
	and library.kood like @konto
	and library.rekvid = @rekvId
open cur_pohikonto
fetch cur_pohikonto into @kood, @asutusId
while @@fetch_status = 0
begin
	declare cur_kaibed cursor
		for  select str ( datepart ( year, period), 4) + str ( datepart (month, period ),2 ) period,
		sum ( saldo ) saldo, sum ( dbkaibed ) dbkaibed, sum (krkaibed ) krkaibed 
		from saldo1 inner join library on library.kood = saldo1.konto
		inner join kontoinf on kontoinf.parentId = library.id
		where library.library = 'KONTOD'
		and kontoinf.pohikonto = @kood
		and saldo1.asutusId = @asutusId
		and saldo1.rekvid = @rekvid
		and datepart ( year, period ) = @aasta
		and datepart ( month, period) >= @kuu1
		and datepart ( month, period ) <= @kuu2
		group by str ( datepart ( year, period), 4) + str ( datepart (month, period ),2 )
		order by str ( datepart ( year, period), 4) + str ( datepart (month, period ),2 )
	open cur_kaibed
	fetch cur_kaibed into @period, @saldo, @dbkaibed, @krkaibed
	while @@fetch_status = 0
		begin
			update saldo1 set saldo = @saldo, 
				dbkaibed = @dbkaibed,
				krkaibed = @krkaibed
				where konto = @kood
				and str ( datepart ( year, period ),4 ) + str ( datepart (month, period ),2 )= @period  
				and saldo1.rekvid = @rekvid
			fetch cur_kaibed into @period, @saldo, @dbkaibed, @krkaibed
		end
	close cur_kaibed
	deallocate cur_kaibed
	fetch cur_pohikonto into @kood, @asutusId
end
close cur_pohikonto
deallocate cur_pohikonto


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE PROCEDURE sp_update_saldo 
@CopyId	int, 
@Id		int
AS
declare 	@asutusId	int,
	@rekvId	int,
	@lausendId	int,
	@deebet	char(20),
	@kreedit	char(20),
	@summa		money,
	@month		smallint,
	@year		smallint,
	@kpv		datetime,
	@today		datetime,
	@month1	smallint,
	@year1		smallint,
	@lSaldo	money,
	@dbKaibed 	money,
	@krkaibed	money,
	@sId		int,
	@kontoid	int
	declare @nMonth int,
		@cMonth	varchar(20),
		@dkpv	datetime,
		@nid	int
declare cur_backlaus cursor
for select  kpv, asutusid,  lausendId, deebet, kreedit, summa , rekvid 
	from journalTmp inner join journal1Tmp on journalTmp.copyid = journal1Tmp.copyid  
	where journalTmp.copyid = @CopyId
open cur_backlaus
fetch cur_backlaus into @kpv, @asutusId, @lausendid, @deebet, @kreedit, @summa, @rekvId
while @@fetch_status = 0
begin
	set @today = getdate()	
	set @today = dateadd ( month,1,@today)
	select @month = datepart(month, @kpv), @year = datepart (year,@kpv)
	update saldo set dbkaibed  = dbkaibed - @summa
		where datepart(year,period) = @year
		and datepart (month, period) = @month
		and konto = @deebet
	exec  sp_recalc_saldo 	@rekvId, @kpv, @today , @deebet 
	if @asutusId > 0
		begin
			update saldo1 set dbkaibed  = dbkaibed - @summa
				where datepart(year,period) = @year
				and datepart (month, period) = @month
				and konto = @deebet
				and asutusId = @asutusId
			exec  sp_recalc_saldo2 	@rekvId, @kpv, @today , @deebet, @AsutusId 
		end
	update saldo set krkaibed  = krkaibed - @summa
		where datepart(year,period) = @year
		and datepart (month, period) = @month
		and konto = @kreedit
	exec  sp_recalc_saldo 	@rekvId, @kpv, @today , @kreedit 
	if @asutusId > 0
		begin
			update saldo1 set krkaibed  = krkaibed - @summa
				where datepart(year,period) = @year
				and datepart (month, period) = @month
				and konto = @kreedit
				and asutusId = @asutusId
			exec  sp_recalc_saldo2 	@rekvId, @kpv, @today , @kreedit, @AsutusId 
		end
	fetch cur_backlaus into @kpv, @asutusId, @lausendid, @deebet, @kreedit, @summa, @rekvid
end
delete from journalTmp where copyid = @copyId
delete from journal1Tmp where copyid = @copyId
close cur_backlaus
deallocate cur_backlaus
declare cur_laus cursor
for select  journal.kpv, journal.asutusid,  journal1.lausendId, lausend.deebet, lausend.kreedit, journal1.summa  , journal.rekvId
	from journal inner join journal1 on journal.id = journal1.parentid  
	inner join lausend on lausend.Id = journal1.lausendid 
	where journal.id = @Id
open cur_laus
fetch cur_laus into @kpv, @asutusId, @lausendid, @deebet, @kreedit, @summa, @rekvId
while @@fetch_status = 0
begin
	select @month = datepart(month, @kpv), @year = datepart (year,@kpv)
	update saldo set dbkaibed  = dbkaibed + @summa
		where datepart(year,period) = @year
		and datepart (month, period) = @month
		and konto = @deebet
		and rekvId =@rekvId
	exec  sp_recalc_saldo 	@rekvId, @kpv, @today , @deebet
	if @asutusId > 0
		begin
			select @id = id from library where kood = @deebet and library = 'KONTOD' and rekvid = @rekvid
			select top 1 @nId = id from subkonto where kontoid = @id order by id desc 
			set @nId = isnull(@nId,0)
			if @nId > 0
				begin
					select top 1 @nid = id from subkonto where kontoid = @id and asutusid = @asutusId order by aasta desc 				
					select @nId = isnull(@nId,0)
					if @nId < 1
						insert into subkonto (kontoid, asutusid, aasta, algsaldo) values (@id, @asutusId, @year,0)
					select top 1  id from saldo1 where konto = @kreedit and asutusid = @asutusid
					if @@rowcount < 1
						exec sp_create_saldo1_tabel1 @rekvId, @year, @deebet, @asutusId	
				end
			update saldo1 set dbkaibed  = dbkaibed + @summa
				where datepart(year,period) = @year
				and datepart (month, period) = @month
				and konto = @deebet
				and asutusId = @asutusId
			exec  sp_recalc_saldo2 	@rekvId, @kpv, @today , @deebet, @AsutusId 
		end
	update saldo set krkaibed  = krkaibed + @summa
		where datepart(year,period) = @year
		and datepart (month, period) = @month
		and konto = @kreedit
		and rekvId =@rekvId
	exec  sp_recalc_saldo 	@rekvId, @kpv, @today , @kreedit 
	if @asutusId > 0
		begin
			select @id = id from library where kood = @Kreedit and library = 'KONTOD' and rekvid = @rekvid
			select top 1 @nId =  id from subkonto where kontoid = @id order by id desc 
			set @nId = isnull(@nId,0)
			if @nId > 0
				begin
					/* записи субсчетов учитываются */
					select top 1 @nId = id from subkonto where kontoid = @id and asutusid = @asutusId order by aasta desc 				
					set @nId = isnull(@nId,0)
					if @nId < 1
						insert into subkonto (kontoid, asutusid, aasta, algsaldo) values (@id, @asutusId, @year,0)
					select top 1  id from saldo1 where konto = @kreedit and asutusid = @asutusid
					if @@rowcount < 1
						exec sp_create_saldo1_tabel1 @rekvId, @year, @kreedit, @asutusId	
			 
				end
			update saldo1 set krkaibed  = krkaibed + @summa
				where datepart(year,period) = @year
				and datepart (month, period) = @month
				and konto = @kreedit
				and asutusId = @asutusId
			exec  sp_recalc_saldo2 	@rekvId, @kpv, @today , @kreedit, @AsutusId 
		end
	fetch cur_laus into @kpv, @asutusId, @lausendid, @deebet, @kreedit, @summa, @rekvId
end
close cur_laus
deallocate cur_laus


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER sp_trigD_autod ON [dbo].[autod] 
FOR DELETE 
AS
declare @id	int
select top 1 @id = autoid from arv3 inner join deleted on arv3.autoid = deleted.id
set @id = isnull(@id,0)
if @id > 0
	begin
		rollback transaction
		raiserror (' ei saa kustuta auto ', 16, 10)
	end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER sp_trigD_vastisikud ON [dbo].[vastisikud] 
FOR DELETE 
AS
declare @id int
select @id = arv3.isikId from arv3 inner join deleted on deleted.id = arv3.isikId
set @id = isnull(@id,0)
if @id > 0
	begin
		rollback transaction
		raiserror (' ei saa kustuta vast.isik ', 16, 10)
	end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

