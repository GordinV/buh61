Parameter cWhere
Local lnDeebet, lnKreedit, lckonto
With odb
	Create Cursor varadearuanne_report1 (Id Int,parentrea c(20), rea c(20), kood c(120), nimetus c(254), konto c(20),GRUPP c(254),;
		soetalg Y,soetperiod Y, tasuta Y, muuk Y, soetmaks Y, soetkpv d, parandus Y, kulumkokku Y, jaak Y, vastisik c(120))
	Index On parentrea+rea Tag rea
	Set Order To rea
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('1', '1','10','Immateriaalne pohivara')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('1','1.1','101','Asutamisväljaminekud')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('1','1.2','102','Arenguväljaminekud')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('1','1.3','103,104,107','Ostetud patendid, litsensid ')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('1','1.4','109','Muu immateriaalne põhivara')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2','11','Materiaalne põhivara')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.1','110','Maa')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.2','111','Maarajatised ja hooned')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.2.1','1111','rajatised')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.2.2','1112','hooned (v.a. elumajad)')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.2.3','1113','hoonete osad (v.a. elumajade osad)')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.2.4','1114','elumajad')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.2.5','1115','elumajade osad')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.3','112','Masinad ja seadmed')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.4','113','Inventar')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.5','114','Ehitusinventar')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.6','115','Sõidukid ja transpordivahendid')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.7','116','Kunsti- ja muud mitteamortiseeruvad väärtused')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.8','117','Muu materiaalne põhivara')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('2','2.9','118','Lõpetamata ehitus ja uusehitus')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('3','3','12','Finantspõhivara ')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('3','3.1','121','Aktsiad ja osad ')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('3','3.2','122','Võlakirjad ja muud väärtpaberid')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('3','3.3','123','Pikaajalised nõuded')
	Insert Into varadearuanne_report1 (parentrea, rea, konto, nimetus) Values ('3','3.3','124','Pikaajalised nõuded asutustele')



	tnTunnus = 1
	tcKood = '%%'
	tcNimetus = '%%'
	tcKonto = '%'
	tcVastIsik = '%%'
	tcGrupp =  '%%'
	tnSoetmaks1 = -99999999999
	tnSoetmaks2 = 9999999999
	tdSoetkpv1 = Date(1901,1,1)
	tdSoetkpv2 = fltrAruanne.kpv2
	.Use ('curPohivara','qryPohivara')
	tnTunnus = 0
	* ñïèñàíûå
	.Use ('curPohivara','qryPohivara0')
	SELECT qryPohivara
	APPEND FROM DBF('qryPohivara0')
	USE IN qryPohivara0
	
	
	tnGruppId1 = 0
	tnGruppId2 = 99999999999
	tdKpv1 = fltrAruanne.kpv1
	tdKpv2 = fltrAruanne.kpv2

	Select varadearuanne_report1
	Scan For varadearuanne_report1.rea <> '1.3'
		Wait Window 'Arvestan ..'+varadearuanne_report1.rea Nowait
&& ñ÷èòàåì ñò-òü ïğèîáğåòåíèÿ
		lcKonto = Alltrim(varadearuanne_report1.konto)
		lnWidth = Len(ALLTRIM(lcKonto))
		Select qryPohivara
		Sum soetmaks To lnSoetalg For soetkpv < fltrAruanne.kpv1 And;
			(Isnull(mahakantud) Or mahakantud = DATE(1900,1,1) or ;
			 mahakantud > fltrAruanne.kpv1) And Left(Alltrim(qryPohivara.konto),lnWidth) = lcKonto
		Sum soetmaks To lnSoetPeriod For soetkpv >= fltrAruanne.kpv1 And soetkpv <= fltrAruanne.kpv2 And;
		 (Isnull(mahakantud) Or mahakantud = DATE(1900,1,1) OR EMPTY(mahakantud) Or mahakantud > fltrAruanne.kpv1 ) ;
		 And Left(Alltrim(qryPohivara.konto),lnWidth) = lcKonto
&& ñ÷èòàåì ñò-òü ñïèñàíûõ ÎÑ
		Sum soetmaks To lnMuuk For !Isnull(mahakantud) And mahakantud >= fltrAruanne.kpv1 ;
			And mahakantud <= fltrAruanne.kpv2  ;
			And Left(Alltrim(qryPohivara.konto),lnWidth) = lcKonto
&& ñ÷èòàåì ñò-òü áåñïëàòíî ïîëó÷åííûõ ÎÑ
		tcKonto = lcKonto+'%'
		.Use ('CURPAIGATUS')
		If Reccount('CURPAIGATUS') > 0
			Select Sum (soetmaks) As Summa From qryPohivara Where Id In (Select Id From curPaigatus Where kulumkokku = 0) Into Cursor qryTasuta
			If Reccount('qryTasuta') > 0
				lnTasuta = qryTasuta.Summa
				lnSoetPeriod = lnSoetPeriod - lnTasuta
			Else
				lnTasuta = 0
			Endif
		Else
			lnTasuta = 0
		Endif
		Use In curPaigatus

&& ñ÷èòàåì ñò-òü èçìåíåíèé
		.Use ('curParandus')
		If Reccount('curParandus') > 0
			Select curParandus
			Sum kulumkokku To lnParandus
		Else
			lnParandus = 0
		Endif
		Use In curParandus
&& ñ÷èòàåì îñòàòî÷íóş ñò-òü
		.Use ('curKulum')
		If Reccount('curKulum') > 0
			Select curKulum
			Sum kulumkokku To lnKulum
		Else
			lnKulum = 0
		Endif
		Select Sum (algkulum) As Summa From qryPohivara ;
			Where konto like tcKonto  Into Cursor qryAlgKulum
		If Reccount('qryAlgKulum') > 0
			lnKulum = lnKulum + qryAlgKulum.Summa
		Endif
		Use In qryAlgKulum
*		lnSoetmaks = lnSoetalg + lnSoetPeriod + lnTasuta + lnParandus - lnMuuk
		lnSoetmaks = lnSoetalg + lnSoetPeriod + lnTasuta + lnParandus
		Replace  soetalg With  lnSoetalg,;
			soetperiod With lnSoetPeriod, ;
			tasuta With lnTasuta,;
			muuk With lnMuuk,;
			parandus With lnParandus,;
			soetmaks With lnSoetmaks,;
			jaak With lnSoetmaks - lnKulum In varadearuanne_report1
	Endscan

	Scan For varadearuanne_report1.rea = '1.3'
		Wait Window 'Arvestan ..'+varadearuanne_report1.rea Nowait
&& ñ÷èòàåì ñò-òü ïğèîáğåòåíèÿ

		lcKonto1 = '103'
		lcKonto2 = '104'
		lcKonto3 = '107'
		Select qryPohivara
		Sum soetmaks To lnSoetalg For soetkpv < fltrAruanne.kpv1 And (Isnull(mahakantud) Or mahakantud > fltrAruanne.kpv1) And (Left(Alltrim(konto),lnWidth) = lcKonto1 Or Left(Alltrim(konto),lnWidth) = lcKonto2 Or Left(Alltrim(konto),lnWidth) = lcKonto3)
		Sum soetmaks To lnSoetPeriod For soetkpv >= fltrAruanne.kpv1 And soetkpv <= fltrAruanne.kpv2 And (Isnull(mahakantud) Or mahakantud > fltrAruanne.kpv1 ) And (Left(Alltrim(konto),lnWidth) = lcKonto1 Or Left(Alltrim(konto),lnWidth) = lcKonto2 Or Left(Alltrim(konto),lnWidth) = lcKonto3)
		Sum soetmaks To lnMuuk For soetkpv >= fltrAruanne.kpv1 And soetkpv <= fltrAruanne.kpv2 And (!Isnull(mahakantud) And mahakantud >= fltrAruanne.kpv1 And mahakantud <= fltrAruanne.kpv2  ) And (Left(Alltrim(konto),lnWidth) = lcKonto1 Or Left(Alltrim(konto),lnWidth) = lcKonto2 Or Left(Alltrim(konto),lnWidth) = lcKonto3)
&& ñ÷èòàåì ñò-òü áåñïëàòíî ïîëó÷åííûõ ÎÑ
		tcKonto = lcKonto1+'%'
		.Use ('CURPAIGATUS')
		tcKonto = lcKonto2+'%'
		.Use ('CURPAIGATUS','CURPAIGATUS2')
		tcKonto = lcKonto3+'%'
		.Use ('CURPAIGATUS','CURPAIGATUS3')
		Select curPaigatus
		Append From Dbf('curPaigatus2')
		Append From Dbf('curPaigatus3')
		Use In curPaigatus2
		Use In curPaigatus3
		If Reccount('CURPAIGATUS') > 0
			Select Sum (soetmaks) As Summa From qryPohivara Where Id In (Select Id From curPaigatus Where kulumkokku = 0) Into Cursor qryTasuta
			If Reccount('qryTasuta') > 0
				lnTasuta = qryTasuta.Summa
				lnSoetPeriod = lnSoetPeriod - lnTasuta
			Else
				lnTasuta = 0
			Endif
		Else
				lnTasuta = 0
		Endif
		Use In curPaigatus

&& ñ÷èòàåì ñò-òü èçìåíåíèé
		tcKonto = lcKonto1+'%'
		.Use ('curParandus')
		tcKonto = lcKonto2+'%'
		.Use ('curParandus', 'curParandus2')
		tcKonto = lcKonto3+'%'
		.Use ('curParandus', 'curParandus3')
		Select curParandus
		Append From Dbf('curParandus2')
		Append From Dbf('curParandus3')
		Use In curParandus2
		Use In curParandus3

		If Reccount('curParandus') > 0
			Select curParandus
			Sum kulumkokku To lnParandus
		Else
			lnParandus = 0
		Endif
		Use In curParandus
&& ñ÷èòàåì îñòàòî÷íóş ñò-òü
		tcKonto = lcKonto1+'%'
		.Use ('curKulum')
		tcKonto = lcKonto2+'%'
		.Use ('curKulum','curKulum2')
		tcKonto = lcKonto3+'%'
		.Use ('curKulum','curKulum3')
		Select curKulum
		Append From Dbf('curKulum2')
		Append From Dbf('curKulum3')
		Use In curKulum2
		Use In curKulum3


		If Reccount('curKulum') > 0
			Select curKulum
			Sum kulumkokku To lnKulum
		Else
			lnKulum = 0
		Endif
		Select Sum (algkulum) As Summa From qryPohivara ;
			Where konto like ALLTRIM(lcKonto1)+'%' Or ;
			konto like ALLTRIM(lcKonto2)+'%' Or;
			konto like ALLTRIM(lcKonto3)+'%' Into Cursor qryAlgKulum
		If Reccount('qryAlgKulum') > 0
			lnKulum = lnKulum + qryAlgKulum.Summa
		Endif
		Use In qryAlgKulum
		lnSoetmaks = lnSoetalg + lnSoetPeriod + lnTasuta + lnParandus - lnMuuk
		Replace  soetalg With  lnSoetalg,;
			soetperiod With lnSoetPeriod, ;
			tasuta With lnTasuta,;
			muuk With lnMuuk,;
			parandus With lnParandus,;
			soetmaks With lnSoetmaks,;
			jaak With lnSoetmaks - lnKulum In varadearuanne_report1
	Endscan
Endwith


If Used('qryPohivara')
	Use In qryPohivara
Endif
Select varadearuanne_report1
