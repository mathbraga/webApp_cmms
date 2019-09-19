drop table if exists order_status_texts;
drop table if exists order_category_texts;
drop table if exists order_priority_texts;
-------------------------------------------------------------
create table order_status_texts (
  val order_status_type not null primary key,
  txt text
);
create table order_category_texts (
  val order_category_type not null primary key,
  txt text
);
create table order_priority_texts (
  val order_priority_type not null primary key,
  txt text
);
--------------------------------------------------------------------------------
insert into order_status_texts values
  ('CAN', 'Cancelada'),
  ('NEG', 'Negada'),
  ('PEN', 'Pendente'),
  ('SUS', 'Suspensa'),
  ('FIL', 'Fila da espera'),
  ('EXE', 'Execução'),
  ('CON', 'Concluída')
;

insert into order_category_texts values
  ('EST', 'Avaliação estrutural'),
  ('FOR', 'Reparo em forro'),
  ('INF', 'Infiltração'),
  ('ELE', 'Instalações elétricas'),
  ('HID', 'Instalações hidrossanitárias'),
  ('MAR', 'Marcenaria'),
  ('PIS', 'Reparo em piso'),
  ('REV', 'Revestimento'),
  ('VED', 'Vedação espacial'),
  ('VID', 'Vidraçaria/esquadria'),
  ('SER', 'Serralheria')
;

insert into order_priority_texts values
  ('BAI', 'Baixa'),
  ('NOR', 'Normal'),
  ('ALT', 'Alta'),
  ('URG', 'Urgente')
;

