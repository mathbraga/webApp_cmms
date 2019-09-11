comment on type order_status_type is null;
comment on type order_category_type is null;
comment on type order_priority_type is null;
---------------------------------------------------------------------------
comment on type order_status_type is E'
Significados dos poss�veis valores do enum order_status_type:\n
CAN: Cancelada;\n 
NEG: Negada;\n
PEN: Pendente;\n
SUS: Suspensa;\n
FIL: Fila de espera;\n
EXE: Execu��o;\n
CON: Conclu�da.
';

comment on type order_category_type is E'
Significados dos poss�veis valores do enum order_category_type:\n
EST: Avalia��o estrutural;\n
FOR: Reparo em forro;\n
INF: Infiltra��o;\n
ELE: Instala��es el�tricas;\n
HID: Instala��es hidrossanit�rias;\n
MAR: Marcenaria;\n
PIS: Reparo em piso;\n
REV: Revestimento;\n
VED: Veda��o espacial;\n
VID: Vidra�aria / Esquadria;\n
SER: Serralheria.
';

comment on type order_priority_type is E'
Significados dos poss�veis valores do enum order_priority_type:\n
BAI: Baixa;\n
NOR: Normal;\n
ALT: Alta;\n
URG: Urgente.
';