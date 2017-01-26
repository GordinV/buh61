select repositvfp
scan
	if atc('CUR',REPOSITVFP.PROP10) > 0
		MODI MEMO REPOSITVFP.PROP10 SAVE
	ENDIF
endscan