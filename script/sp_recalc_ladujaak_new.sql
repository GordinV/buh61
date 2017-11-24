-- Function: sp_recalc_ladujaak(integer, integer, integer)

-- DROP FUNCTION sp_recalc_ladujaak(integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_recalc_ladujaak(integer, integer, integer)
  RETURNS smallint AS
$BODY$

declare 

	tnrekvId	ALIAS FOR $1;
	tnNomid	ALIAS FOR $2;
	tnArveId	ALIAS FOR $3;	
	cur_ladusisearved record;
	cur_v_arved record;
	v_ladu_config record;
	cur_ladujaak_valja record;
	cur_ladujaak_sise record;
	recArv	record;
	recArv1	record;
	lnCount int;
	ldKpv date;

	lnNomid1 int;
	lnNomid2 int;
	lnArveId1 int;
	lnArveId2 int;

	lnId int;

begin



raise notice ' alg  ';

lnNomId1 = 0;
lnNomid2 = 9999999;

if tnNomId > 0 then
	lnNomId1 = tnNomId;
	lnNomid2 = tnNomId;	
end if;
lnArveId1 = 0;
lnArveid2 = 9999999;

if tnArveId > 0 then
	lnArveId1 = tnArveId;
	lnArveid2 = tnArveId;	
end if;


select * into v_ladu_config from ladu_config where rekvid = tnrekvId;


-- clearn up old data

delete from ladu_jaak 
	where rekvid = tnRekvId  
	and ladu_jaak.nomid >= lnNomId1 
	and ladu_jaak.nomid <= lnNomId2 
	and dokItemId in (select id from arv1 where parentid >= lnArveId1 and parentid <= lnArveid2);

-- insert new jaagid (+)

insert into ladu_jaak (rekvid, dokItemId, nomId, userid,kpv, hind,kogus, maha, jaak  )
	SELECT arv.rekvid, arv1.Id, arv1.nomId, arv.userId, arv.kpv, arv1.hind, arv1.kogus, 0, arv1.kogus
	from arv inner join arv1 on arv.id = arv1.parentid 
	where arv.rekvid = tnRekvid
	and arv.liik = 1 and arv.operId > 0
	and arv1.nomid >= lnNomId1 
	and arv1.nomid <= lnNomId1 
	and arv.id >= lnArveId1 and arv.id <= lnArveid2;


-- insert new jaagid (-)

insert into ladu_jaak (rekvid, dokItemId, nomId, userid,kpv, hind,kogus, maha, jaak  )
	SELECT arv.rekvid, arv1.Id, arv1.nomId, arv.userId, arv.kpv, arv1.hind, (-1 * arv1.kogus), 0, (-1 * arv1.kogus)
	from arv inner join arv1 on arv.id = arv1.parentid 
	where arv.rekvid = tnRekvid
	and arv.liik = 0 and arv.operId > 0
	and arv1.nomid >= lnNomId1 
	and arv1.nomid <= lnNomId2 
	and arv.id >= lnArveId1 and arv.id <= lnArveid2;

		
-- update dok. inform

update arv1 set maha = 0 where parentid in (select id from arv where arv.rekvid = tnRekvid
	and arv.liik = 1 and arv.operId > 0 )
	and arv1.nomid >= lnNomId1 
	and arv1.nomid <= 1nNomId2 
	and arv.id >= lnArveId1 and arv.id <= lnArveid2;



--vara valjaminek
-- list of reduced items

for cur_ladujaak_valja  in 
	select   id, jaak, maha, kpv, dokItemId   
	from ladu_jaak
	where rekvid = tnrekvId
	and jaak < 0
	and ladu_jaak.nomid >= lnNomid1
	and ladu_jaak.nomid <= lnNomId2
	order by kpv

loop
	-- look for item 
	for cur_ladujaak_sise  in 
		select   id, jaak, maha, kpv, dokItemId   
			from ladu_jaak
			where rekvid = tnrekvId
			and jaak > 0
			and ladu_jaak.nomid >= lnNomid1
			and ladu_jaak.nomid <= lnNomId2
			order by kpv
	loop
		-- check if avail. kogus >= reduced
		if cur_ladujaak_sise.jaak >= (-1 * cur_ladujaak_valja.kogus) then 
			-- update reduced item
			update ladu_jaak set jaak = 0 where id = cur_ladujaak_valja.id;
			-- update avail item
			update ladu_jaak set jaak = kogus +  cur_ladujaak_valja.jaak, maha = maha - cur_ladujaak_valja.jaak where id = cur_ladujaak_sise.id ;
			-- update arv1 rea status
			update arv1 set maha = 1 where id = cur_ladujaak_sise.dokitemid;
			
			exit;

		else
			-- valja qantity more than avail.item
	
			-- update reduced item
			update ladu_jaak set jaak = jaak + cur_ladujaak_sise where id = cur_ladujaak_valja.id;
			-- update avail item
			update ladu_jaak set jaak = 0, maha = cur_ladujaak_sise.kogus where id = cur_ladujaak_sise.id;
			-- update arv1 rea status
			update arv1 set maha = 1 where id = cur_ladujaak_sise.dokitemid;
		end if;

	end loop;
	
end loop;

delete from ladu_jaak where jaak = 0;


return 1;



end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION sp_recalc_ladujaak(integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO taabel;
