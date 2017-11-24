CREATE OR REPLACE FUNCTION sp_TASUARV(int4, int4, int4, date, numeric(12,4), int4, int4)
  RETURNS numeric(12,4) AS
'
declare 
	tnDokId alias for 	$1;
	tnArvId alias for 	$2; 
	tnRekvId alias for 	$3; 
	tdkpv	 alias for 	$4; 
	tnSumma  alias for 	$5; 
	tnDokTyyp alias for 	$6; 
	tnNomId	  alias for 	$7;
	lnArvSumma numeric (12,4);
	lnTasuSumma numeric (12,4);
	lnJaak numeric (12,4);
begin
	lnArvSumma := 0;
	lnTasuSumma := 0;
	lnJaak := 0;
-- KUSTUTA VANA TASU INF
	delete FROM Arvtasu 
		WHERE Arvtasu.sorderid = tnDokId 
		and arvId = tnArvId ;
-- uus kiri		
	insert into arvtasu (rekvId, arvId, kpv, summa, sorderId, pankKassa, nomId) values
	(tnRekvId, tnArvId, tdKpv, tnSumma, tnDokId, tnDokTyyp, tnNomId);

	SELECT summa into lnArvSumma FROM arv WHERE id = tnArvId ;
	SELECT sum(summa) into lnTasuSumma FROM arvtasu WHERE arvId = tnArvId;
	lnJaak := lnArvSumma - lnTasuSumma;
	UPDATE arv SET tasud = tdkpv,
		jaak = lnJaak WHERE id = tnArvId;		

	return lnJaak;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
