--Promo Code Lookup: 10/24/2020
--Date claimed/redeemed as time range argument

select distinct
promo_code.promo_code as "Promo Code",
(case 
	when promo_code.claimed is not null and promo_code.redeemed is null then 'Claimed'
	when promo_code.claimed is not null and promo_code.redeemed is not null then 'Redeemed'
	else 'Neither' end) as "Claimed/Redeemed",
promo_code.lastupdated as "Claimed/Redeemed Date",
promo_code.expiration_date as "Expiration Date",
(case
	when promo_code.non_unique in (True, 'T', true, 't') then 'Non-Unique'
 	when promo_code.non_unique in (False, 'F', false, 'f') then 'Unique'
 	else 'Unique' end) as "Type",
concat(account.firstname, ' ', account.lastname) as "First/Last Name",
account.email as "Email",
account.phone as "Phone",
(
SELECT 
	address.address
	from address
	left join orders on address.id = orders.delivery_address_id
	left join promo_code on promo_code.id = orders.promo_code_id
	where address.id = orders.delivery_address_id
	and orders.promo_code_id = promo_code.id
	group by address.id
) as "Address (Street)",
(
SELECT 
	address.zip
	from address
	left join orders on address.id = orders.delivery_address_id
	left join promo_code on promo_code.id = orders.promo_code_id
	where address.id = orders.delivery_address_id
	and orders.promo_code_id = promo_code.id
	group by address.id
) as "Zip COde",
(
SELECT 
	address.neighborhood
	from address
	left join orders on address.id = orders.delivery_address_id
	left join promo_code on promo_code.id = orders.promo_code_id
	where address.id = orders.delivery_address_id
	and orders.promo_code_id = promo_code.id
	group by address.id
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
	else 'None' end)
		from address
		left join orders on address.id = orders.delivery_address_id
		left join promo_code on promo_code.id = orders.promo_code_id
		where address.id = orders.delivery_address_id
		and orders.promo_code_id = promo_code.id
		group by address.id
) as "Alcadia",
(
SELECT 
	address.city
	from address
	left join orders on address.id = orders.delivery_address_id
	left join promo_code on promo_code.id = orders.promo_code_id
	where address.id = orders.delivery_address_id
	and orders.promo_code_id = promo_code.id
	group by address.id
) as "City",
(
SELECT 
	address.state
	from address
	left join orders on address.id = orders.delivery_address_id
	left join promo_code on promo_code.id = orders.promo_code_id
	where address.id = orders.delivery_address_id
	and orders.promo_code_id = promo_code.id
	group by address.id
) as "State",
date(account.created) as "Registration Date",
(
SELECT
	(case when
 		(SELECT
			count(orders.id)
			from orders
			inner join account on account.id = orders.buyer_account_id
			where orders.buyer_account_id = account.id
			group by account.id limit 1) >= 1 then 'Yes'
			else 'No' end)
		from orders
		inner join account on account.id = orders.buyer_account_id
		where orders.buyer_account_id = account.id
		group by account.id
		limit 1
) as "At least one successful purchase?"
from promo_code
inner join account on account.id = promo_code.account_id
left join orders on orders.promo_code_id = promo_code.id
where promo_code.lastupdated >= '2020-08-01' AND promo_code.lastupdated <= '2020-10-31';