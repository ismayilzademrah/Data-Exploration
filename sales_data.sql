-- Look at raw data
SELECT TOP (5) *
FROM SALES_DB..sales_data;

-- Drop some columns that I dont need
ALTER TABLE SALES_DB..sales_data
DROP COLUMN PHONE, ADDRESSLINE1, ADDRESSLINE2, STATE, POSTALCODE, TERRITORY;

-- Add ORDERDATE_CONVERTED column
ALTER TABLE SALES_DB..sales_data
ADD ORDERDATE_CONVERTED Date

-- Change Timestamp to Date
UPDATE SALES_DB..sales_data
SET ORDERDATE_CONVERTED = CONVERT(Date, ORDERDATE);

-- Add CONTACTNAME column
ALTER TABLE SALES_DB..sales_data
ADD CONTACTNAME Nvarchar(50)

-- Concatinating first and last name
UPDATE SALES_DB..sales_data
SET CONTACTNAME = CONCAT(CONTACTFIRSTNAME, ' ', CONTACTLASTNAME);

-- Drop some columns too
ALTER TABLE SALES_DB..sales_data
DROP COLUMN ORDERDATE, QTR_ID, MONTH_ID, YEAR_ID, CONTACTLASTNAME, CONTACTFIRSTNAME;

-- Remove duplicates
WITH RowNumCTE AS (
	SELECT *, ROW_NUMBER() OVER (
							PARTITION BY
								QUANTITYORDERED,
								PRICEEACH,
								ORDERLINENUMBER,
								SALES,
								STATUS,
								PRODUCTLINE,
								MSRP,
								PRODUCTCODE,
								CUSTOMERNAME,
								CITY,
								COUNTRY,
								DEALSIZE,
								ORDERDATE_CONVERTED,
								CONTACTNAME
							ORDER BY ORDERNUMBER
							) row_num
	FROM SALES_DB..sales_data
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

--1.Which month had the highest sales?
-- year and month
SELECT YEAR(ORDERDATE_CONVERTED) AS YEAR, MONTH(ORDERDATE_CONVERTED) AS MONTH, ROUND(MAX(SALES),2) AS MAX_SALES
FROM SALES_DB..sales_data
GROUP BY MONTH(ORDERDATE_CONVERTED), YEAR(ORDERDATE_CONVERTED)
ORDER BY MAX_SALES DESC, YEAR ASC, MONTH ASC;

-- only month
SELECT MONTH(ORDERDATE_CONVERTED) AS MONTH, ROUND(MAX(SALES),2) AS MAX_SALES
FROM SALES_DB..sales_data
GROUP BY MONTH(ORDERDATE_CONVERTED);

--2.Which city sold the most products?
SELECT CITY, SUM(QUANTITYORDERED) AS QUANTITY
FROM SALES_DB..sales_data
GROUP BY CITY
ORDER BY QUANTITY DESC;

--3.What products are most often sold together?
SELECT t1.PRODUCTCODE, t2.PRODUCTCODE, COUNT(*) AS SOLD
FROM SALES_DB..sales_data AS t1
INNER JOIN SALES_DB..sales_data AS t2
ON t1.ORDERNUMBER = t2.ORDERNUMBER
AND t1.PRODUCTCODE < t2.PRODUCTCODE
--WHERE t1.STATUS = 'Shipped'
GROUP BY t1.PRODUCTCODE, t2.PRODUCTCODE
ORDER BY SOLD DESC;

--4.What is the most popular shipping status?
SELECT STATUS, COUNT(*) AS COUNT
FROM SALES_DB..sales_data
GROUP BY STATUS
ORDER BY COUNT DESC;

--5.Which day of the week has the highest orders?
-- MAX SALES
SELECT ROUND(MAX(SALES),2) AS MAX_SALES, DATENAME(WEEKDAY, ORDERDATE_CONVERTED) AS WEEKDAY
FROM SALES_DB..sales_data
GROUP BY DATENAME(WEEKDAY, ORDERDATE_CONVERTED)
ORDER BY MAX_SALES DESC;

-- MAX ORDERS
SELECT SUM(QUANTITYORDERED) AS MAX_ORDERS, DATENAME(WEEKDAY, ORDERDATE_CONVERTED) AS WEEKDAY
FROM SALES_DB..sales_data
GROUP BY DATENAME(WEEKDAY, ORDERDATE_CONVERTED)
ORDER BY MAX_ORDERS DESC;

--6.What is the average order value?
SELECT ROUND(AVG(PRICEEACH), 2) AS AVG_ORD_VAL
FROM SALES_DB..sales_data

--7.What are the top 5 best-selling products?
SELECT TOP 5 PRODUCTCODE, SUM(QUANTITYORDERED) AS MAX_ORDERS
FROM SALES_DB..sales_data
GROUP BY PRODUCTCODE
ORDER BY MAX_ORDERS DESC;

--SELECT *
--FROM SALES_DB..sales_data