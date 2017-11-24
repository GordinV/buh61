Parameter tcWhere
LOCAl lcString, lcStringTegelik, tdKpv1, tdKpv2
CREATE CURSOR tmpFilter (filter c(254))
APPEND blank
tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2

lnYear = YEAR(tdKpv1)
lnKuu1 = MONTH(tdKpv1)
lnKuu2 = MONTH(tdKpv2)
lcKood1 = ALLTRIM(fltrAruanne.kood1) + '%'
lcKood2 = ALLTRIM(fltrAruanne.kood2) + '%'
lcKood3 = ALLTRIM(fltrAruanne.kood3) + '%'
lcKood5 = ALLTRIM(fltrAruanne.kood5) + '%'
lcTunnus = ALLTRIM(fltrAruanne.tunnus) + '%'
lcProj = ALLTRIM(fltrAruanne.proj) + '%'
lcProjNimi = ''
IF !EMPTY(fltrAruanne.proj) then
	SELECT comProjRemote
	LOCATE FOR kood = fltrAruanne.proj
	IF FOUND() 
		lcProjNimi = ALLTRIM(comProjRemote.nimetus)
	ENDIF
	
ENDIF

lnTunnus = fltrAruanne.tunn
ldTapsusKpv = null
IF lnTunnus > 0 then
	ldTapsusKpv = fltrAruanne.kpv	
ENDIF

replace  tmpFilter.filter WITH 'Period:' + DTOC(fltrAruanne.kpv1) +'-'+DTOC(fltrAruanne.kpv2) +CHR(13)+;
	IIF(!EMPTY(fltrAruanne.kood1),' Tegevusalla:' + ALLTRIM(fltrAruanne.kood1) + '%' , '')+;
	IIF(!EMPTY(fltrAruanne.kood2),' Allikas:' + ALLTRIM(fltrAruanne.kood2) + '%','') +;
	IIF(!EMPTY(fltrAruanne.kood3),' Eelarve:' + ALLTRIM(fltrAruanne.kood3) + '%','') +;
	IIF(fltrAruanne.tunn = 1,' Täpsestatud, seisuga '+ DTOC(fltrAruanne.kpv),'') +CHR(13)+ ;	
	IIF(!EMPTY(fltrAruanne.proj),' Projekt:' + ALLTRIM(fltrAruanne.proj) + '% '+ lcProjNimi +CHR(13),'')+ ;
	IIF(!EMPTY(fltrAruanne.tunnus),' Tunnus:' + ALLTRIM(fltrAruanne.tunnus) + '%' ,'') IN tmpFilter
	
lnKond = IIF(fltrAruanne.kond = 1 , 3, 9)


Create Cursor eelarve_report (aasta Int , kuu Int, eelarve n(16,2) DEFAULT 0, taitmine n(16,2) DEFAULT 0, ;
		eelarveKond n(16,2) DEFAULT 0, taitmineKond n(16,2) DEFAULT 0,;
		korrkonto c(20), kood1 c(20), kood2 c(20), kood3 c(20), kood5 c(20), nimetus c(254) null, tunnus c(20) null, taitmineKokku n(16,2), eelarveKokku n(16,2))

TEXT TO lcString NOSHOW 

	select sum(eelarve) as eelarve, sum(taitmine) as taitmine,  kood2, kood5,
	 korrkonto, coalesce(l.nimetus, ' ')::varchar(254) as nimetus, tunnus from (
	select sum(coalesce(e.summa,0)) as eelarve, 0 as taitmine, e.kood2,  e.kood5,'' as korrkonto, coalesce(tunnus.kood,'') as tunnus
		from eelarve e
		LEFT JOIN library tunnus ON e.tunnusid = tunnus.id
		where aasta = ?lnYear::integer
		and ((kuu >= ?lnKuu1::integer and kuu <= ?lnKuu2::integer) or kuu = 0)
		and e.rekvid in ( (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, ?gRekv::integer) > ?lnKond or  e.rekvid = ?gRekv)) -- svod = 3, 9		
		and e.kood1 ilike ?lcKood1
		and e.kood2 ilike ?lcKood2
		and e.kood3 ilike ?lcKood3
		and e.kood5 ilike ?lcKood5	
		and (tunnus.kood ilike ?lcTunnus or tunnus.kood is null)
		and e.tunnus <= ?fltrAruanne.tunn	
		and (e.kpv <= ?fltrAruanne.kpv or e.kpv is null)
		and e.kood5 in (select kood from library where library = 'TULUDEALLIKAD' and tun5 = 2)
		group by  e.kood2,  e.kood5, coalesce(tunnus.kood,'')
	union 
	select 0 as eelarve, sum(j.summa) as taitmine, j.kood2, j.kood5,
	j.deebet as korrkonto, j.tunnus
	from curJournal as j
	where j.kpv >= ?tdKpv1
	and j.kpv <= ?tdKpv2
	and j.rekvid in ( (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, ?gRekv::integer) > ?lnKond or  j.rekvid = ?gRekv)) -- svod = 3, 9		
	and j.kood1 ilike ?lcKood1
	and j.kood2 ilike ?lcKood2
	and j.kood3 ilike ?lcKood3
	and j.kood5 ilike ?lcKood5	
	and j.tunnus ilike ?lcTunnus
	and j.proj ilike ?lcProj
	and j.deebet in -- tegelik kulud
		(select l.kood
			from library l
			inner join faktkulud ON ltrim(rtrim(l.kood::text)) ~~ ltrim(rtrim(faktkulud.kood::text))
			where library = 'KONTOD'
			)
	group by j.kood2, j.kood5, j.deebet, j.tunnus		
	) qry
	left outer join library l on l.kood = qry.korrkonto and l.library = 'KONTOD'					
	group by  kood2, kood5, korrkonto, tunnus, l.nimetus
	order by  tunnus, kood5, kood2,   korrkonto
ENDTEXT


lnError = SQLEXEC(gnhandle, lcString,'qryTmp')
If lnError < 0 Then
	Wait Window 'Viga' Nowait
	Do err
ELSE

		SELECT kood2, kood5, tunnus, sum(eelarve) as eelarveKond FROM qryTmp group BY kood2, kood5, tunnus INTO cursor qryEelarve 

	SELECT sum(taitmine) as taitmineKond, kood2, kood5, tunnus FROM qryTmp ;
		group BY kood2, kood5, tunnus ;
		INTO CURSOR qryTaitmine
		
	SELECT qryEelarve
	SUM eelarveKond TO lnSummaEelarve

	SELECT qryTaitmine
	SUM taitmineKond TO lnSummaTaitmine


	SELECT IIF(ISNULL(qryTmp.eelarve),0,qryTmp.eelarve) as eelarve, ;
		IIF(ISNULL(qryTmp.taitmine),0,qryTmp.taitmine) as taitmine, ;
		IIF(ISNULL(qryEelarve.eelarveKond),0,qryEelarve.eelarveKond) as eelarveKond , lnSummaEelarve as eelarveKokku,;
		 IIF(ISNULL(qryTaitmine.taitmineKond),0,qryTaitmine.taitmineKond) as taitmineKond ,lnSummaTaitmine as taitmineKokku,;
		 qryTmp.korrkonto, qryTmp.kood2,  qryTmp.kood5, qryTmp.nimetus, qryTmp.tunnus;
		FROM qryTmp ;
		LEFT OUTER JOIN qryEelarve ON qryEelarve.kood5 = qryTmp.kood5 AND qryEelarve.kood2 = qryTmp.kood2 AND qryEelarve.tunnus = qryTmp.tunnus;
		LEFT OUTER JOIN qryTaitmine ON qryTaitmine.kood5 = qryTmp.kood5 AND qryTaitmine.kood2 = qryTmp.kood2 AND qryTaitmine.tunnus = qryTmp.tunnus;
		ORDER BY qryTmp.kood5,  qryTmp.tunnus, qryTmp.kood2,   qryTmp.korrkonto;
		INTO CURSOR qryReport
		

	Select eelarve_report
	APPEND FROM DBF('qryReport') 
	USE IN qryTmp
	USE IN qryTaitmine
	USE IN qryEelarve
Endif

Select eelarve_report
