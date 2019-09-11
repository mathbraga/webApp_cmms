drop table if exists order_status_texts;
drop table if exists order_category_texts;
drop table if exists order_priority_texts;
-------------------------------------------------------------
CREATE TABLE order_status_texts (
  val order_status_type not null primary key,
  txt text
);
CREATE TABLE order_category_texts (
  val order_category_type not null primary key,
  txt text
);
CREATE TABLE order_priority_texts (
  val order_priority_type not null primary key,
  txt text
);
--------------------------------------------------------------------------------
INSERT INTO order_status_texts VALUES
  ('CAN', 'Cancelada'),
  ('NEG', 'Negada'),
  ('PEN', 'Pendente'),
  ('SUS', 'Suspensa'),
  ('FIL', 'Fila da espera'),
  ('EXE', 'Execução'),
  ('CON', 'Concluída')
;

INSERT INTO order_category_texts VALUES
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

INSERT INTO order_priority_texts VALUES
  ('BAI', 'Baixa'),
  ('NOR', 'Normal'),
  ('ALT', 'Alta'),
  ('URG', 'Urgente')
;

