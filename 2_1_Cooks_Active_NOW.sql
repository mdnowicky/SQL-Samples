DO $$
DECLARE 

--Specify start date - end date in YYYY-MM-DD format.
active_date timestamp := '2020-10-4';
start_time time := '00:00:00';
end_time time := '23:59:00';

day_of_week text := rtrim(to_char(active_date, 'day'));


BEGIN
    CREATE TEMP TABLE temp_output ON COMMIT DROP AS
	select distinct on (menu.name)
	date(account.lastupdated) as "Date",
	concat(to_char(menu.pickup_start_time, 'HH:MI'), ' - ', to_char(menu.pickup_end_time, 'HH:MI')) as "Time Range",
	menu.name as "Menu Name",
	(
		SELECT 
			count(orders.id)
			from orders
			inner join store on store.id = orders.store_id
			where orders.store_id = store.id
			and orders.placed::timestamp::time >= start_time AND orders.placed::timestamp::time <= end_time
			and date(orders.created) >= active_date AND date(orders.created) < active_date + interval '1 day' 
			group by store.id limit 1
	) as "Orders Placed by Eater",
	(
		SELECT
			count(orders.id)
			from orders
			inner join store on store.id = orders.store_id
			where orders.store_id = store.id
			and orders.placed::timestamp::time >= start_time AND orders.placed::timestamp::time <= end_time
			and date(orders.created) >= active_date AND date(orders.created) < active_date + interval '1 day'
			and orders.status = '3'
			group by store.id limit 1
	) as "Orders Fulfilled by Cook",
	(
		SELECT
			count(orders.id)
			from orders
			inner join store on store.id = orders.store_id
			where orders.store_id = store.id
			and orders.placed::timestamp::time >= start_time AND orders.placed::timestamp::time <= end_time
			and date(orders.created) >= active_date AND date(orders.created) < active_date + interval '1 day'
			and orders.status = '9'
			group by store.id limit 1
	) as "Orders Delivered by iVoy",
	concat(account.firstname, ' ', account.lastname) as "Cook Name",
	account.email as "Email",
	account.phone as "Phone",
	address.address as "Address",
	address.zip as "Zip Code",
	(case when account.zip_code like '01%' then 'Álvaro Obregón' 
		when account.zip_code like '02%' then 'Azcapotzalcoelse'
 		when account.zip_code like '03%' then 'Benito Juárez'
 		when account.zip_code like '04%' then 'Coyoacán'
 		when account.zip_code like '05%' then 'Cuajimalpa'
 		when account.zip_code like '06%' then 'Cuauhtémoc'
 		when account.zip_code like '07%' then 'Gustavo A. Madero'
 		when account.zip_code like '08%' then 'Iztacalco'
 		when account.zip_code like '09%' then 'Iztapalapa'
 		when account.zip_code like '10%' then 'Magdalena Contreras'
 		when account.zip_code like '11%' then 'Miguel Hidalgo'
 		when account.zip_code like '12%' then 'Tlahuac'
 		when account.zip_code like '13%' then 'Tlalpan'
 		when account.zip_code like '14%' then 'Venustiano Carranza'
 		when account.zip_code like '15%' then 'Xochimilco'
			else 'Other' end) as "Alcadia",
	address.city as "City",
	address.state as "State",
	account.lastupdated as "Last login date/time"
	from account
	left join store on account.id = store.account_id
	left join menu on store.id = menu.store_id
	left join menu_item on menu.id = menu_item.menu_id
	left join orders on (orders.store_id = store.id)
	join store_address on store.id = store_address.store_id
	join address on store_address.address_id = address.id
	where account.lastupdated >= active_date AND account.lastupdated < active_date + interval '1 day'
    and menu.pickup_start_time >= start_time AND menu.pickup_end_time <= end_time
	and ((day_of_week like 'monday' and menu.repeat_mon in (True, 'T', true, 't'))
		or (day_of_week like 'tuesday' and menu.repeat_tues in (True, 'T', true, 't'))
		or (day_of_week like 'wednesday' and menu.repeat_wed in (True, 'T', true, 't'))
		or (day_of_week like 'thursday' and menu.repeat_thurs in (True, 'T', true, 't'))
		or (day_of_week like 'friday' and menu.repeat_fri in (True, 'T', true, 't'))
		or (day_of_week like 'saturday' and menu.repeat_sat in (True, 'T', true, 't'))
		or (day_of_week like 'sunday' and menu.repeat_sun in (True, 'T', true, 't')))
	order by menu.name;
END $$;

SELECT * FROM temp_output;
