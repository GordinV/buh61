Parameter cWhere
SELECT curHooTehingud.*, isik.nimetus as isik from curHooTehingud INNER JOIN comAsutusRemote Isik ON isik.id = curHooTehingud.isikId ;
	ORDER BY kpv, allikas, tyyp INTO CURSOR tehingud

SELECT tehingud
