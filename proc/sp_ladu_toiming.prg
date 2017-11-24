Parameters tnId

*Procedure sp_trig_i_arv1
* check for versioon
If gVersia <> 'VFP'
	Return .T.
Endif
If Empty(tnId)
	Return .T.
Endif

Select arv.operid,arv.liik, arv.rekvid, arv.kpv, arv1.* ;
	from arv INNER Join arv1 On arv.Id = arv1.parentid ;
	WHERE arv.Id = tnId AND EMPTY(arv1.maha) Into Cursor tmpArv

If Used('arv')
	Use In arv
Endif

If Used('arv1')
	Use In arv1
Endif
	If tmpArv.operid > 0  And tmpArv.liik = 1
&&	/* vara sisetulik*/
		DELETE FROM ladu_jaak WHERE dokItemid in (select id FROM tmpArv)

		Insert Into ladu_jaak (rekvid, dokItemid, nomId, Userid, kpv, hind, kogus, maha, jaak);
			SELECT tmpArv.rekvid, tmpArv.Id, tmpArv.nomId,tmpArv.Userid, tmpArv.kpv, tmpArv.hind, tmpArv.kogus, 0, tmpArv.kogus FROM tmpArv
	Endif
	If tmpArv.operid > 0  And tmpArv.liik = 0
		Select Count(Id) As kogus From ladu_grupp Where nomId = tmpArv.nomId Into Cursor tmpItem
		If !Used('tmpItem') Or tmpItem.kogus = 0
&& teenus

			Return .T.
		Endif

		If Used('tmpItem')
			Use In tmpItem
		Endif

		If Used('ladu_grupp')
			Use In ladu_grupp
		Endif

&&	/*vara valjaminek */

SELECT tmpArv
scan

		Select liik From ladu_config Where ladu_config.rekvid = tmpArv.rekvid Into Cursor qryLifoFifo
		lnLifoFifo = Iif (Empty (qryLifoFifo.liik),1,qryLifoFifo.liik)
		Use In qryLifoFifo
		If lnLifoFifo = 1
&&		/* Lifo */
			Select   Id, jaak, maha, kpv, dokItemid  ;
				from ladu_jaak ;
				where rekvid = tmpArv.rekvid;
				and jaak > 0;
				and nomId = tmpArv.nomId;
				and Not Deleted();
				order By kpv;
				into Cursor cur_ladujaak
		Else
&&		/* FiFo*/
			Select   Id, jaak, maha, kpv, dokItemid   ;
				from ladu_jaak;
				where rekvid = arv.rekvid;
				and jaak > 0;
				and nomId = arv.nomId;
				and Not Deleted();
				order By kpv Desc;
				into Cursor cur_ladujaak

		Endif
		lnKogus = arv1.kogus
		Selec cur_ladujaak
		SCAN
			lnMaha = 0
			If cur_ladujaak.jaak >= arv1.kogus And arv1.kogus > 0
				lnMaha = cur_ladujaak.maha + lnKogus
				Update ladu_jaak Set jaak = cur_ladujaak.jaak - lnKogus, ;
					maha = lnMaha Where Id = cur_ladujaak.Id
				lnKogus = 0
*!*					If (cur_ladujaak.maha ) > cur_ladujaak.jaak
*!*						Rollback
*!*						Messagebox(' ei saa mahakandma nii palja kaupa','Kontrol')
*!*						Exit
*!*					Endif
*!*					Exit
			Endif
			If cur_ladujaak.jaak < lnKogus And lnKogus >= 0
				lnMaha = cur_ladujaak.maha + (lnKogus - cur_ladujaak.jaak)
				Update ladu_jaak Set jaak = 0, maha = lnmaha  Where Id = cur_ladujaak.Id
				lnKogus = lnKogus - cur_ladujaak.jaak
			ENDIF
			UPDATE arv1 SET maha = lnMaha WHERE id = cur_ladujaak.dokitemid
			Delete From ladu_jaak Where jaak = 0
		Endscan
		Use In cur_ladujaak
*!*			If lnKogus > 0
*!*				Rollback
*!*				glError = .T.
*!*				Messagebox ('Ladus ei ole kaupa','Kontrol')
*!*			Else
*!*	&&			do sp_recalc_ladujaak with arv.rekvid,arv1.NomId,0
*!*			Endif
	Endscan

Endif
Endproc
