Parameter cWhere
SELECT comHooIsikud.*, kov.nimetus as omavalitsus ;
	from comHooIsikud INNER JOIN comasutusremote kov ON kov.id = comHooIsikud.omavalitsusId ;
	ORDER BY kov.nimetus, comHooIsikud.hooldekodu, comHooIsikud.nimi;
	INTO CURSOR isikutenimekiri
SELECT isikutenimekiri
