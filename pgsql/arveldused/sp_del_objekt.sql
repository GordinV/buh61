-- Function: sp_del_objekt(integer, integer)

-- DROP FUNCTION sp_del_objekt(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_objekt(integer, integer)
  RETURNS smallint AS
$BODY$


declare 



	tnId alias for $1;

	tnOpt alias for $2;

	lnReturn integer;
	lcObjekt varchar(20);

begin
--	select kood into lcObjekt from library where id = tnId;
	

--	if  (select count(id) from library where library = 'MOTTED' and tun2 = tnId) = 0 and 
--		(select count(id) from leping1 where objektid = tnId) = 0 AND 
--		(select count(id) from arv where objekt = ifnull(lcObjekt,'null')) = 0 	then

		Delete From library Where Id = tnid;
		lnreturn = 1;
--		if 
--	else
--		if (select count(id) from library where library = 'MOTTED' and tun2 = tnId) > 0 then
--			raise notice 'Motted, ei saa kustuta';
--		end if;
--		if (select count(id) from leping1 where objektid = tnId) > 0 then
--			raise notice 'lepingud, ei saa kustuta';
--		end if;
--		if (select count(id) from arv where objekt = ifnull(lcObjekt,'null')) > 0 then
--			raise notice 'Arved, ei saa kustuta';
--		end if;
--		lnreturn = 0;
--	end if; 

	if  (select count(id) from library where library = 'MOTTED' and tun2 = tnId) > 0 then
		delete from library where tun2 = tnId;
	end if;
	Return lnReturn;



end; 


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_del_objekt(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_objekt(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_del_objekt(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_objekt(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_del_objekt(integer, integer) TO dbpeakasutaja;
