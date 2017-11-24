select * from nomenklatuur where kood = 'Hotel' order by rekvid

select * from klassiflib where nomid in (6981, 23838)

select library from library where rekvid = 66 group by library

select sp_salvesta_library(568282, 119, '9027','0922064 Eestimaa on meie kodumaa. Eesti Lõimumiskava 2008-2013','PROJ                ','Narva Humanitaargümnaasium. Leping nr. KNPL09114. Toetav summa on 99 070 krooni. Aruande esitamise tähtaeg on 05.11.2009. Projekti lõppemise tähtaeg on 15.10.2009. Toetuse andja on Integratsiooni Sihtasutus.',         0,         0,         0,         0,         0)


select sp_salvesta_library(570703, 119, '9054','0810671 Maleturniir Läänemere Maletähed','PROJ                ','Narva Laste Loomemaja. Leping nr. 8.14/896. Toetav summa on 27 000 krooni. Väljamakse kuupäev on 13.07.2009. Aruande esitamise tähtaeg on 30.12.2009. Toetuse andja on Kultuuriministeerium.',         0,         0,         0,         0,         0)
select * from library where id = 568282
