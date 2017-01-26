-- Function: sp_del_toiming(integer)

-- DROP FUNCTION sp_del_toiming(integer);

CREATE OR REPLACE FUNCTION sp_del_toiming(integer)
  RETURNS smallint AS
$BODY$

declare 


	tnId alias for $1;
	v_toiming record;
	lnDekl integer;

begin
	select * into v_toiming from toiming where id = tnId;
	
	Delete From toiming Where Id = tnid;
	-- kustutame viivise info
	delete from viiviseinfo where intressId = tnId;
	-- kustutame dekl info
--	delete from viiviseinfo where dokId = tnId and dokliik = 1;
	-- lausend
	if v_toiming.tyyp = 'TASU' then
		select deklId into lnDekl from dekltasu where tasuid = v_toiming.id limit 1;
		delete from dekltasu where tasuid = v_toiming.id;
		perform sp_recalc_rekljaak(lnDekl);
		perform sp_muuda_deklstaatus(lnDekl, 1);
	end if;
	perform sp_del_journal(v_toiming.journalid, 1);

	Return 1;


end; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_del_toiming(integer)
  OWNER TO vlad;
