ALTER TABLE orderlist
ADD PRIMARY KEY (OrderID);

-- Change the data type of the OrderID column in both tables to VARCHAR to
-- match the nvarchar equivalent from SQL Server.
-- This is necessary to establish the foreign key relationship.

ALTER TABLE orderlist
MODIFY COLUMN OrderID VARCHAR(255) NOT NULL;

ALTER TABLE eachorderbreakdown
MODIFY COLUMN orderid VARCHAR(255) NOT NULL;

-- Add the foreign key constraint to link EachOrderBreakdown to OrdersList.

ALTER TABLE eachorderbreakdown
ADD CONSTRAINT fk_orderid FOREIGN KEY (orderid) REFERENCES orderlist(OrderID);


-- Q2: Split City State Country into 3 individual columns.

-- Add the new columns to the OrdersList table.
ALTER TABLE orderlist
ADD City VARCHAR(255),
ADD State VARCHAR(255),
ADD Country VARCHAR(255);

-- Use the SUBSTRING_INDEX function to split the combined column.
-- This is the MySQL equivalent of PARSENAME.
UPDATE orderlist
SET
    City = SUBSTRING_INDEX(SUBSTRING_INDEX(`City State Country`, ',', 1), ',', -1),
    State = SUBSTRING_INDEX(SUBSTRING_INDEX(`City State Country`, ',', 2), ',', -1),
    Country = SUBSTRING_INDEX(SUBSTRING_INDEX(`City State Country`, ',', 3), ',', -1);

-- Drop the original combined column after the data has been split.
ALTER TABLE OrdersList
DROP COLUMN `City State Country`;


-- Q3: Add a new Category Column with a mapping based on the first 3 characters.

-- Add the new 'Category' column to the EachOrderBreakdown table.
ALTER TABLE EachOrderBreakdown
ADD Category VARCHAR(255);

-- Update the new 'Category' column using a CASE statement.
UPDATE EachOrderBreakdown
SET Category = CASE
    WHEN LEFT(ProductName, 3) = 'OFS' THEN 'Office Supplies'
    WHEN LEFT(ProductName, 3) = 'TEC' THEN 'Technology'
    WHEN LEFT(ProductName, 3) = 'FUR' THEN 'Furniture'
END;


-- Q4: Delete the first 4 characters from the ProductName Column.

-- Use the SUBSTRING function to remove the first 4 characters from each string.
-- The SUBSTRING function in MySQL can take only a starting position to get the rest of the string.
UPDATE EachOrderBreakdown
SET ProductName = SUBSTRING(ProductName, 5);


-- Q5: Remove duplicate rows from EachOrderBreakdown table.

-- The CTE with a direct DELETE does not work in MySQL.
-- This alternative uses a self-join to correctly delete duplicates.
DELETE T1
FROM EachOrderBreakdown AS T1
JOIN (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY OrderID, ProductName, Discount, Sales, Profit, Quantity, Category, SubCategory
            ORDER BY (SELECT 0)
        ) AS rn,
        OrderID AS UniqueID
    FROM EachOrderBreakdown
) AS T2 ON T1.OrderID = T2.UniqueID
WHERE T2.rn > 1;


-- Q6: Replace blank with NA in OrderPriority Column in OrdersList table.

-- This is a straightforward UPDATE statement that works in MySQL.
UPDATE OrdersList
SET OrderPriority = 'NA'
WHERE OrderPriority = '';