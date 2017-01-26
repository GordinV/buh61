				SELECT journal.id, journal.rekvid, journal1.summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= date(2013,06,30) and year(journal.kpv) = 2013 and not empty (journal1.kood5) 
				and journal1.kood5  '5500' 
			and journal.rekvid = 28 


				SELECT journal.id, journal.rekvid, journal1.summa  AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= date(2013,06,30) and year(journal.kpv) = 2013 and not empty (journal1.kood5) 
				and journal1.kood5 like '5500%'
				and journal.rekvid = 28 
				and journal.id = 5185440


		select kassakulu.kood,ifnull(library.nimetus,space(254)) as nimetus, -1* (summa) as summa
				from (
				SELECT journal.id, journal.rekvid, journal1.summa  AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= date(2013,06,30) and year(journal.kpv) = 2013 and not empty (journal1.kood5) 
				and journal1.kood5 like '5500%'
				) kassakulu
			inner join library on (library.kood = kassakulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 2)
			where kassakulu.rekvid = 28 




		select kassakulu.id, kassakulu.kood,ifnull(library.nimetus,space(254)) as nimetus, -1* (summa) as summa
				from (
				SELECT journal.id, journal.rekvid, (journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= date(2013,06,30) and year(journal.kpv) = 2013 and not empty (journal1.kood5) 
				and journal1.kood5 like '5500%' 
				) kassakulu
			inner join library on (library.kood = kassakulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 2)
			where (kassakulu.rekvid = 28 ) and kassakulu.id = 5185440
