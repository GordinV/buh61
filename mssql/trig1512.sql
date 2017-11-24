CREATE TRIGGER TrigI_aa ON aa FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'rekv' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.parentid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
ELSE
	select @@IDENTITY  as id, 'aa' as tbl 



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigU_aa ON aa FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'rekv' */
IF UPDATE(parentid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.parentid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
                SELECT @status = 'Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'vorder1' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, vorder1 WHERE (deleted.id = vorder1.kassaid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''vorder1''.'
            SELECT @status='Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigD_aa ON aa FOR DELETE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT DELETES IF DEPENDENT RECORDS IN 'vorder1' */
IF (SELECT COUNT(*) FROM deleted, vorder1 WHERE (deleted.id = vorder1.kassaid)) > 0
    BEGIN
    RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''vorder1''.'
    SELECT @status='Failed'
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_AASTA ON [dbo].[aasta] 
FOR INSERT
AS
select @@IDENTITY  as id, 'AASTA' as tbl 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigI_arv ON arv FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'rekv' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
            SELECT @status='Failed'
        END
    END
/* PREVENT INSERTS IF NO MATCHING KEY IN 'asutus' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM asutus, inserted WHERE (asutus.id = inserted.asutusid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''asutus''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
else
	select @@IDENTITY  as id, 'ARV' as tbl 






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigU_arv ON arv FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'rekv' */
IF UPDATE(rekvid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
                SELECT @status = 'Failed'
            END
    END
/* PREVENT UPDATES IF NO MATCHING KEY IN 'asutus' */
IF UPDATE(asutusid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM asutus, inserted WHERE (asutus.id = inserted.asutusid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''asutus''.'
                SELECT @status = 'Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER sp_trig_i_arv1 
ON arv1
FOR INSERT 
AS
declare @operId		int,
	@liik		int,
	@parent	int,
	@arv1id	int,
	@LifoFifo 	int,
	@rekv		int,
	@nomId	int,
	@kogus	money,
	@dokItemId	int
select @arv1id = i.id, @parent = i.parentId, @nomid = i.nomId, @kogus = i.kogus from inserted i inner join ladu_grupp on ladu_grupp.nomId = i.nomId 
set @parent = isnull(@parent,0)
if @parent > 0
begin
select @operid = operId, @liik = liik, @rekv = rekvid from arv where id = @parent 
if @operId > 0  and @liik = 1
	begin
	/* vara sisetulik*/
		insert ladu_jaak 
			select arv.rekvid, arv1.id as dokitemid, nomid, userid, kpv, hind, kogus, 0 as maha, arv1.kogus as jaak 
				from arv inner join arv1 on arv.id = arv1.parentid
				where arv1.id = @arv1id 
	end	
if @operId > 0  and @liik = 0
	begin
	/*vara valjaminek */
	begin tran
	declare @id		int, 
		@jaak		money,
		@maha		money,	
		@kpv		datetime
	select @LifoFifo = liik from ladu_config where rekvid = @rekv 
	set @LifoFifo = isnull(@LifoFifo,1)
	if @LifoFifo = 1
		begin
		/* Lifo */
			declare cur_ladujaak cursor
				for select   id, jaak, maha, kpv, dokItemId   
				from ladu_jaak
				where rekvid = @rekv
				and jaak > 0
				and nomid = @nomId
				order by kpv 
		end
	else
		/* FiFo*/
		begin
			declare cur_ladujaak cursor
				for select   id, jaak, maha, kpv, dokItemId   
				from ladu_jaak
				where rekvid = @rekv
				and jaak > 0
				and nomid = @nomId
				order by kpv desc
		end
	open cur_ladujaak
	fetch  cur_ladujaak into @id, @jaak, @maha, @kpv, @dokItemId
	while @@fetch_status = 0  
	begin
		if @Jaak >= @kogus and @Kogus > 0
			begin
				
				update arv1 set maha = 1 where id = @dokItemId and maha = 0
				update ladu_jaak set jaak = @jaak - @kogus, maha = @maha + @kogus where id = @id
				set @kogus = 0
				if (@maha + @kogus) > @jaak
					raiserror (' ei saa mahakandma nii palja kaupa', 16, 10)
			end	
		if @Jaak < @kogus and @kogus >= 0	
			begin
				update arv1 set maha = 1 where id = @dokItemId and maha = 0
				update ladu_jaak set jaak = 0, maha = maha + (@kogus - @jaak) where id = @id
				set @kogus = @kogus - @jaak				
			end
		delete from ladu_jaak where jaak = 0
		fetch  cur_ladujaak into @id, @jaak, @maha, @kpv, @dokItemId
	end
	close cur_ladujaak
	deallocate cur_ladujaak
	if @kogus > 0
		begin
			rollback tran
			raiserror ('Ladus ei ole kaupa', 16, 10)
		end
	else
		commit tran
	end
end
select @ARV1ID  as id, 'ARV1' as tbl 






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER sp_trigD_arv1 
ON arv1
FOR DELETE 
AS
declare @maha		int,
	@id		int,
	@liik		int,
	@operid	int
select @maha = maha from deleted
select @maha as maha
if @maha = 1	
	begin
		print 'maha:'+str (@maha)
		rollback tran
		raiserror (' ei saa parandada makantud dokument ', 16, 10)
	end
else
	begin
		select @id = parentid from deleted 
		select @liik = arv.liik, @operid = operid from arv where id = @id
		select @liik as liik, @operid as operid, @id as id
		if @operId > 0	and @liik = 1
			begin
				print 'deleting'
				/* sistulik*/
				delete from ladu_jaak where dokitemid in (select id from deleted)
			end
		if @operId > 0	and @liik = 0
			begin
				/* valjaminek*/
				print 'rollback'	
				rollback tran
				raiserror (' ei saa parandada makantud dokument ', 16, 10)
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


CREATE TRIGGER sp_trigU_arv1
ON arv1
FOR  UPDATE
AS
declare @maha		int,
	@kpv		datetime,
	@summa	money,
	@kogus	money,
	@nomid		int,
	@hind		money,
	@kpvi		datetime,
	@summai	money,
	@kogusi	INT

declare 	@hindi		money,	
	@id		int,
	@NomIdi	int
select @maha = maha from deleted
if @maha = 1
	begin
		select @id = deleted.parentid from deleted
		select @summa = d.summa, @hind = d.hind, @kogus = d.kogus, @nomid = d.nomid from arv, deleted d where arv.id = @id
 		select  @summai = i.summa, @hindi = i.hind, @kogusi = i.kogus, @nomidi = i.nomid from inserted i 
		if @summa <> @summai or @kogus <> @kogusi or @nomid <> @nomidi
			begin
				raiserror (' ei saa parandada makantud dokument ', 16, 10)
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

CREATE TRIGGER TRIGI_ARVTASU ON [dbo].[arvtasu] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'ARVTASU' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigI_asutus ON asutus FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'rekv' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
ELSE
	select @@IDENTITY  as id, 'ASUTUS' as tbl 



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigU_asutus ON asutus FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'journal' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, journal WHERE (deleted.id = journal.asutusid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''journal''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF NO MATCHING KEY IN 'rekv' */
IF UPDATE(rekvid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
                SELECT @status = 'Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'arv' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, arv WHERE (deleted.id = arv.asutusid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''arv''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'subkonto' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, subkonto WHERE (deleted.id = subkonto.asutusid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''subkonto''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'saldo1' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, saldo1 WHERE (deleted.id = saldo1.asutusid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''saldo1''.'
            SELECT @status='Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigD_asutus ON asutus FOR DELETE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT DELETES IF DEPENDENT RECORDS IN 'journal' */
IF (SELECT COUNT(*) FROM deleted, journal WHERE (deleted.id = journal.asutusid)) > 0
    BEGIN
    RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''journal''.'
    SELECT @status='Failed'
    END
/* PREVENT DELETES IF DEPENDENT RECORDS IN 'arv' */
IF (SELECT COUNT(*) FROM deleted, arv WHERE (deleted.id = arv.asutusid)) > 0
    BEGIN
    RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''arv''.'
    SELECT @status='Failed'
    END
/* PREVENT DELETES IF DEPENDENT RECORDS IN 'sorder1' */
IF (SELECT COUNT(*) FROM deleted, sorder1 WHERE (deleted.id = sorder1.asutusid)) > 0
    BEGIN
    RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''sorder1''.'
    SELECT @status='Failed'
    END
/* PREVENT DELETES IF DEPENDENT RECORDS IN 'vorder1' */
IF (SELECT COUNT(*) FROM deleted, vorder1 WHERE (deleted.id = vorder1.asutusid)) > 0
    BEGIN
    RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''vorder1''.'
    SELECT @status='Failed'
    END
/* CASCADE DELETES TO 'subkonto' */
DELETE subkonto FROM deleted, subkonto WHERE deleted.id = subkonto.asutusid
/* CASCADE DELETES TO 'saldo1' */
DELETE saldo1 FROM deleted, saldo1 WHERE deleted.id = saldo1.asutusid
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_DOKLAUSEND ON [dbo].[doklausend] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'DOKLAUSEND' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER sp_GetId_doklausend 
ON doklausend 
FOR INSERT 
AS
select id from inserted


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_DOKLAUSHEADER ON  [dbo].[doklausheader] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'DOKLAUSHEADER' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_DOKPROP ON [dbo].[dokprop] 
FOR INSERT 
AS
	select @@IDENTITY  as id, 'DOKPROP' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_EEL_CONFIG ON [dbo].[eel_config] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'EEL_CONFIG' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_EELARVE ON [dbo].[eelarve] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'EELARVE' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER trigI_gruppOmandus ON gruppomandus 
FOR INSERT
AS
	select @@IDENTITY  as id, 'GRUPPOMANDUS' as tbl 


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_HOLIDAYS ON [dbo].[holidays] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'HOLIDAYS' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TrigI_journal ON journal FOR INSERT AS 
declare @nKuu		int,
	@Rekv		int,
	@nAasta	int,
	@nKinni	int,
	@status 	char(10) 
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'asutus' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM asutus, inserted WHERE (asutus.id = inserted.asutusid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''asutus''.'
            SELECT @status='Failed'
        END
    END
/* PREVENT INSERTS IF NO MATCHING KEY IN 'rekv' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
            SELECT @status='Failed'
        END
    END
/* PREVENT INSERTS IF NO MATCHING KEY IN 'userid' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM userid, inserted WHERE (userid.id = inserted.userid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''userid''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
else
	begin

		select @nKuu = datepart   ( month, kpv ), @nAasta = datepart ( year, kpv), @rekv = rekvid  from inserted 
		select @nKinni = kinni from aasta where kuu = @nKuu and aasta = @nAasta and rekvid = @rekv 
		if @nKinni = 1
			begin
				rollback tran
				raiserror ('Period on kinnitatud', 16, 10)
			end
		else
		select @@IDENTITY  as id, 'JOURNAL' as tbl 
	end





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigU_journal ON journal FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'asutus' */
IF UPDATE(asutusid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM asutus, inserted WHERE (asutus.id = inserted.asutusid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''asutus''.'
                SELECT @status = 'Failed'
            END
    END
/* PREVENT UPDATES IF NO MATCHING KEY IN 'rekv' */
IF UPDATE(rekvid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
                SELECT @status = 'Failed'
            END
    END
/* PREVENT UPDATES IF NO MATCHING KEY IN 'userid' */
IF UPDATE(userid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM userid, inserted WHERE (userid.id = inserted.userid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''userid''.'
                SELECT @status = 'Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigD_journal ON journal FOR DELETE AS 
declare @nKuu		int,
	@Rekv		int,
	@nAasta	int,
	@nKinni	int,
	@status char(10)
SELECT @status='Succeeded'
/* CASCADE DELETES TO 'journal1' */
DELETE journal1 FROM deleted, journal1 WHERE deleted.id = journal1.parentid
/* CASCADE DELETES TO 'arvtasu' */
DELETE arvtasu FROM deleted, arvtasu WHERE deleted.id = arvtasu.journalid
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION
else
	begin
	
		select @nKuu = datepart   ( month, kpv ), @nAasta = datepart ( year, kpv), @rekv = rekvid  from deleted
		select @nKinni = kinni from aasta where kuu = @nKuu and aasta = @nAasta and rekvid = @rekv 
		if @nKinni = 1
			begin
				rollback tran
				raiserror ('Period on kinnitatud', 16, 10)
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


CREATE TRIGGER sp_checksubkonto_journal1 
ON journal1
FOR UPDATE
AS
declare @deebet	varchar (20),
	@kreedit 	varchar (20),
	@subkontoid	int,
	@asutusid	int,
	@aasta		int,
	@parentid	int,
	@kontoid	int,
	@rekvid	int

select @asutusid = asutusid, @aasta = datepart (year, journal.kpv), @rekvid = journal.rekvid from journal, inserted i where journal.id = i.parentid
set @asutusid = isnull(@asutusid,0)
if @asutusId > 0
	begin
		select @deebet = lausend.deebet, @kreedit = lausend.kreedit, @parentid = i.parentid from lausend inner join  inserted i on i.lausendid = lausend.id
		select @kontoid = library.id from library where kood = @deebet and rekvid = @rekvid and library.library = 'KONTOD'
		select @subkontoid = subkonto.id from subkonto  WHERE kontoid = @kontoid and asutusId = @asutusId 
		set @subkontoid = isnull(@subkontoid,0)
		if @subkontoid = 0
			insert into subkonto (algsaldo, aasta, kontoid, asutusid, rekvid) values (0, @aasta, @kontoid, @asutusid, @rekvid)
		select @kontoid = library.id from library where kood = @kreedit and rekvid = @rekvid and library = 'KONTOD'
		select @subkontoid = subkonto.id from subkonto  where kontoid = @kontoid and asutusId = @asutusId 
		set @subkontoid = isnull(@subkontoid,0)
		if @subkontoid = 0
			insert into subkonto (algsaldo, aasta, kontoid, asutusid) values (0, @aasta, @kontoid, @asutusid)	
	end
select id from inserted




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER sp_getid_journal1 
ON journal1
FOR INSERT
AS
declare @deebet	varchar (20),
	@kreedit 	varchar (20),
	@subkontoid	int,
	@asutusid	int,
	@aasta		int,
	@parentid	int,
	@kontoid	int,
	@rekvid	int,
	@kontrol	int,
	@Eelarve	money,
	@taitmine	money,
	@kpv		datetime,
	@status		int,
	@kood3	int,
	@kood4	int,
	@summa	money,
	@indentity	int

select @kpv = kpv, @asutusid = asutusid, @aasta = datepart (year, journal.kpv), @rekvid = journal.rekvid, @indentity = i.id  from journal, inserted i where journal.id = i.parentid
set @asutusid = isnull(@asutusid,0)
if @asutusId > 0
	begin
		select @deebet = lausend.deebet, @kreedit = lausend.kreedit, @parentid = i.parentid from lausend inner join  inserted i on i.lausendid = lausend.id
		select @kontoid = library.id from library where kood = @deebet and rekvid = @rekvid and library.library = 'KONTOD'
		select @subkontoid = subkonto.id from subkonto  WHERE kontoid = @kontoid and asutusId = @asutusId 
		set @subkontoid = isnull(@subkontoid,0)
		if @subkontoid = 0
			insert into subkonto (algsaldo, aasta, kontoid, asutusid, rekvid) values (0, @aasta, @kontoid, @asutusid, @rekvid)
		select @kontoid = library.id from library where kood = @kreedit and rekvid = @rekvid and library = 'KONTOD'
		select @subkontoid = subkonto.id from subkonto  where kontoid = @kontoid and asutusId = @asutusId 
		set @subkontoid = isnull(@subkontoid,0)
		if @subkontoid = 0
			insert into subkonto (algsaldo, aasta, kontoid, asutusid, rekvid) values (0, @aasta, @kontoid, @asutusid, @rekvid)	
	end


set @status = 1

select @summa = i.summa, @kood3 = i.kood3, @kood4 = i.kood4, @kpv = kpv, @rekvid = rekvid from journal,  inserted i 
select @kontrol = kontrol from eel_config where rekvid = @rekvid 
if @kontrol = 1 and  @kood3 > 0 and @kood4 > 0
	begin
		select @eelarve = sum ( eelarve.summa )  from eelarve
		where eelarve.aasta = datepart  ( year,@kpv)
		and eelarve.kood3 = @Kood3
		and eelarve.kood4 = @Kood4
		and eelarve.rekvid = @Rekvid

		set @eelarve = isnull(@eelarve,0)
		if @eelarve > 0
			begin
				select  @taitmine = sum ( journal1.summa) 
					from  journal inner join journal1 on journal.id = journal1.parentid
					where journal1.kood3 = @Kood3 
					and journal1.kood4 = @Kood4
					and journal.rekvid = @rekvid
					and journal.kpv <= @kpv
				set @taitmine = isnull(@taitmine,0) + @summa

				if (@Eelarve - @Taitmine)  < 0 and @eelarve > 0
		   			RAISERROR 44446 'Eelarve kontrol'
			end
	end
	select @INDENTITY  as id, 'JOURNAL1' as tbl 








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_KLASSIFLIB  ON [dbo].[klassiflib] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'KLASSIFLIB' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigI_kontoinf ON kontoinf FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'library' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM library, inserted WHERE (library.id = inserted.parentid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''library''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigU_kontoinf ON kontoinf FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'library' */
IF UPDATE(parentid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM library, inserted WHERE (library.id = inserted.parentid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''library''.'
                SELECT @status = 'Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER trigD_kontoinf 
ON kontoinf
FOR DELETE 
AS
declare @kood	varchar(20)
select @kood = kood from library, deleted  where library.id = deleted.parentid
select top 1 id from lausend where deebet = @kood or kreedit = @kood
if @@rowcount > 0
	    RAISERROR ('Ei saa kustuta konto', 16, 1)




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_LADU_CONFIG ON [dbo].[ladu_config] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LADU_CONFIG' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_LADU_GRUPP ON [dbo].[ladu_grupp] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LADU_GRUPP' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_LADU_JAAK ON [dbo].[ladu_jaak] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LADU_JAAK' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_LADU_MINKOGUS ON [dbo].[ladu_minkogus] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LADU_MINKOGUS' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_LADU_OPER ON [dbo].[ladu_oper] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LADU_OPER' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIG_LADU_ULEHIND ON [dbo].[ladu_ulehind] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LADU_ULEHIND' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_LAUSDOK ON [dbo].[lausdok] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LAUSDOK' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER sp_getid_lausdok 
ON lausdok
FOR INSERT 
AS
select id from inserted


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_LAUSEND ON [dbo].[lausend] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LAUSEND' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER CHEK_FOR_JOURNAL1  
ON LAUSEND
FOR DELETE 
AS
DECLARE @ID	INT
select top 1 @id = JOURNAL1.id  from journal1, deleted  where lausendid = deleted.id
set @id = isnull(@id,0)
if @id > 0
	raiserror ('Ei saa kusttuta sest lausend kasutatab dokumendis',16,10)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER check_for_update 
ON lausend 
FOR UPDATE
AS
declare @id	int,
	@deebet_vana	varchar(20),
	@kreedit_vana	varchar(20),
	@deebet_uus	varchar(20),
	@kreedit_uus	varchar(20)

select top 1 @id =journal1. id from journal1, deleted where lausendid = deleted.id
set @id = isnull(@id,0)
if @id > 0
	begin
		select @deebet_vana = deebet, @kreedit_vana = kreedit  from deleted
		select @deebet_uus = deebet, @kreedit_uus = kreedit  from inserted
		if @deebet_vana <> @deebet_uus or @kreedit_vana <> @kreedit_uus
			raiserror ('Ei saa parandada lausend',16,10)				
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



CREATE TRIGGER sp_getid_lausend
ON lausend
FOR INSERT
AS
select id from inserted



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_LEPING1 ON [dbo].[leping1] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LEPING1' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_LEPING2 ON [dbo].[leping2] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'LEPING2' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigI_library ON library FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
declare		@LIBRARY  	varchar(20),	
		@kood		varchar(20),
		@count		int,
		@rekvid	int,
		@period	datetime,
		@kuu		int,
		@cKuu		varchar(2),
		@ID		INT
SELECT @status='Succeeded', @id = @@identity
/* PREVENT INSERTS IF NO MATCHING KEY IN 'rekv' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
else
	begin
		select @library = library, @kood = kood, @rekvid = rekvid  from inserted 
		if @library = 'KONTOD'
			begin
				select @count = count (id) from saldo where   rekvid = @rekvid and konto = @kood 
				set @count = isnull(@count,0)
				if @count < 1
					begin
						set @kuu = 1
						while @kuu < 13
							begin
								if @kuu < 10
									set @cKuu = '0'+cast(@kuu as varchar(2))
								set @period =  cast(datepart (year,getdate()) as char(4))+@cKuu+'01'
								insert into saldo (rekvid, konto, period) values (@rekvid, @kood, @period)
								set @kuu = @kuu + 1
							end
					end
			end	
		select @ID  as id, 'LIBRARY' as tbl 
	end




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigU_library ON library FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'rekv' */
IF UPDATE(rekvid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
                SELECT @status = 'Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'kontoinf' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, kontoinf WHERE (deleted.id = kontoinf.parentid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''kontoinf''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'subkonto' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, subkonto WHERE (deleted.id = subkonto.kontoid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''subkonto''.'
            SELECT @status='Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigD_library ON library FOR DELETE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* CASCADE DELETES TO 'kontoinf' */
DELETE kontoinf FROM deleted, kontoinf WHERE deleted.id = kontoinf.parentid
/* CASCADE DELETES TO 'subkonto' */
DELETE subkonto FROM deleted, subkonto WHERE deleted.id = subkonto.kontoid
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigI_nomenklatuur ON nomenklatuur FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'rekv' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
ELSE
	select @@IDENTITY  as id, 'NOMENKLATUUR' as tbl 



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigU_nomenklatuur ON nomenklatuur FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'rekv' */
IF UPDATE(rekvid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
                SELECT @status = 'Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER sp_getid_nomenklatuur 
ON nomenklatuur
FOR INSERT
AS
select id from inserted



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_PALK_ASUTUS  ON [dbo].[palk_asutus] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'PALK_ASUTUS' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_PALK_CONFIG ON [dbo].[palk_config] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'PALK_CONFIG' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_PALK_JAAK ON palk_jaak 
FOR INSERT
AS
	select @@IDENTITY  as id, 'PALK_JAAK' as tbl

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_PALK_KAART ON [dbo].[palk_kaart] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'PALK_KAART' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_PALK_LIB ON [dbo].[palk_lib] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'PALK_LIB' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER spD_recalk_jaak 
ON palk_oper
FOR DELETE
AS
declare @kpv1	datetime,
	@kpv2	datetime,
	@rekv	int,
	@lepId	int

select @kpv1 = '01.'+cast (datepart (month, i.kpv) as char(2)) +'.'+
	cast (datepart ( year, i.kpv) as char(4)),
	@kpv2 = dateadd (month,1, @kpv1 ) - 1, @rekv = i.rekvId, @lepId = i.lepingid from deleted i

exec sp_update_palk_jaak @KPV1, @kpv2, @rekv, @lepId



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER spI_recalk_jaak 
ON palk_oper
FOR INSERT, UPDATE
AS
declare @kpv1	datetime,
	@kpv2	datetime,
	@rekv	int,
	@lepId	int,
	@id	int
select @id = @@IDENTITY  

select @kpv1 = '01.'+cast (datepart (month, i.kpv) as char(2)) +'.'+
	cast (datepart ( year, i.kpv) as char(4)),
	@kpv2 = dateadd (month,1, @kpv1 ) - 1, @rekv = i.rekvId, @lepId = i.lepingid from inserted i
exec sp_update_palk_jaak @KPV1, @kpv2, @rekv, @lepId
select @ID  as id, 'PALK_OPER' as tbl 





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_PALK_TAABEL1 ON [dbo].[palk_taabel1] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'PALK_TAABEL1' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_PALK_TAABEL2 ON [dbo].[palk_taabel2] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'PALK_TAABEL2' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_PV_KAART ON [dbo].[pv_kaart] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'PV_KAART' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_PV_OPER ON [dbo].[pv_oper] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'PV_OPER' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER trigid_raamat ON [dbo].[raamat] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'RAAMAT' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_REKV ON [dbo].[rekv] 
FOR INSERT 
AS
	select @@IDENTITY  as id, 'REKV' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigU_rekv ON rekv FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'arv' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, arv WHERE (deleted.id = arv.rekvid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''arv''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'nomenklatuur' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, nomenklatuur WHERE (deleted.id = nomenklatuur.rekvid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''nomenklatuur''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'journal' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, journal WHERE (deleted.id = journal.rekvid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''journal''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'asutus' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, asutus WHERE (deleted.id = asutus.rekvid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''asutus''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'saldo' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, saldo WHERE (deleted.id = saldo.rekvid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''saldo''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'library' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, library WHERE (deleted.id = library.rekvid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''library''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'userid' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, userid WHERE (deleted.id = userid.rekvid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''userid''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'aa' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, aa WHERE (deleted.id = aa.parentid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''aa''.'
            SELECT @status='Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'saldo1' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, saldo1 WHERE (deleted.id = saldo1.rekvid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''saldo1''.'
            SELECT @status='Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigD_rekv ON rekv FOR DELETE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* CASCADE DELETES TO 'arv' */
DELETE arv FROM deleted, arv WHERE deleted.id = arv.rekvid
/* CASCADE DELETES TO 'nomenklatuur' */
DELETE nomenklatuur FROM deleted, nomenklatuur WHERE deleted.id = nomenklatuur.rekvid
/* CASCADE DELETES TO 'journal' */
DELETE journal FROM deleted, journal WHERE deleted.id = journal.rekvid
/* CASCADE DELETES TO 'asutus' */
DELETE asutus FROM deleted, asutus WHERE deleted.id = asutus.rekvid
/* CASCADE DELETES TO 'saldo' */
DELETE saldo FROM deleted, saldo WHERE deleted.id = saldo.rekvid
/* CASCADE DELETES TO 'library' */
DELETE library FROM deleted, library WHERE deleted.id = library.rekvid
/* CASCADE DELETES TO 'userid' */
DELETE userid FROM deleted, userid WHERE deleted.id = userid.rekvid
/* CASCADE DELETES TO 'aa' */
DELETE aa FROM deleted, aa WHERE deleted.id = aa.parentid
/* CASCADE DELETES TO 'saldo1' */
DELETE saldo1 FROM deleted, saldo1 WHERE deleted.id = saldo1.rekvid
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigI_saldo ON saldo FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'rekv' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
ELSE
	select @@IDENTITY  as id, 'SALDO' as tbl 




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigU_saldo ON saldo FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'rekv' */
IF UPDATE(rekvid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
                SELECT @status = 'Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigI_saldo1 ON saldo1 FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'rekv' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
            SELECT @status='Failed'
        END
    END
/* PREVENT INSERTS IF NO MATCHING KEY IN 'asutus' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM asutus, inserted WHERE (asutus.id = inserted.asutusid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''asutus''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
ELSE
		select @@IDENTITY  as id, 'SALDO1' as tbl 




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigU_saldo1 ON saldo1 FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'rekv' */
IF UPDATE(rekvid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
                SELECT @status = 'Failed'
            END
    END
/* PREVENT UPDATES IF NO MATCHING KEY IN 'asutus' */
IF UPDATE(asutusid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM asutus, inserted WHERE (asutus.id = inserted.asutusid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''asutus''.'
                SELECT @status = 'Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_SORDER1 ON [dbo].[sorder1] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'SORDER1' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigU_sorder1 ON sorder1 FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'sorder2' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, sorder2 WHERE (deleted.id = sorder2.parentid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''sorder2''.'
            SELECT @status='Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigD_sorder1 ON sorder1 FOR DELETE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* CASCADE DELETES TO 'sorder2' */
DELETE sorder2 FROM deleted, sorder2 WHERE deleted.id = sorder2.parentid
/* CASCADE DELETES TO 'arvtasu' */
DELETE arvtasu FROM deleted, arvtasu WHERE deleted.id = arvtasu.sorderid
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigU_sorder2 ON sorder2 FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'sorder1' */
IF UPDATE(parentid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM sorder1, inserted WHERE (sorder1.id = inserted.parentid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''sorder1''.'
                SELECT @status = 'Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER sp_getid_sorder2
ON sorder2
FOR INSERT 
AS
select id from inserted



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigI_sorder2 ON sorder2 FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'sorder1' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM sorder1, inserted WHERE (sorder1.id = inserted.parentid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''sorder1''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigI_subkonto ON subkonto FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'library' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM library, inserted WHERE (library.id = inserted.kontoid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''library''.'
            SELECT @status='Failed'
        END
    END
/* PREVENT INSERTS IF NO MATCHING KEY IN 'asutus' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM asutus, inserted WHERE (asutus.id = inserted.asutusid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''asutus''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
ELSE
	select @@IDENTITY  as id, 'SUBKONTO' as tbl 




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigU_subkonto ON subkonto FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'library' */
IF UPDATE(kontoid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM library, inserted WHERE (library.id = inserted.kontoid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''library''.'
                SELECT @status = 'Failed'
            END
    END
/* PREVENT UPDATES IF NO MATCHING KEY IN 'asutus' */
IF UPDATE(asutusid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM asutus, inserted WHERE (asutus.id = inserted.asutusid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''asutus''.'
                SELECT @status = 'Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER sp_getid_subkonto
ON subkonto
FOR INSERT
AS
select id from inserted



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_TOOLEPING ON [dbo].[tooleping] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'TOOLEPING' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_TULUDKULUD ON [dbo].[tuludkulud] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'TULUDKULUD' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigU_userid ON userid FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'rekv' */
IF UPDATE(rekvid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM rekv, inserted WHERE (rekv.id = inserted.rekvid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''rekv''.'
                SELECT @status = 'Failed'
            END
    END
/* PREVENT UPDATES IF DEPENDENT RECORDS IN 'journal' */
IF UPDATE(id) AND @status<>'Failed'
    BEGIN
    IF (SELECT COUNT(*) FROM deleted, journal WHERE (deleted.id = journal.userid)) > 0
        BEGIN
            RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''journal''.'
            SELECT @status='Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER TrigD_userid ON userid FOR DELETE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT DELETES IF DEPENDENT RECORDS IN 'journal' */
IF (SELECT COUNT(*) FROM deleted, journal WHERE (deleted.id = journal.userid)) > 0
    BEGIN
    RAISERROR 44445 'Cannot delete or change record.  Referential integrity rules would be violated because related records exist in table ''journal''.'
    SELECT @status='Failed'
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_USERID ON [dbo].[userid] 
FOR INSERT 
AS
	select @@IDENTITY  as id, 'USERID' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER sp_getid_vorder1
On vorder1
FOR INSERT
AS
select id from inserted



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigI_vorder1 ON vorder1 FOR INSERT AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT INSERTS IF NO MATCHING KEY IN 'aa' */
IF @status<>'Failed'
    BEGIN
    IF(SELECT COUNT(*) FROM inserted) !=
   (SELECT COUNT(*) FROM aa, inserted WHERE (aa.id = inserted.kassaid))
        BEGIN
            RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''aa''.'
            SELECT @status='Failed'
        END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
	ROLLBACK TRANSACTION
ELSE
		select @@IDENTITY  as id, 'VORDER1' as tbl 



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER TrigU_vorder1 ON vorder1 FOR UPDATE AS 
DECLARE @status char(10)  /* USED BY VALIDATION STORED PROCEDURES */
SELECT @status='Succeeded'
/* PREVENT UPDATES IF NO MATCHING KEY IN 'aa' */
IF UPDATE(kassaid) AND @status<>'Failed'
    BEGIN
IF (SELECT COUNT(*) FROM inserted) !=
           (SELECT COUNT(*) FROM aa, inserted WHERE (aa.id = inserted.kassaid))
            BEGIN
                RAISERROR 44446 'Cannot add or change record.  Referential integrity rules require a related record in table ''aa''.'
                SELECT @status = 'Failed'
            END
    END
/* ROLLBACK THE TRANSACTION IF ANYTHING FAILED */
IF @status='Failed'
ROLLBACK TRANSACTION


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE TRIGGER sp_getid_vorder2
ON vorder2
FOR INSERT 
AS
select id from inserted



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER TRIGI_VORDER2 ON [dbo].[vorder2] 
FOR INSERT
AS
	select @@IDENTITY  as id, 'VORDER2' as tbl 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

