Parameter tcWhere
if !used('fltrPalkOper')
	return .f.
endif
CREATE CURSOR tootajad_report1 (KOOD C(20), nimetus c(254), amet c(254), osakondid int, osakond c(254))
INDEX ON LEFT(UPPER(osakond),40)+'-'+LEFT(UPPER(amet),40) TAG kood
SET ORDER TO kood
tcisik = ltrim(rtrim(fltrPalkOper.isik))+'%'
*oDb.use('comTootajad', 'Tootajad_report1')
select tootajad_report1

INSERT INTO tootajad_report1 (KOOD, nimetus , amet,  osakondid , osakond );
SELECT comTootajad.kood, comTootajad.nimetus, comTootajad.amet, comTootajad.osakondId,;
comOsakondpalkOper.nimetus FROM comTootajad inner join comOsakondpalkOper ;
on comTootajad.osakondid = comOsakondpalkOper.id