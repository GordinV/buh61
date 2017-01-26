-- Function: sp_del_mk1(integer, integer)
/*
select * from mk order by id desc limit 1
select * from hoojaak
DELETE FROM HOOJAAK 	where id = 4
delete from hootehingud where id in (11, 12)
select sp_del_mk1(83, 0)
select sp_calc_hoojaak(3)
*/
-- DROP FUNCTION sp_del_mk1(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_mk1(integer, integer)
  RETURNS smallint AS
$BODY$


declare 


	tnId alias for $1;
	tnOpt alias for $2;

	lnisikId integer;


begin

	Delete From mk Where Id = tnid;

	if found then
		delete from mk1 where parentid = tnId;
		delete from arvtasu where pankkassa = 1 and sorderid = tnid;
		select isikid into lnIsikId from hootehingud where ltrim(rtrim(doktyyp)) = 'PANK' and dokid = tnId order by id desc limit 1;
		delete from hootehingud where ltrim(rtrim(doktyyp)) = 'PANK' and dokid = tnId;

		if ifnull(lnIsikId,0) > 0 then
			perform sp_calc_hoojaak(lnIsikId);
		end if;
		Return 1;
	else
		Return 0;
	end if;





end; 


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_del_mk1(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_mk1(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_mk1(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_del_mk1(integer, integer) TO dbkasutaja;
