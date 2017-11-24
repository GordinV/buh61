CREATE OR REPLACE  FUNCTION sp_salvesta_objekt(integer, integer, character varying, character varying, text, integer, integer, integer, integer, integer,
	integer,integer, integer, numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tcKood alias for $3;
	tcNimetus alias for $4;
	ttMuud alias for $5;
	tnTun1 alias for $6;
	tnTun2 alias for $7;
	tntun3 alias for $8;
	tntun4 alias for $9;
	tnTun5 alias for $10;
	tnLibId alias for $11;
	tnParentId alias for $12;
	tnAsutusid alias for $13;
	tnNait01 alias for $14;
	tnNait02 alias for $15;
	tnNait03 alias for $16;
	tnNait04 alias for $17;
	tnNait05 alias for $18;
	tnNait06 alias for $19;
	tnNait07 alias for $20;
	tnNait08 alias for $21;
	tnNait09 alias for $22;
	tnNait10 alias for $23;
	tnNait11 alias for $24;
	tnNait12 alias for $25;
	tnNait13 alias for $26;
	tnNait14 alias for $27;
	tnNait15 alias for $28;
	ttSelg alias for $29;

	lcLibrary varchar(20);

	lnId int; 
	lrCurRec record;
begin
	if tnId = 0 then
		lcLibrary = 'OBJEKT';
	else
		select library into lcLibrary from library where id = tnId;
	end if;

	lnId = sp_salvesta_library(tnId, tnRekvId, tcKood, tcNimetus, lcLibrary, ttMuud, tnTun1, tnTun2, tnTun3, tnTun4, tnTun5);

	if (select count(id) from objekt where libid = lnId) = 0 then
			-- lisame uus kiri
		insert into objekt (parentid, libid, asutusid, nait01, nait02, nait03, nait04, nait05, nait06, nait07, nait08, nait09, nait10,nait11, nait12, nait13, nait14, nait15, muud)
			values (tnParentId, lnId, tnAsutusId, tnnait01,tnnait02,tnnait03,tnnait04, tnnait05,tnnait06,tnnait07,tnnait08,tnnait09,tnnait10,
			tnnait11,tnnait12,tnnait13,tnnait14,tnnait15,ttMuud);
	else
		update objekt set
			parentid = tnParentId,
			libid = lnId,
			asutusid = tnAsutusId,
			nait01 = tnnait01,
			nait02 = tnnait02,
			nait03 = tnnait03,
			nait04 = tnnait04,
			nait05 = tnnait05,
			nait06 = tnnait06,
			nait07 = tnnait07,
			nait08 = tnnait08,
			nait09 = tnnait09,
			nait10 = tnnait10,
			nait11 = tnnait11,
			nait12 = tnnait12,
			nait13 = tnnait13,
			nait14 = tnnait14,
			nait15 = tnnait15,
			muud = ttMuud
		where libid = lnId;

	end if;


         return  lnId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
 /*
ALTER FUNCTION sp_salvesta_objekt(integer, integer, character varying, character varying,  text, integer, integer, integer, integer, integer,
	integer,integer, integer, numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_objekt(integer, integer, character varying, character varying,  text, integer, integer, integer, integer, integer,
	integer,integer, integer, numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_objekt(integer, integer, character varying, character varying,  text, integer, integer, integer, integer, integer,
	integer,integer, integer, numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,text) TO dbpeakasutaja;
*/