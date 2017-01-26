-- Function: sp_recalcarvjaak(integer)

-- DROP FUNCTION sp_recalcarvjaak(integer);

CREATE OR REPLACE FUNCTION sp_recalcarvjaak(integer)
  RETURNS numeric AS
$BODY$
declare tnArvId alias for 	$1;
	tmpArv record;	
	tmpSorder record;
	tmpVorder record;
	tmpSMK record;
	tmpVMK record;
	tmpJournal record;

	lnSumma numeric (12,4);
	lcArvKonto varchar(20);
	lctasuKonto varchar(20);
begin
-- arv prop

	Select * into tmpARV From arv Where Id = tnArvId ;

-- delete from arvtasu

	Delete From arvtasu Where arvid = tnArvId;

-- check for kassa

	for tmpSorder in 
	Select * From korder1 WHERE arvid = tnArvId And tyyp = 1 and rekvid = tmpArv.rekvid 
	loop
		if tmpARV.liik = 0 then
		
			lnSumma := tmpSorder.Summa;
		else
			lnSumma := -1 * tmpSorder.Summa;
		end if;

		Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
			(tnArvId, tmpARV.rekvid, tmpSorder.kpv, 1, tmpSorder.Id, lnSumma);

	end loop;

	for tmpvorder in
	Select * From korder1 WHERE arvid = tnArvId And tyyp = 2 and rekvid = tmpArv.rekvid
	loop
		if tmpARV.liik = 1 then

			lnSumma := tmpvorder.Summa;
		else
			lnSumma := -1 * tmpvorder.Summa;
		end if;

		Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
				(tnArvId, tmpARV.rekvid, tmpvorder.kpv, 1, tmpvorder.Id, lnSumma);

	end loop;


-- check for pank

	
	for tmpSMk in 
		Select mk.*, mk1.summa From mk inner join mk1 on mk.id = mk1.parentid 
			Where mk.arvid = tnArvId And mk.opt = 0 and mk1.asutusId = tmpArv.asutusId and mk.rekvid = tmpArv.rekvid
	loop

		if tmpARV.liik = 0 then


			lnSumma := tmpSMk.Summa;
		else
			lnSumma := -1 * tmpSMk.Summa;
		end if;
		Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
			(tnArvId, tmpARV.rekvid, tmpSMk.kpv, 1, tmpSMk.Id, lnSumma);

	end loop;

	for tmpVMk in
		Select mk.*, mk1.summa From mk inner join mk1 on mk.id = mk1.parentid 
			Where mk.arvid = tnArvId And mk.opt = 1 and mk1.asutusId = tmpArv.asutusId and mk.rekvid = tmpArv.rekvid
	loop
		if tmpARV.liik = 1 then
			lnSumma := tmpVMk.Summa;
		else
			lnSumma :=  -1 * tmpVMk.Summa;
		end if;
		Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
				(tnArvId, tmpARV.rekvid, tmpVMk.kpv, 1, tmpVMk.Id, lnSumma);

	end loop;
	

-- lausend

	If tmpARV.doklausId > 0 then

		raise notice 'lausend';

		Select konto Into lcArvKonto From dokprop Where Id = tmpARV.doklausId; 


		If tmpARV.liik = 0 then
			raise notice 'tmpARV.liik %',tmpARV.liik;
			raise notice 'tmpARV.asutusid %',tmpARV.asutusid;
			raise notice 'tmpARV.Number %',tmpARV.Number;

			if tmpArv.journalId > 0 then
				-- kontrollime arve konto
				select deebet into lctasukonto from journal1 where parentid = tmpArv.journalid order by id limit 1;
				if lcArvKonto <> lctasukonto then
					-- arve dokprop oli vigane, vahetame arve konto
					lcArvKonto := lctasukonto;
				end if;
			end if;

			for tmpJournal in
			Select Sum(curJournal.Summa) As Summa, Max(curJournal.kpv) As kpv, curJournal.Id  From curJournal
				where curJournal.asutusId = tmpARV.asutusId 
				AND Alltrim(curJournal.dok) = tmpARV.Number 
				AND curJournal.rekvid = tmpARV.rekvid
				AND curJournal.kreedit = lcArvKonto
				GROUP By curJournal.Id
			loop
				raise notice 'tmpJournal.Id %',tmpJournal.Id;

				Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
					(tnArvId, tmpARV.rekvid, tmpJournal.kpv, 3, tmpJournal.Id, tmpJournal.Summa);

			end loop;
		Else
			raise notice 'tmpARV.liik %',tmpARV.liik;
				-- kontrollime arve konto
			select kreedit into lctasukonto from journal1 where parentid = tmpArv.journalid order by id limit 1;
			if lcArvKonto <> lctasukonto then
				-- arve dokprop oli vigane, vahetame arve konto
				lcArvKonto := lctasukonto;
			end if;

			for tmpJournal in 
			Select Sum(curJournal.Summa) As Summa, Max(curJournal.kpv) as kpv, curJournal.Id From curJournal
				where curJournal.asutusId = tmpARV.asutusId 
				AND Alltrim(curJournal.dok) = tmpARV.Number 
				AND curJournal.rekvid = tmpARV.rekvid
				AND curJournal.deebet = lcArvKonto
				GROUP By curJournal.Id


			loop
				raise notice 'tmpJournal.Id %',tmpJournal.Id;
				Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
					(tnArvId, tmpARV.rekvid, tmpJournal.kpv, 3, tmpJournal.Id, tmpJournal.Summa);

			end loop;

		End if;

		

	End if;

	Return sp_updatearvjaak(tmpARV.Id,date());

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_recalcarvjaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_recalcarvjaak(integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_recalcarvjaak(integer) TO public;
GRANT EXECUTE ON FUNCTION sp_recalcarvjaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_recalcarvjaak(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_recalcarvjaak(integer) TO taabel;
