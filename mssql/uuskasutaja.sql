insert into rekv (parentid, nimetus, kbmkood, aadress, haldus, tel, faks, email, juht, raama, muud, recalc)
values (2, 'Linna Arenduse ja Okonomika Amet',space(1),'Narva Petri valjak 5',space(1),space(1),space(1),space(1),space(1),'Natalja Kozlova','smtp.narva.ee',1 )


select top 1 * from userid
insert into userid (rekvid, kasutaja, ametnik, parool, kasutaja_, peakasutaja_, admin)
values (28, 'vladislav','Vladislav Gordin',space(1), 0,1,1)

select * from rekv where id = 28

insert into userid (rekvid, kasutaja, ametnik, parool, kasutaja_, peakasutaja_, admin)
select 28,kasutaja, ametnik, parool, kasutaja_, peakasutaja_, admin from userid where kasutaja_ = 0 and rekvid = 8



insert into library (rekvid,kood, nimetus, library)
select 28,kood, nimetus, library from library ettev where ettev.library <> 'DOK' and ettev.rekvid = 8

insert into kontoinf (rekvid,parentid,type, formula, aasta, algsaldo, liik, pohikonto)
select 28,parentid, type, formula, aasta, 0, liik, pohikonto from kontoinf ettev where ettev.rekvid = 8

insert into palk_config (rekvid, minpalk, tulubaas, round, jaak)
select 28, minpalk, tulubaas, round, jaak from palk_config where rekvid = 8

insert into holidays (rekvid, kuu, paev, nimetus, muud)
select 28, kuu, paev, nimetus, muud from holidays where rekvid = 8

delete from library where library = 'AMET' AND REKVID = 28






update rekv set nimetus = 'Linna Arenduse ja Okonoomika Amet' where id = 28
                
                                                                                                                                                                                                              