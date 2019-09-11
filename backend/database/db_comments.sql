comment on type order_status_type is null;
comment on type order_category_type is null;
comment on type order_priority_type is null;
---------------------------------------------------------------------------
comment on type order_status_type is E'
Significados dos possíveis valores do enum order_status_type:\n
CAN: Cancelada;\n 
NEG: Negada;\n
PEN: Pendente;\n
SUS: Suspensa;\n
FIL: Fila de espera;\n
EXE: Execução;\n
CON: Concluída.
';

comment on type order_category_type is E'
Significados dos possíveis valores do enum order_category_type:\n
EST: Avaliação estrutural;\n
FOR: Reparo em forro;\n
INF: Infiltração;\n
ELE: Instalações elétricas;\n
HID: Instalações hidrossanitárias;\n
MAR: Marcenaria;\n
PIS: Reparo em piso;\n
REV: Revestimento;\n
VED: Vedação espacial;\n
VID: Vidraçaria / Esquadria;\n
SER: Serralheria.
';

comment on type order_priority_type is E'
Significados dos possíveis valores do enum order_priority_type:\n
BAI: Baixa;\n
NOR: Normal;\n
ALT: Alta;\n
URG: Urgente.
';