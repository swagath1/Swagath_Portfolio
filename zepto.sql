use zepto

select * from zepto

ALTER TABLE zepto
ADD id INT IDENTITY(1,1);

--Data Exploration

--Counted the total number of records in the dataset

select count(*) total_records from zepto;

--Viewed a sample of the dataset to understand structure and content

select top 10 * from zepto;

--Checked for null values across all columns

select * from zepto
where category is null
or
name is null
or
mrp is null
or
discountPercent is null
or
availableQuantity is null
or
discountedSellingPrice is null
or
weightInGms is null
or
outofstock is null
or
quantity is null

--Identified distinct product categories available in the dataset

select distinct category from zepto

--Compared in-stock vs out-of-stock product counts

SELECT outOfStock, COUNT(id) stock
FROM zepto
GROUP BY outOfStock;

--Detected products present multiple times, representing different SKUs

select name,count(id) no_id from zepto
group by name
having count(*)>1
order by no_id desc

--Data Cleaning

--Identified and removed rows where MRP or discounted selling price was zero

select * 
from zepto 
where mrp=0 
and 
discountedsellingprice =0

--Converted mrp and discountedSellingPrice from paise to rupees for consistency and readability

update zepto set mrp=mrp/100.0,discountedsellingprice=discountedsellingprice/100.0;

--Business Insights

--Found top 10 best-value products based on discount percentage

--using cte
with cte as (
select 
      category,
	  name,
	  discountpercent,
	  rank() over(order by discountpercent desc) rk 
from zepto)

select * from cte where rk<=10

--using subquery

select * from (select 
      category,
	  name,
	  discountpercent,
	  rank() over(order by discountpercent desc) rk 
from zepto)t where rk<=10

--Identified high-MRP products that are currently out of stock

WITH cte AS (
    SELECT
	    id,
        category,
        name,
        mrp,
        outofstock,
        RANK() OVER (ORDER BY mrp DESC) AS rnk
    FROM zepto
    WHERE outofstock = 1
)
SELECT *
FROM cte

--Estimated potential revenue for each product category

select 
      category,
	  sum(mrp*quantity) revenue 
from zepto 
group by category

--Filtered expensive products (MRP > ₹500) with minimal discount

select 
     category,name,mrp,discountpercent  minimal_discount 
from zepto 
where mrp>500 
and
discountpercent<10
order by minimal_discount

--Ranked top 5 categories offering highest average discounts
with cte as(
select 
category,avg(discountpercent) avg_discounts 
from zepto 
group by category),
cte1 as (
select *,
rank()over(order by avg_discounts desc) rk 
from cte )
select * from cte1 where rk<=5

--Find the price per gram for products above 100g and sort by best value.

SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

--Group the products into categories like Low, Medium, Bulk.

select distinct name,weightingms,case
                         when weightingms > 5000 then 'bulk'
					     when weightingms between 1000 and 5000 then 'medium'
						 else 'low'
						 end as different_levels
from zepto
order by weightingms desc

--What is the Total Inventory Weight Per Category 

select 
category ,
sum(cast(weightingms as decimal(10,2))*availablequantity) total_inventory 
from zepto 
group by category
order by total_inventory;

