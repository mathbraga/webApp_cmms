select * from assets where asset_id like 'ACAT%';
select * from assets where starts_with(asset_id, 'ACAT-');
select * from assets where asset_id similar to '%((ACAT-))%';
