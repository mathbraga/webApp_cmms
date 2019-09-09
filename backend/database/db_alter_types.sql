ALTER TYPE asset_category_type ADD VALUE 'X' AFTER 'Z';

ALTER TYPE asset_category_type ADD VALUE 'A';

UPDATE assets SET category = 'A' WHERE category = 'E';