-- 1)
--Si queremos un promedio bruto, podemos simplemente calcular la diferencia entre 
-- el pago más reciente y el más antiguo y dividirlo por los intervalos totales 
-- entre pagos (pagos-1). 
select customer_id, (MAX(payment_date)- MIN(payment_date))/(count(*)-1) 
from payment p group by customer_id 
having count(*)>1;

-- utilizando la función lag(), podemos analizar los intervalos entre los pagos 
-- de forma más precisa 
select sq.customer_id, AVG(sq.payment_date-sq.fechaAnt) from(
	select customer_id, payment_date, lag(payment_date) over (partition by customer_id order by payment_date)
	as fechaAnt from payment p2) as sq
group by sq.customer_id;

-- se me hizo interesante que en el caso del customer 1 la diferencia es de 0.000001 segundos 

--con CTEs
with intervalosPago as (
	select customer_id, payment_date, lag(payment_date) over (partition by customer_id order by payment_date)
	as fechaAnt from payment p2)

select intervalosPago.customer_id, AVG(intervalosPago.payment_date-intervalosPago.fechaAnt) as dif
from intervalosPago group by intervalosPago.customer_id order by intervalosPago.customer_id asc;

--2) 
select intervalosPago.customer_id, AVG(intervalosPago.payment_date-intervalosPago.fechaAnt) as dif
from intervalosPago group by intervalosPago.customer_id order by dif asc;
--notamos que sí tiene una distribución normal

--3) 
with intervalosPago as (
	select customer_id, payment_date, lag(payment_date) over (partition by customer_id order by payment_date)
	as fechaAnt from payment p2),
	
intervalosRenta as (
	select customer_id, rental_date, lag(rental_date) over (partition by customer_id order by rental_date)
	as fechaPrev from rental r)

select intervalosPago.customer_id, (AVG(intervalosPago.payment_date-intervalosPago.fechaAnt)-
	AVG(intervalosRenta.rental_date-intervalosRenta.fechaPrev)) as difProm from intervalosPago join 
	intervalosRenta on (intervalosPago.customer_id=intervalosRenta.customer_id) group by 
	intervalosPago.customer_id;
--me regresa diferencias de 0, pero no sé si se me cuatrapeó o si así debe ser.
--hay muy pocos que sí me regresan un tiempo mayor a 0. No sé si son los pocos deudores que tiene Sakila 
-- o si mis CTEs están mal hechas 