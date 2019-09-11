ALTER TYPE asset_category_type ADD VALUE 'X' AFTER 'Z';
ALTER TYPE asset_category_type ADD VALUE 'A';
UPDATE assets SET category = 'A' WHERE category = 'E';
--------------------------------------------------------------------
-- UPDATING ENUMS
ALTER TYPE order_category_type RENAME TO order_category_old;
ALTER TYPE order_status_type   RENAME TO order_status_old;
ALTER TYPE order_priority_type RENAME TO order_priority_old;

ALTER TYPE order_category_old  ADD VALUE 'ELE';
ALTER TYPE order_status_old    ADD VALUE 'PEN';
ALTER TYPE order_priority_old  ADD VALUE 'BAI';

UPDATE orders SET (category, status, priority) = ('ELE', 'PEN', 'BAI') WHERE TRUE;

CREATE TYPE order_status_type AS ENUM ('CAN', 'NEG', 'PEN', 'SUS', 'FIL', 'EXE', 'CON');
CREATE TYPE order_priority_type AS ENUM ('BAI', 'NOR', 'ALT', 'URG');
CREATE TYPE order_category_type AS ENUM ('EST', 'FOR', 'INF', 'ELE', 'HID', 'MAR', 'PIS', 'REV', 'VED', 'VID', 'SER');
ALTER TABLE orders ALTER COLUMN status   TYPE order_status_type   USING status::text::order_status_type;
ALTER TABLE orders ALTER COLUMN category TYPE order_category_type USING category::text::order_category_type;
ALTER TABLE orders ALTER COLUMN priority TYPE order_priority_type USING priority::text::order_priority_type;
DROP TYPE order_status_old;
DROP TYPE order_category_old;
DROP TYPE order_priority_old;