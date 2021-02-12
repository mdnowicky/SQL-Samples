-- Redeemed Promo Codes Report: 10/30/2020
-- Date range as input from promo_code.redeemed (promo code redemption date)
-- Shows all orders that redeemed a promo code during checkout

select distinct
account.id as "Customer ID", 
promo_code.promo_code as "Promo Code", 
cast(promo_code.value as money) as "Code Value",
promo_code.expiration_date as "Expiration Date", 
promo_code.redeemed as "Redemption", 
(
select
    cast(sum(order_item.purchase_price) as money)
    from order_item
    where order_item.order_id = orders.id
    group by orders.id, order_item.id
    limit 1
) as "Total Food Value", 
cast(transaction.sub_total as money) as "Total Order Value",
concat(account.firstname, ' ', account.lastname) as "Customer Name",
account.email as "Email", 
account.phone as "Phone", 
account.zip_code as "Zip Code", 
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
		else 'Other' end) as "Alcadia"
from account
inner join orders on account.id = orders.buyer_account_id
inner join order_item on order_item.order_id = orders.id
left join promo_code on orders.promo_code_id = promo_code.id
left join delivery_address on account.id = delivery_address.account_id
left join address on address.id = delivery_address.address_id
left join transaction on orders.id = transaction.order_id
where promo_code.redeemed >= '10-01-2020' and promo_code.redeemed <= '10-25-2020'
and promo_code.redeemed is not null

