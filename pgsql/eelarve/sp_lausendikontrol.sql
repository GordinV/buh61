-- Function: sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying)

-- DROP FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying);
/*
select sp_lausendikontrol
('201000','500004', '800699', '800699', '10120', '', '5000', '','185101', date(2012,12,31), 'EUR')

select * from library where library = 'TEGEV'

*/

CREATE OR REPLACE FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying)
  RETURNS character varying AS
$BODY$

DECLARE tcDb alias for $1;
	tcKr alias for $2;
	tcTPD alias for $3;
	tcTPK alias for $4;
	tcTT alias for $5;
	tcAllikas alias for $6;
	tcEelarve alias for $7;
	tcRahavoog alias for $8;
	tcOmaTP alias for $9;
	tdKpv alias for $10;
	tcValuuta alias for $11;
	lnTPD int;
	lnTPK int;
	lnTT int;
	lnEelarve int;
	lnAllikas int;
	lnRahavoog int;
	lcMsg text;
	lcMsg1 text;
	lcKr varchar(20);
	lcDb varchar(20);
	lcOmaTp varchar(20);

	ldKpv date;
	v_konto record;
	lviga integer;
begin	

	raise notice 'tcTPK %',tcTPK;
	lViga = 0;
	lnTPD = 0;
	lnTPK = 0;
	lnTT = 0;
	lnEelarve = 0;
	lnAllikas = 0;
	lnRahavoog = 0;
	lcMsg = '';
	lcMsg1 = '';

	if tdkpv = date(2010,12,31) then
		return lcMsg;
	end if;

	raise notice 'val.kontrol kpv %',tdKpv;
	raise notice 'val.kontrol tcValuuta %',tcValuuta;

-- kontrollin valuuta kehtivus 
	if fnc_valkehtivus(tcValuuta, tdKpv) = 0 then
		raise notice 'valuuta ei kehti';
		lcMsg = ' Valuuta ei kehti';
	else
		raise notice 'valuuta kehtib';

	end if;

-- kontrollin oma TP
	if not empty (tcOmaTP) and (tcTPD = tcOmaTP or tcTPK = tcOmaTp)  then	
		lcMsg1 =  ' TP kood on vale, ei saa kasutada tehingus oma TP kood ';			
	end if;

	raise notice 'lcmsg1 %',lcMsg1;
	if (left(tcOmaTP,6) = '185101' or tcOmaTP = '185130') and (left(tcDb,1) = '7' or left(tckr,1) = '7')  then
		lcMsg1 = '';
	end if;

	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;

	raise notice 'lcmsg %',lcMsg;

	-- Tp kontoll

	if left(ltrim(rtrim(tcTPD)),4) = '1851' and len(ltrim(rtrim(tcTPD))) = 6 then
		lcMsg1 = 'TP-D Ei saa kasuta vana kohalik TP koodid';
	end if;
	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;

	if left(ltrim(rtrim(tcTPK)),4) = '1851' and len(ltrim(rtrim(tcTPK))) = 6 then
		lcMsg1 = 'TP-K Ei saa kasuta vana kohalik TP koodid';
	end if;
	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;
-- konto kehtivus (D)
	select aasta into lnTpD from kontoinf where parentid in (select id from library where kood = tcDb and library = 'KONTOD') order by rekvid  limit 1;
	raise notice 'Konto date %',lnTpD;
	if ifnull(lnTPD,0) > 0 AND lnTPD > 20120101 then
		ldKpv = date(val(left(lnTPD::varchar(8),4)),val(substr(lnTPD::varchar(8),5,2)),val(substr(lnTPD::varchar(8),7,2)));
--		raise notice 'Konto date %',ldKpv;
--		raise notice 'Konto date %',tdKpv;

		if tdKpv > ldKpv then
			lcMsg1 = 'Konto D, Ei saa kasuta, sest kood ei ole kehtiv';
		end if; 
	end if; 
	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;

-- konto kehtivus (K)
	select aasta into lnTpD from kontoinf where parentid in (select id from library where kood = tcKr and library = 'KONTOD') order by rekvid  limit 1;
	raise notice 'Konto date %',lnTpD;
	if ifnull(lnTPD,0) > 0 AND lnTPD > 20120101 then
		ldKpv = date(val(left(lnTPD::varchar(8),4)),val(substr(lnTPD::varchar(8),5,2)),val(substr(lnTPD::varchar(8),7,2)));
		if tdKpv > ldKpv then
			lcMsg1 = 'Konto K, Ei saa kasuta, sest kood ei ole kehtiv';
		end if; 
	end if; 
	
	if ifnull(lnTPK,0) > 0 then
		ldKpv = date(val(left(lnTPK::varchar(8),4)),val(substr(lnTPK::varchar(8),5,2)),val(substr(lnTPK::varchar(8),7,2)));
		if tdKpv > ldKpv then
			lcMsg1 = 'TP-D,Ei saa kasuta, sest TP kood ei ole kehtiv';
		end if; 
	end if; 


	select tun4,tun5 into lnTpD,lnTPK from library where kood = tcTPD and library = 'TP' order by tun4, tun5 desc limit 1;
	raise notice 'tp date %',lnTpD;
	if ifnull(lnTPD,0) > 0 then
		ldKpv = date(val(left(lnTPD::varchar(8),4)),val(substr(lnTPD::varchar(8),5,2)),val(substr(lnTPD::varchar(8),7,2)));
		if tdKpv < ldKpv then
			lcMsg1 = 'TP-D, Ei saa kasuta, sest TP kood ei ole kehtiv';
		end if; 
	end if; 
	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;
	
	if ifnull(lnTPK,0) > 0 then
		ldKpv = date(val(left(lnTPK::varchar(8),4)),val(substr(lnTPK::varchar(8),5,2)),val(substr(lnTPK::varchar(8),7,2)));
		if tdKpv > ldKpv then
			lcMsg1 = 'TP-D,Ei saa kasuta, sest TP kood ei ole kehtiv';
		end if; 
	end if; 
	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;

	select tun4,tun5 into lnTpD,lnTPK from library where kood = tcTPK and library = 'TP' order by tun4, tun5 limit 1;
	if ifnull(lnTPD,0) > 0 then
		ldKpv = date(val(left(lnTPD::varchar(8),4)),val(substr(lnTPD::varchar(8),5,2)),val(substr(lnTPD::varchar(8),7,2)));
		if tdKpv < ldKpv then
			lcMsg1 = 'TP-K, Ei saa kasuta, sest TP kood ei ole kehtiv';
		end if; 
	end if; 
	
	if ifnull(lnTPK,0) > 0 then
		ldKpv = date(val(left(lnTPK::varchar(8),4)),val(substr(lnTPK::varchar(8),5,2)),val(substr(lnTPK::varchar(8),7,2)));
		if tdKpv > ldKpv then
			lcMsg1 = 'TP-K,Ei saa kasuta, sest TP kood ei ole kehtiv';
		end if; 
	end if; 
	
	-- deebet

	select * into v_konto from library where kood = tcDb and library = 'KONTOD' order by id desc limit 1;
	if ifnull(v_konto.kood,'PUUDUB') = 'PUUDUB' or empty(tcDb) or len(tcDb) < 6 then
		lcMsg = lcMsg + 'Viga: Deebet konto: puudub või vale konto ';	
		return lcMsg;	 
	end if;
	lcDb = v_konto.kood;
	if v_konto.tun1 = 1 and empty(tcTPD) then
		lnTPD = 1;
	end if;
	if v_konto.tun2 = 1 and (empty(tcTT) or empty(tcEelarve)) then
		if not empty(tcTT) then		
			lnTT = 0;
		end if;
		lnEelarve = 1;
		if (left(tcDb,1) = '9' or LEFT(tcDb,2) = '61' )  then
			lnEelarve = 0;
		end if;
	end if;
	if v_konto.tun3 = 1 and (empty(tcAllikas) or isdigit(tcAllikas) = 0) then
		lnAllikas = 1;	

	end if;
	if v_konto.tun4 = 1 and empty(tcRahavoog) then
		lnRahavoog = 1;
	end if;

-- kontrollin kontogrupp '7'
	if left(tcDb,1) = '7' then
		if (left(tcTPD,3) = '800' or left(tcTPD,3) = '900')   then
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood ';
		end if;

		if not empty (tcOmaTP) and left(tcTPD,4) <> left(tcOmaTP,4) then 
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: saab siirdeid kajastada ainult nende TP koodidega, mille esimesed 4 numbrit on samad ';
		end if;

	end if;


	if not empty(v_konto.muud) and v_konto.muud = '*' then
		RAISE NOTICE 'Eri konto %',v_konto.muud;
		if tcRahavoog <> '01' then
			lnTPD = 0;
			lnTPK = 0;
			lnTT = 0;
			lnEelarve = 0;
			lnAllikas = 0;
		end if;
	end if;

-- maksud
/*
	if (left(tcDb,4) = '2030' or left(tcDb,4) = '1037') and tcTPD <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;
--parandetud J.tsekanina
*/
	if (left(tcDb,5) = '20200') then
--		raise notice 'Kontrollin 20200';
		if tcTPD = '800699' or left(tcTPD,4) = '9006'  then	
--			raise notice 'kontoll %',tcTPD;
		else
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: alati 800699 '+left(tcTPD,4);
		end if;
	end if;
	if left(tcDb,5) = '10393' and tcTPD <> '800699'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: alati 800699 ';
	end if;
/*
	if (left(tcDb,3) = '102'  ) and tcTPD <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;
*/
	if (left(tcDb,5) = '60100' or left(tcDb,5) = '60101' or left(tcDb,5) = '60102' or tcDb = '601095' ) and tcTPD <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;

-- Sots.toetused
/*
	if (left(tcDb,3) = '413' ) and tcTPD <> '800699'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: uldjuhul 800699 ';
	end if;
*/

-- pank
	if (left(tcDb,4) = '1001' or tcDb = '550012' or  tcDb = '655000') and left(tcTPD,4) <> '8004'  then	
		lcMsg = lcMsg + 'Deebet, ei saa kasutada see TP kood: alati 8004** ';
	end if;
	
--palk
	if left(tcDb,3) = '500' then
		if tcTPD <> '800699' and left(tcTPD,4) <> '9006'  then	
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: alati 800699 ';
		end if;
	end if;
--omakapital
	if left(tcDb,3) = '298' and (tcRahavoog <> '28' and tcRahavoog <> '00' and tcRahavoog <> '05' and tcRahavoog <> '18' and tcRahavoog <> '38' and tcRahavoog <> '21' and tcRahavoog <> '41' and tcRahavoog <> '43') then	
		lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
	end if;

--eraldised
	if (left(tcDb,3) = '206' or left(tcDb,3) = '256') and (tcRahavoog <> '00' and tcRahavoog <> '06' and tcRahavoog <> '41' and tcRahavoog <> '42') then	
		lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
	end if;

--laenud
 	if v_konto.tun4 = 1 then

		if (left(tcDb,3) = '208' or left(tcDb,3) = '258') and (tcRahavoog <> '36' and tcRahavoog <> '35' and tcRahavoog <> '05' and tcRahavoog <> '06' and tcRahavoog <> '41' and tcRahavoog <> '42' and tcRahavoog <> '43') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;

		if (left(tcDb,4) = '1032' or left(tcDb,4) = '1532') and not empty (tcRahavoog) and (tcRahavoog <> '01' and tcRahavoog <> '02' and tcRahavoog <> '23' and tcRahavoog <> '02' and tcRahavoog <> '21') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;
	end if;


	-- Kreedit

	raise notice 'Kreedit, tctpk %',tcTPK;
	select * into v_konto from library where kood = tcKr and library = 'KONTOD' order by id desc limit 1;

	if ifnull(v_konto.kood,'PUUDUB') = 'PUUDUB' or empty(tcKr) or len(tcKr) < 6 then
		lcMsg = lcMsg + 'Viga: Kreedit konto: puudub või vale konto ';	
		return lcMsg;	 
	end if;
	lcKr = v_konto.kood;

	if v_konto.tun1 = 1 and empty(tcTPK) then
		raise notice 'v_konto.tun1 = 1 and empty(tcTPK) %',tcTPK ;
		lnTPK = 1;
--		lcMsgK  =' TP-K ';
	end if;
	if v_konto.tun2 = 1 and (empty(tcTT) or empty(tcEelarve)) and lnTT = 0 then
		if not empty(tcTT) then		
			lnTT = 0;
		end if;
		lnEelarve = 1;
		if (left(tcKr,1) = '9' or left(tcKr,3) = '154' or left(tcKr,3) = '155' or left(tcKr,3) = '156' or tcKr = '350000') then
			lnEelarve = 0;
		end if;
	end if;
	if v_konto.tun3 = 1 and (empty(tcAllikas) or isdigit(tcAllikas) = 0) and lnAllikas = 0 then
		lnAllikas = 1;
	end if;
	if v_konto.tun4 = 1 and empty(tcRahavoog) and lnRahavoog = 0 then
		lnRahavoog = 1;
	end if;

	if left(tcKr,1) = '7' then
		if (left(tcTPK,3) = '800' or left(tcTPK,3) = '900')   then
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood ';
		end if;

		if not empty (tcOmaTP) and left(tcTPK,4) <> left(tcOmaTP,4) then 
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: saab siirdeid kajastada ainult nende TP koodidega, mille esimesed 4 numbrit on samad ';
		end if;

	end if;
	


	if not empty(v_konto.muud) and v_konto.muud = '*' then
		RAISE NOTICE 'Eri konto %',v_konto.muud;
		if tcRahavoog <> '01' then
			lnTPD = 0;
			lnTPK = 0;
			lnTT = 0;
			lnEelarve = 0;
			lnAllikas = 0;
		end if;
	end if;

--maksud
/*
	if (left(tcKr,4) = '2030' or left(tcKr,4) = '1037') and tcTPK <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;
*/
	if (left(tcKR,5) = '20200') then 
		if ltrim(rtrim(tcTPK)) = '800699' or left(ltrim(rtrim(tcTPK)),4) = '9006' then	
		else
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: TP kood alati 800699 (9006**)';
		end if;
	end if;
	if (left(tcKR,5) = '10393') and tcTPK <> '800699'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: TP kood alati 800699 ';
	end if;
/*
	if (left(tcKr,3) = '102') and tcTPK <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003  ';
	end if;
*/
	if (left(tcKr,5) = '60100' or left(tcKr,5) = '60101' or left(tcKr,5) = '60102' or tcKr = '601095' ) and tcTPK <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;

-- Sots.toetused
/*
	if (left(tcKr,3) = '413' ) and tcTPK <> '800699'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: uldjuhul kasutatakse 800699 ';
	end if;
*/
-- pank
	if (left(tcKr,4) = '1001' or tcKr = '550012' or tcKr = '655000') and left(tcTPK,4) <> '8004'  then	
		lcMsg = lcMsg + 'Kreedit, ei saa kasutada see TP kood: alati 8004** ';
	end if;
--palk
	if left(tcKr,3) = '500' then 
		if tcTPK <> '800699' and left(tcTPK,4) <> '9006'  then	
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: alati 800699 ';
		end if;
	end if;

--omakapital
  	if v_konto.tun4 = 1 then

		if left(tcKr,3) = '298' and (tcRahavoog <> '28' and tcRahavoog <> '00' and tcRahavoog <> '05' and tcRahavoog <> '18' and tcRahavoog <> '38' and tcRahavoog <> '21' and tcRahavoog <> '41' and tcRahavoog <> '43') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;
	end if;
--eraldised
 	if v_konto.tun4 = 1 then

		if (left(tcKr,3) = '206' or left(tcKr,3) = '256') and (tcRahavoog <> '00' and tcRahavoog <> '06' and tcRahavoog <> '41' and tcRahavoog <> '42') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;
	end if;
--laenud
 	if v_konto.tun4 = 1 then

		if (left(tcKr,3) = '208' or left(tcKr,3) = '258') and (tcRahavoog <> '36' and tcRahavoog <> '35' and tcRahavoog <> '05' and tcRahavoog <> '06' and tcRahavoog <> '41' and tcRahavoog <> '42' and tcRahavoog <> '43') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;

		if (left(tcKr,4) = '1032' or left(tcKr,4) = '1532') and (tcRahavoog <> '01' and tcRahavoog <> '02' and tcRahavoog <> '23' and tcRahavoog <> '02' and tcRahavoog <> '21') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;
	end if;


-- kontrollin RV 01 + TP
	if tcKr = '253800' then
		if tcRahavoog = '01' and empty(tcTPK) then
			lnTPK = 1;
		else
			lnTPK = 0;
		end if;
	end if;

	raise notice 'lcmsg %',lcMsg;
	
	if lnTPD = 1 then
		lcMsg = lcMsg + 'TP-D ';
	end if;
	if lnTPK = 1 then
		lcMsg = lcMsg + ' TP-K';
	end if;
	if lnTt = 1 then
		lcMsg = lcMsg + ' Tegevusalla ';
	end if;
	if lnEelarve = 1 then
		lcMsg = lcmsg + ' Eelarve ';
	end if;
	if lnAllikas = 1 then
		lcmsg = lcmsg + ' Allikas ';
	end if;
	if lnRahavoog = 1 then
		lcmsg = lcmsg + 'Rahavoog ';
	end if;

-- kontrollin grupp 506
	if left(tcDb,3) = '506' then 
		if tcTPD <> '800699' and left(tcTPD,4) <> '9006' then
			lcMsg = lcMsg + ' TP-D kood on vale, peaks olla 800699 ';
		end if;
	end if;

-- kontrollin kontogrupp '9'
	if (left(tcDb,1) = '9' or left(tcKr,1) = '9') and (tcDb <> '999999' and tcKr <> '999999') and left(tcRahavoog,1) <> '9' and lnRahavoog = 1 then
		lcMsg = lcMsg + ' RV kood on vale, peaks olla 90-99 ';
	end if;



	if (tcRahavoog = '11' or tcRahavoog = '12') and left(tcDb,3) <> left(tcKr,3)  then
		lviga = 1;
		if left(tcDb,2) = '61' then
			lViga = 0;
		end if;

		if lViga = 1 and left(tcDb,2) = '29' then
			lViga = 0;
		end if;
		if lViga = 1 then
--			RAISE NOTICE 'left(tcDb,2) %',left(tcDb,2);
			lcMsg = lcMsg + ' DB konto on vale, see peab olema vordne kontodega 61xxx  ';			
		end if;
	end if;
	raise notice 'lcmsg %',lcMsg;

	if not empty (ltrim(rtrim(lcmsg))) then
		lcMsg = 'Viga Db:'+ LTRIM(RTRIM(lcdb))+' '+'Kr:'+ LTRIM(RTRIM(lcKr))+ ' puudub eelarve koodid: '+lcMsg; 
	END IF;
	raise notice 'lcmsg %',lcMsg;

	return lcMsg;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) TO dbpeakasutaja;
