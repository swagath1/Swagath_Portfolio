use ds

create table sales_store(
transaction_id varchar(15),
customer_id varchar(15),
customer_name varchar(30),
customer_age int,
gender varchar(15),
product_id varchar(15),
product_name varchar(15),
product_category varchar(15),
quantiy int,
prce float,
payment_mode varchar(50),
purchase_date date,
time_of_purchase time,
status varchar(15)
);

select * from sales_store

set dateformat dmy
bulk insert sales_store
from 'E:\sales_store_updated_allign_with_video.csv'
     with(
	       firstrow=2,
		   fieldterminator=',',
		   rowterminator='\n'
	  );

select * from sales_store

--this command is used for copying the dataset 
select * into sales from sales_store

select * from sales

-- step 1: datacleaning

select 
     transaction_id,count(*)
from sales 
group by transaction_id 
having count(transaction_id)>1;

with cte as (
select *,
      row_number() over(partition by transaction_id order by transaction_id) row
from sales
)

--delete from cte where row=2

select * from cte
where transaction_id in ('TXN240646',
'TXN342128',
'TXN855235',
'TXN981773'
)

--2.renaming the headers which are wrong

exec sp_rename'sales.quantiy','quantity','column'

exec sp_rename'sales.prce','price','column'


--3.checking data_type

select
      column_name,data_type 
from information_schema.columns 
where table_name='sales'

select 
     * 
from sales 
where transaction_id is null
or customer_id is null
or customer_name is null
or status is null

delete from sales where transaction_id is null

--filling the null values

select * from sales where customer_name='ehsaan ram'

--update the record where null is present in the dataset

update sales 
set customer_id='cust9494'
where transaction_id='txn977900'

select * from sales where customer_name='damini raju'

update sales 
set customer_id='cust1401'
where transaction_id='txn985663'

select * from sales where customer_id='cust1003'

update sales
set customer_name='Mahik Saini',
customer_age='35',
gender='Male'
where transaction_id='txn432798'

--all null values are removed

select * from sales where transaction_id is null

select distinct gender,count(*) from sales group by gender

update sales set gender='M' where gender='Male'

update sales set gender='F' where gender='Female'

update sales set payment_mode='Credit Card' where payment_mode='CC'


--Data Analysis
--1. what are the top 5 selling products by quantity

select 
     product_name, total_sales 
from 
    (select product_name,sum(quantity) total_sales,rank()over(order by sum(quantity) desc) rnk
from sales where status='delivered' group by product_name  )t where rnk<=5;

--Business Problem-we dont know which products are in demand
 
 --2. which products are more frequently cancelled?

select top 5 product_name,count(quantity) total_cancelled 
from sales 
where status='cancelled' 
group by product_name 
order by count(quantity) desc

-- Business Problem-frequent cancellations effect revenue and customer trust

--3.what time of the day has the highest number of purchases?

select 
      case 
	      when datepart(hour,time_of_purchase) between 0 and 5 then 'night'
		  when datepart(hour,time_of_purchase) between 6 and 11 then 'morning'
		  when datepart(hour,time_of_purchase) between 12 and 17 then 'afternoon'
		  when datepart(hour,time_of_purchase) between 18 and 23 then 'evening'
	  end as time_of_day,
	  count(*) total_orders
from sales 
group by case 
	      when datepart(hour,time_of_purchase) between 0 and 5 then 'night'
		  when datepart(hour,time_of_purchase) between 6 and 11 then 'morning'
		  when datepart(hour,time_of_purchase) between 12 and 17 then 'afternoon'
		  when datepart(hour,time_of_purchase) between 18 and 23 then 'evening'
	  end 
order by total_orders desc

--4. who are the top 5 highest spending customers?

select 
      top 5 customer_name,format(sum(price*quantity),'c0','en-in') total_spend 
from sales 
group by customer_name 
order by total_spend desc

--5. which product categories generate highest revenue?

select 
      top 5 product_category,format(sum(quantity*price),'c0','en-in') revenue 
from sales 
group by product_category
order by sum(quantity*price) desc

--6. what is the return/cancellation rate per product_category

select product_category,
       format(count(case when status='cancelled' then 1 end)*100.0/count(*),'n3')+' %' as cancelled_percent
from sales
group by product_category
order by cancelled_percent desc

select product_category,
       format(count(case when status='returned' then 1 end)*100.0/count(*),'n3')+' %' as returned_percent
from sales
group by product_category
order by returned_percent desc

--7. what is the most preferred payment mode?

select 
     payment_mode,count(*) most_used 
from sales 
group by payment_mode 
order by most_used desc

--8. how does age group effect purchasing behavior

select 
     case 
	     when customer_age between 18 and 25 then '18-25'
		 when customer_age between 26 and 35 then '26-35'
	     when customer_age between 36 and 50 then '36-50'
		 else '51+'
	  end as c_age,
	format(sum(quantity*price),'c0','en-in') total_spend
group by case 
	     when customer_age between 18 and 25 then '18-25'
		 when customer_age between 26 and 35 then '26-35'
	     when customer_age between 36 and 50 then '36-50'
		 else '51+'
	  end
order by total_spend desc

--9. what's the monthly sales trend?

select * from sales

select 
     month(purchase_date) month,
	 sum(quantity*price) total_sales,
	 sum(quantity) total_quantity 
from sales 
group by month(purchase_date) 
order by month desc

--10. are certain genders buying more specific product categories?

select 
      product_category,gender,count(*) total_sales 
from sales 
group by product_category,gender 
order by gender desc

select * 
from ( select product_category,gender 
from sales) source_t
pivot (
       count(gender) for gender in([M],[F])
	   ) as pivot_t
order by product_category




