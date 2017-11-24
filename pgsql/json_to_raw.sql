-- Function: json_to_raw(text)

-- DROP FUNCTION json_to_raw(text);

CREATE OR REPLACE FUNCTION json_to_raw(IN in_json text, OUT fieldname text, OUT fieldvalue text, OUT fieldtype text, OUT fieldcoursor text, OUT fieldindex integer, OUT fieldcount integer)
  RETURNS SETOF record AS
$BODY$
DECLARE
	v_json record;
	v_json_sub record;
	v_json_raw record;
	c_json text;
	c_subjson text;
	l_coursor text;
	n_fields integer;
	c_value varchar;
	c_array text[];
	c_record text[];
	c_raw text[];
	c_raw_value text;
	c_subraw text;
	i_array integer;
	i_record integer;
	i_raw integer;
	n_start integer;
	n_finish integer;
	n_raw_start integer;
	n_raw_finish integer;
	n_raw_first_record integer;
	i_index integer;
BEGIN
c_json = in_json;
fieldcount = 1;
fieldindex = 0;
-- проверяем на кол-во записей в массиве
-- выкидываем \	
while position('\' in c_json) > 0
loop
	c_json = regexp_replace(regexp_replace(c_json, '\\', ''), '\\', '');
end loop;
--	raise notice '%',c_json;

-- вырезаем строки
i_record = 100;
i_raw = 100;
c_raw[i_raw] = '';
n_start = position('[{' in c_json);

n_raw_start = position('[{' in c_json);

while n_raw_start > 0
loop
	n_raw_start = position('[{' in c_json);
	n_raw_finish = position('}]' in c_json);
	n_raw_first_record = i_record;
--	n_start = n_raw_start;
	while n_start > 0
	loop
		n_finish = position('}' in c_json);
		if (n_finish >= n_raw_finish  or ( n_finish - n_start < 3)) and n_raw_first_record <> i_record then
			--конец строки
			n_finish = 0;
		end if;
		if n_finish = 0 then
			n_start = 0;
		end if;
		raise notice 'n_raw_start %,n_raw_finish %,  n_start %, n_finish %, i_raw %, c_raw[i_raw] %, c_json %', n_raw_start, n_raw_finish, n_start, n_finish, i_raw,  c_raw[i_raw], c_json;
		if n_start > 0 then
			-- есть еще записи в строке
			-- сохраняем массив в переменной
			c_record[i_record] = substring(c_json from n_start+1 for n_finish - n_start);
			-- меняем n_start на положение после записи
			-- вырезаем массив из строки
			if position('\' in c_record[i_record]) > 0 then
				c_record[i_record] = regexp_replace(regexp_replace(c_record[i_record], '\\', ''), '\\', '');
			end if;
	
			c_json = overlay(c_json placing 'RECORD' || i_record::text from n_start+1 for n_finish - n_start);
			-- формируем строку 
			if i_record > 0 then
				c_raw[i_raw] =  c_raw[i_raw] || ',';
			end if;

			c_raw[i_raw] = c_raw[i_raw] || 'RECORD' || i_record::text;

			i_record = i_record + 1;
			n_start = n_start + 10; -- (увеличиваем на длину RECORD(I)
		end if;
	end loop;
	if (i_record-100) > 0 then
		-- убираем квадратные скобки
		c_json = overlay(c_json placing '' from position('[RECORD' || n_raw_first_record::text in c_json) for 1);

		c_value = 'RECORD' || (i_record-1)::text || ']';
		c_json = overlay(c_json placing '' from position(c_value in c_json)+9 for 1);
		fieldcount = (i_record-100);
		-- замещаем записи строкой
		n_start = position('RECORD' in c_json);
		c_json = overlay(c_json placing 'RAW' || i_raw::text from n_start for length(c_raw[i_raw])-1);
	end if;
	n_raw_start = coalesce(position('[{' in c_json),0);
	n_start = n_raw_start;
	raise notice 'Следующая строка n_raw_start %, c_json %', n_raw_start, c_json;
	i_raw = i_raw + 1;
	c_raw[i_raw] = '';
end loop;

i_array = 100;
--вырезаем массивы
while position('[' in c_json) > 0
loop
	-- "tags":[],
	-- сохраняем массив в переменной
	c_array[i_array] = substring(c_json from position('[' in c_json) for (position(']' in c_json) - position('[' in c_json) )+1);

	-- вырезаем массив из строки
	c_json = overlay(c_json placing 'ARRAY' || i_array::text from position('[' in c_json) for (position(']' in c_json) - position('[' in c_json))+1);
	i_array = i_array + 1;
end loop;
raise notice 'c_json %', c_json;

--n_start = length(in_json);
n_start = length(c_json);
for v_json in
	select  unnest( string_to_array(substring(c_json from 2 for n_start+2),',')) as rec 
loop

-- читаем json
	fieldname = trim(both '"' from ltrim(lpad(v_json.rec,position(':' in  v_json.rec)-1)));
	if position('{' in fieldname) > 0 then
		-- чистим последующую строку
		fieldname = trim(both '{' from fieldname);		
	end if;
	if position('"' in fieldname) > 0 then
		fieldname = trim(both '"' from fieldname);
	end if;	
	fieldvalue = trim(both '"' from ltrim(substring(v_json.rec from position(':' in  v_json.rec)+1 for 1000)));
	fieldtype = 'C';
	if position('"' in substring(v_json.rec from position(':' in  v_json.rec)+1 for 100)) = 0 and fieldvalue <> 'null' then
		fieldtype = 'N';
	end if;

	c_value = fieldvalue::varchar;
		-- выкидываем \	
	while position('\' in c_value) > 0
	loop
		c_value = regexp_replace(regexp_replace(c_value, '\\', ''), '\\', '');
	end loop;
	if fieldvalue like 'RAW%' then
		c_raw_value = '';
		-- вытаскиваем строку
		i_raw = substring(fieldvalue from 4 for 3)::integer; 
		c_subraw =  '{' || c_raw[i_raw] || '}';
		l_coursor = fieldname;
		i_index = 0;
		for v_json_raw in 
			select  * from json_to_raw(c_subraw) 
		loop
			if v_json_raw.fieldvalue like 'RECORD%' then 
				i_record = substring(v_json_raw.fieldvalue from 7 for 3)::integer; 
				c_subjson = trim('[' from (trim( ']' from c_record[i_record] )));
				if fieldname = '' and length(l_coursor) > 0 then
					fieldname = l_coursor;
				end if;
				for v_json_sub in
					select  * from json_to_raw(c_subjson) 
				loop
					return query select v_json_sub.fieldname::text,v_json_sub.fieldvalue, v_json_sub.fieldtype, l_coursor as fieldcoursor, i_index as fieldindex, fieldcount;
				end loop;
				fieldvalue = c_record[i_record];
				fieldtype = 'C';
				fieldindex = (i_record-100);
				if (i_record-100) > 0 then
					c_raw_value = c_raw_value || ',';
				end if;
				c_raw_value = c_raw_value || c_subjson;
			end if; -- record
			i_index = i_index +1;
		end loop;  --v_json_raw
	end if; --raw
		-- обрабатываем массив
	fieldindex = (i_raw-100);	
	if fieldvalue like 'ARRAY%' then
		i_array = substring(fieldvalue from 6 for 3)::integer;
		fieldvalue = c_array[i_array];
		fieldtype = 'A';
--		fieldindex = i_array;
	end if;
	if position('"}' in fieldvalue) > 0 then
		fieldvalue = overlay(fieldvalue placing '' from position('"}' in fieldvalue) for 2);
	end if;
	if position('}' in fieldvalue) > 0 then
		fieldvalue = overlay(fieldvalue placing '' from position('}' in fieldvalue) for 1);
	end if;
	if coalesce(c_raw_value,'null') <> 'null' then
		-- замещаем значение строки
		fieldvalue = c_raw_value;
		c_raw_value = null;
	end if;
	
	return  next;	
end loop;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

COMMENT ON FUNCTION json_to_raw(text) IS 'возвращает поля и их значения из формата json в виде таблицы ';


--select * from json_to_raw('{"field1":272799, "field2":[{"fill11":"val111"}], "field3":[{"fill00":"val0"},{"fill01":"val1"},{"fill02":"val2"}], "field4":[{"fill100":"val10"},{"fill101":"val11"},{"fill1012":[1,2,3,4]}]}')

select * from json_to_raw('{"doc_id":272799,"tags":[],"tmcs":[{"id":0}],"payments":[{"card_deals_calc_id":42,"tmc_id":null}]}')

--select * from json_to_raw('{"doc_id":272799,"module":"crm","status_id":1,"annotation":null,"doc_type_id":78,"controlled_by":null,"registered_by":9345,"register_date":"15.01.2014 00:00","create_date":"24.01.2014 00:00","tags":[],"manager_id":9383,"buyer_id":153171,"buyer_contact_name":null,"buyer_phone":null,"buyer_email":null,"buyer_note":null,"deal_spec":null,"store_shipping":291,"plan_date_shipping":"2014-01-21","payer_id":153170,"payer_note":null,"consignee_id":153167,"consignee_note":null,"main_calc":1,"bproject_id":100481,"bobject_id":100491,"tmcs":[{"id":0,"version":1,"seq_num":1,"nomenclaturen_id":104218,"nomenclaturen_name":"МАЗ Мусоровоз МКЗ-3402","amount":1,"measure":280,"supplier_id":153166,"supplier_doc":null,"transport_company_id":null,"transport_company_doc":null,"discount":110,"pricelist_item_id":4,"unit_price":120,"shipping_price":0,"unit_cost":0,"shipping_cost":0,"tax_rate":25,"tax_is_rate":25}],"payments":[{"card_deals_calc_id":42,"version":1,"budget_item_id":100277,"operation_type_id":654,"pay_operation_type_id":18,"sum_currency":120,"currencid":48,"currency_rate":0,"currency_rate_add":0,"pay_date":"2014-01-24","invoice_doc_id":null,"payment_note":"","cfrid":null,"organizationid":153329,"contractorid":153171,"tmc_id":null}]}')