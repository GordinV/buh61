declare @id	int,
	@kontoid	int,
	@asutusid	int,
	@konto	varchar(20),
	@YEAR INT,
	@REKViD	INT

declare cur_kontod cursor
for select * from SUBKONTOIDX

open cur_kontod
fetch cur_kontod into @kontoid	, @asutusid, @REKViD
while @@fetch_status = 0
begin
	 IF (SELECT COUNT(id) FROM library where id = @kontoid) = 1 and
		(select count(id) from asutus where id = @asutusId) =1
		begin
			select @id = id from subkonto 
			where kontoid = @kontoid 
			and asutusId = @asutusid
			and rekvid = @rekvid

			set @id = isnull(@id, 0)
			if @id = 0
			begin
				insert into subkonto (rekvid, kontoid, asutusid, aasta, algsaldo) values (@rekvid, @kontoid, @asutusid, 2003, 0)
			end
		end
	fetch cur_kontod into @kontoid	, @asutusid, @REKViD
end
close cur_kontod
deallocate cur_kontod
