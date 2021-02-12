-- Promo Codes Claimed vs Redeemed
-- Notes:
-- Takes date range of order placed as input

select distinct
date(account.created) as "Registration Date",
concat(account.firstname, ' ', account.lastname) as "First/Last Name",
account.email as "Email",
account.phone as "Phone", 
(
SELECT
	address.address
	from address
	where address.id = orders.delivery_address_id
	limit 1
) as "Address (Street)",
(
SELECT
	address.zip
	from address
	where address.id = orders.delivery_address_id
	limit 1
) as "Zip Code",
(
SELECT
	address.neighborhood
	from address
	where address.id = orders.delivery_address_id
	limit 1
) as "Neighborhood",
(
SELECT
(case when address.zip like '01%' then 'Álvaro Obregón' 
	when address.zip like '02%' then 'Azcapotzalcoelse'
 	when address.zip like '03%' then 'Benito Juárez'
 	when address.zip like '04%' then 'Coyoacán'
 	when address.zip like '05%' then 'Cuajimalpa'
 	when address.zip like '06%' then 'Cuauhtémoc'
 	when address.zip like '07%' then 'Gustavo A. Madero'
 	when address.zip like '08%' then 'Iztacalco'
 	when address.zip like '09%' then 'Iztapalapa'
 	when address.zip like '10%' then 'Magdalena Contreras'
 	when address.zip like '11%' then 'Miguel Hidalgo'
 	when address.zip like '12%' then 'Tlahuac'
 	when address.zip like '13%' then 'Tlalpan'
 	when address.zip like '14%' then 'Venustiano Carranza'
 	when address.zip like '15%' then 'Xochimilco'
	else 'N/A' end)
from address
where address.id = orders.delivery_address_id
limit 1
) as "Alcadia",
(
SELECT
	address.city
	from address
	where address.id = orders.delivery_address_id
	limit 1
) as "City",
(
SELECT
	address.state
	from address
	where address.id = orders.delivery_address_id
	limit 1
) as "State",
(
SELECT
	count(orders.id)
	from orders
	where orders.buyer_account_id = account.id
) as "Successfully Placed Orders",
(
SELECT
	count(orders.id)
	from orders
	where orders.buyer_account_id = account.id
	and orders.promo_code_id is not null
) as "Successful Orders with Redeemed Promo Code"
from orders
inner join account on (orders.buyer_account_id = account.id)
where orders.placed >= '2020-09-28' AND orders.placed <= '2020-10-8';