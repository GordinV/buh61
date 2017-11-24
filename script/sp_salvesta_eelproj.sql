CREATE OR REPLACE FUNCTION sp_salvesta_eelproj(integer, integer, integer, integer, integer,integer, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnaasta alias for $3;
	tnkuu alias for $4;
	tnstaatus alias for $5;
	tnkinnitaja alias for $6;
	ttmuud alias for $7;

	lnId int; 


begin



if tnId = 0 then
	-- uus kiri

	insert into pv_oper (rekvid,aasta,kuu,staatus,kinnitaja,muud) 
		values (tnrekvid,tnaasta,tnkuu,tnstaatus,tnkinnitaja,ttmuud);

	lnId:= cast(CURRVAL('public.eelproj_id_seq') as int4);

else
	-- muuda 
	update eelproj set 
		aasta = tnAasta,
		kuu = tnKuu,
		staatus = tnStaatus,
		tnKinnitaja = tnKinnitaja,
		muud = ttmuud
	where id = tnId;

	lnId := tnId;
end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelproj(integer, integer, integer, integer, integer,integer, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelproj(integer, integer, integer, integer, integer,integer, text) TO dbpeakasutaja;
