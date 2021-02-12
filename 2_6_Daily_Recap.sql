-- Daily Recap Report : 10/30/2020
-- Enter date to be used for each of the columns below

-- Missing store name, where is this obtained from?

DO $$
DECLARE 

--*** MODIFY DATE TO BE USED VVV HERE *** YYYY-MM-DD format
queryDate timestamp := '2020-10-4';


BEGIN
    CREATE TEMP TABLE temp_output ON COMMIT DROP AS
	select distinct on (queryDate)
	date(queryDate) as "Date",
    (
    select
        sum(transaction.sub_total)
        from transaction
        where transaction.created = queryDate
    ) as "Income Total",
	concat(to_char(menu.pickup_start_time, 'HH:MI'), ' - ', to_char(menu.pickup_end_time, 'HH:MI')) as "Time Range",
	menu.name as "Menu Name",
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
	order by queryDate;
END $$;

SELECT * FROM temp_output;