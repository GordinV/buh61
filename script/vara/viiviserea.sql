select * from arv where number = 'V82'

select * from arv1 where parentid = 134306

update arv1 set muud = 'Arve nr.:1216r10 Päevad: 16 viivis:'  where id = 220019

Arve nr.:853r11               Võlg:1281.61 Päevad: 1 viivis: 0.50%

			select count(arv.jaak * ifnull(dokvaluuta1.kuurs,1)) 
					from arv inner join arv1 on arv.id = arv1.parentid 
					left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
					where rekvid = 6 and arv1.muud like '%Arve nr.:'+ltrim(rtrim('1098r10'))+'%' and arv1.muud like '%viivis%'; 



SELECT * FROM ASUTUS where nimetus = 'TEADUS  JA  TARKUS KOOLITUSKESKUS  '

SELECT sp_calc_viivis(6, 33967, date(), 1)

					select arv1.muud::varchar  from arv1 inner join arv on arv.id = arv1.parentid 
						where arv.rekvid = 6 and arv.asutusId =33967 and  arv1.muud like '%Arve nr.:'+ltrim(rtrim('1098r10'))+'%' 
						and arv1.muud like '%viivis%' order by arv.id desc limit 1;
