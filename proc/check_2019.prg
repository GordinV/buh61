
IF !FILE('key_.dbf')
	return
ENDIF


If !Used('key_')
	Use key_ In 0
	
Endif

SELECT comrekvRemote
LOCATE FOR id = gRekv

IF !FOUND() OR gRekv = 1
	return
ENDIF


IF !USED('key')
	USE key IN 0
ENDIF

CREATE CURSOR tmp_rekv (nimetus m) 

SELECT tmp_rekv

APPEND BLANK
replace nimetus WITH LTRIM(RTRIM(comrekvRemote.nimetus)) + ' 2019' IN tmp_rekv

SELECT tmp_rekv
=secure('ON')

SELECT tmp_rekv
GO bottom

l_omanik = MLINE(TMP_REKV.nimetus,1)

l_uhenda = 'DRIVER=PostgreSQL;DATABASE=narvalv2019;server=dbarch.narva.ee;PORT=5432;MaxVarcharSize=254;'
	
Insert Into key (Id, tyyp, algus, lopp, uhenda, versia, omAnik, Connect, vfp);
	values (key_.Id, key_.tyyp, key_.algus, key_.lopp, l_uhenda, key_.versia, l_omanik, key_.Connect, key_.vfp)

Use In key_
Use In key
