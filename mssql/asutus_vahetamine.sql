declare @UusAsutus	int,
	@VanaAsutus	int
select @VanaAsutus = 1454, @UusAsutus = 268
select * from asutus where nimetus like '%urve%'
update journal set asutusId = @uusAsutus where asutusId = @vanaAsutus
update arv set asutusId = @uusAsutus where asutusId = @vanaAsutus
update sorder1 set asutusId = @uusAsutus where asutusId = @vanaAsutus
update vorder1 set asutusId = @uusAsutus where asutusId = @vanaAsutus
update subkonto set asutusid = @uusasutus where asutusId = @vanaAsutus
update mk1 set asutusId = @uusasutus where asutusId = @vanaAsutus
update palk_kaart set parentId = @uusasutus where parentId = @vanaAsutus
update saldo1 set asutusId = @uusasutus where asutusId = @vanaAsutus
update teenused set asutusId = @uusasutus where asutusId = @vanaAsutus
update leping1 set asutusId = @uusasutus where asutusId = @vanaAsutus

delete from asutusaa where parentId = @vanaAsutus
delete from asutus where id = @vanaAsutus


