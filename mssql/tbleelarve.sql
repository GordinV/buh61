CREATE TABLE [dbo].[eelarve] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[rekvid] [int] NOT NULL ,
	[allikasid] [int] NOT NULL ,
	[aasta] [int] NOT NULL ,
	[summa] [money] NOT NULL ,
	[kood1] [int] NOT NULL ,
	[kood2] [int] NOT NULL ,
	[kood3] [int] NOT NULL ,
	[kood4] [int] NOT NULL ,
	[muud] [text] COLLATE Cyrillic_General_CI_AS NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

