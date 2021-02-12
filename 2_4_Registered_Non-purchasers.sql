select distinct
account.id as "Account Id",
account.created as "Registration Date",
round(extract (epoch from(current_date - account.created)/86400)::numeric,2) as "Number of Days Since Registration",
concat(account.firstname, ' ', account.lastname) as "First/Last Name",
account.email as "Email",
account.phone as "Phone",
address.address as "Address (Street)",
account.zip_code as "Zip Code",
address.neighborhood as "Neighborhood",
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
address.state as "State"
from account
left join delivery_address on delivery_address.account_id = account.id
left join address on address.id = delivery_address.address_id
where not exists
	(
	SELECT buyer_account_id
		from orders
		where orders.buyer_account_id = account.id
	)
and account.created >= '10-01-2020' and account.created <= '10-25-2020'
order by account.id desc