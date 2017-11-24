-- Function: sp_del_toiming(integer)
/*
select * from raamat where dokument = 'toiming' order by id desc limit 20
*/
-- DROP FUNCTION sp_del_toiming(integer);

CREATE OR REPLACE FUNCTION sp_del_toiming(integer)
  RETURNS smallint AS
$BODY$

declare 


	tnId alias for $1;
	v_toiming record;

begin
	select * into v_toiming from toiming where id = tnId;
	
	Delete From toiming Where Id = tnid;
	-- kustutame viivise info
	delete from viiviseinfo where intressId = tnId;
	-- kustutame dekl info
--	delete from viiviseinfo where dokId = tnId and dokliik = 1;
	-- lausend
	perform sp_del_journal(v_toiming.journalid, 1);

	Return 1;


end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_del_toiming(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_toiming(integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_toiming(integer) TO public;
GRANT EXECUTE ON FUNCTION sp_del_toiming(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_del_toiming(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_del_toiming(integer) TO taabel;
