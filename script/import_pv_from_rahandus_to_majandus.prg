Local lError
Clear All


lnSumma = 0
lnrec = 0
lnrekvId = 130
lnrekvIdvana = 3
lnError = 0

*gnHandle = SQLConnect('koopia','vlad')

gnHandle = SQLConnect('narvalvpg','vlad')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

* koosta pv nimikiri
=koosta_pv_nimikiri()


* paring
SET STEP ON 

Select tmp_pv
SCAN
	WAIT WINDOW 'Salvestam PV kaart:' + tmp_pv.inv_kood nowait

TEXT TO lcString TEXTMERGE noshow
	select * from curpohivara
		where rekvid = <<lnRekvIdvana>>
		and LTRIM(RTRIM(UPPER(kood))) = '<<ALLTRIM(UPPER(tmp_pv.inv_kood))>>'
ENDTEXT

	lnError = SQLEXEC(gnHandle,lcString,'qryPV' )
	If lnError < 0
		Set Step On
		Exit
	Endif


* kas jube on olemas

TEXT TO lcString TEXTMERGE noshow
		SELECT id FROM curpohivara WHERE rekvid = <<lnrekvId>> and LTRIM(RTRIM(UPPER(kood))) = '<<ALLTRIM(UPPER(tmp_pv.inv_kood))>>'
ENDTEXT
	lnError = SQLEXEC(gnHandle,lcString,'qryPVId' )
	If lnError < 0
		Set Step On
		Exit
	Endif
	If Reccount('qryPVId') = 0
* puudub, lisame

* arvestame kulum
TEXT TO lcString TEXTMERGE NOSHOW
			select sum(summa) as kulum from pv_oper where parentid = <<qryPV.id>> and liik = 2
ENDTEXT
		lnError = SQLEXEC(gnHandle,lcString,'qryPVKulum' )
		If lnError < 0
			Set Step On
			Exit
		Endif


		l_kulum = Iif(Isnull(qryPVKulum.kulum),0,qryPVKulum.kulum) + qryPV.algKulum
TEXT TO lcString TEXTMERGE noshow

			SELECT sp_salvesta_pv_kaart(0, 3556, '2019-06-01',
				<<qryPV.kulum>>,
				<<l_kulum>>,
				<<tmp_pv.groupId_uus>>,
				'<<qryPV.konto>>',
				 1,
				 '<<qryPV.selgitus>>',
				 '<<qryPV.rentnik>>',
				 '<<qryPV.kood>>',
				 '<<qryPV.nimetus>>',
				 <<lnrekvId>>) as id
ENDTEXT

		lnError = SQLEXEC(gnHandle,lcString,'qryPvId' )
		If lnError < 0 Or !Used('qryPvId') Or Empty(qryPvId.Id)
			Set Step On
			Exit
		Endif

* paigaldus

* loeme originaal

TEXT TO lcString TEXTMERGE noshow

		SELECT * from pv_oper WHERE parentid = <<qryPV.id>> and liik = 1 ORDER BY id DESC limit 1

ENDTEXT

		lnError = SQLEXEC(gnHandle,lcString,'qryPvPaig' )
		If lnError < 0 Or !Used('qryPvPaig')
			Set Step On
			Exit
		Endif


TEXT TO lcString TEXTMERGE noshow

		SELECT sp_salvesta_pv_oper(0,
			<<qryPvId.id>>,
			26255,
			0, 1, '2019-06-01'::date,
			<<qryPV.parhind>>,
			'<<IIF(ISNULL(qryPvPaig.muud),'',qryPvPaig.muud)>>',
			'<<qryPvPaig.kood1>>',
			'<<qryPvPaig.kood2>>',
			'<<qryPvPaig.kood3>>',
			'<<qryPvPaig.kood4>>',
			'<<qryPvPaig.kood5>>',
			'<<qryPvPaig.konto>>',
			'<<qryPvPaig.tp>>',
			<<qryPvPaig.asutusid>>,
			'',
			'','EUR' , 1)

ENDTEXT

* salvestame

	lnError = SQLEXEC(gnHandle,lcString)
		If lnError < 0 
			Set Step On
			Exit
		ENDIF
		
		WAIT WINDOW 'Salvestam PV kaart:' + tmp_pv.inv_kood + '...tehtud' nowait
	

	Endif

Endscan

*(inv_kood c(20), gruppId_vana int, groupId_uus int)



Endfunc


Function koosta_pv_nimikiri
	Create Cursor tmp_pv (inv_kood c(20), gruppId_vana Int, groupId_uus Int)
	Insert Into tmp_pv (inv_kood, gruppId_vana, groupId_uus) VALUES ('1113/0001x',3894,674242)
	Insert Into tmp_pv (inv_kood, gruppId_vana, groupId_uus) VALUES ('1113/0002',3894,674242)
	Insert Into tmp_pv (inv_kood, gruppId_vana, groupId_uus) VALUES ('155000/0001',3893,679662)
	Insert Into tmp_pv (inv_kood, gruppId_vana, groupId_uus) VALUES ('155000/0002',3893,679662)
	Insert Into tmp_pv (inv_kood, gruppId_vana, groupId_uus) VALUES ('155400/0014',3895,674249)
	Insert Into tmp_pv (inv_kood, gruppId_vana, groupId_uus) VALUES ('155600/0003',3897,674314)
	Insert Into tmp_pv (inv_kood, gruppId_vana, groupId_uus) VALUES ('1128/0003',3897,674249)
Endfunc



Function transdigit

	Lparameters tcString
	lnQuota = At(',',tcString)
	lcKroon = Left(tcString,lnQuota-1)
	lcCent = Right(tcString,2)
	If At(Space(1),lcKroon) > 0
* on probel
		lcKroon = Stuff(lcKroon,At(Space(1),lcKroon),1,'')
	Endif
	Return lcKroon+'.'+lcCent
Endfunc
