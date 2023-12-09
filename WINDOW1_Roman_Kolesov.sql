--Task Description
--Construct a query to generate a sales report for customers ranked in the top 300 based on total sales in the years 1998, 1999, and 2001.
-- The report should be categorized based on sales channels, and separate calculations should be performed for each channel. Consider the following instructions:
--Retrieve customers who ranked among the top 300 in sales for the years 1998, 1999, and 2001.
--Categorize the customers based on their sales channels.
--Perform separate calculations for each sales channel.
--Include in the report only purchases made on the channel specified.
--Format the column so that total sales are displayed with two decimal places.


WITH TotalSales AS (
    SELECT
        s.cust_id,
        s.channel_id,
        SUM(s.amount_sold) AS total_sales
    FROM
        sh.sales s
        JOIN sh.times t ON s.time_id = t.time_id
    WHERE
        t.calendar_year IN (1998, 1999, 2001)
    GROUP BY
        s.cust_id, s.channel_id
),
ChannelRankedCustomers AS (
    SELECT
        ts.cust_id,
        ts.channel_id,
        ts.total_sales,
        ROW_NUMBER() OVER (PARTITION BY ts.channel_id ORDER BY ts.total_sales DESC) AS channel_rank
    FROM
        TotalSales ts
),
GlobalRankedCustomers AS (
    SELECT
        crc.*,
        c.cust_first_name,
        c.cust_last_name,
        ch.channel_desc,
        ROW_NUMBER() OVER (ORDER BY crc.total_sales DESC) AS global_rank
    FROM
        ChannelRankedCustomers crc
        JOIN sh.customers c ON crc.cust_id = c.cust_id
        JOIN sh.channels ch ON crc.channel_id = ch.channel_id
    WHERE
        crc.channel_rank <= 300
)
SELECT
    cust_id,
    cust_first_name,
    cust_last_name,
    channel_desc,
    ROUND(total_sales, 2) AS total_sales_rounded
FROM
    GlobalRankedCustomers
WHERE
    global_rank <= 300;


--Explanation:
-- To calculate the total sales amount for each customer in each channel for the years 1998, 1999, and 2001
-- SELECT s.cust_id, s.channel_id: Selects customer ID and channel ID.
-- SUM(s.amount_sold) AS total_sales: Sums up the sales amount for each customer per channel.
-- JOIN sh.times t ON s.time_id = t.time_id: Joins the sales table with the times table to filter sales based on years.
-- WHERE t.calendar_year IN (1998, 1999, 2001): Filters records for the years 1998, 1999, and 2001.
-- GROUP BY s.cust_id, s.channel_id: Groups results by customer and channel.

-- To rank customers within each channel based on their total sales.
-- ROW_NUMBER() OVER (PARTITION BY ts.channel_id ORDER BY ts.total_sales DESC) AS channel_rank:
-- Assigns a rank to each customer within a channel, ordered by total sales in descending order.

-- To rank customers globally across all channels and to retrieve customer names and channel descriptions.
-- crc.*: Selects all columns from the ChannelRankedCustomers CTE.
-- c.cust_first_name, c.cust_last_name, ch.channel_desc: Joins with customers and channels tables to get customer names and channel descriptions.
-- ROW_NUMBER() OVER (ORDER BY crc.total_sales DESC) AS global_rank: Assigns a global rank to each customer based on total sales.
-- WHERE crc.channel_rank <= 300: Filters to include only customers who are within the top 300 in their respective channels.

-- To retrieve the final report with the top 300 customers globally.
-- Selects customer ID, first name, last name, channel description, and total sales rounded to two decimal places.
-- Filters to include only the top 300 customers globally.