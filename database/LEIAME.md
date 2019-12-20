# Tabela de entidades no banco de dados

|Entidade no banco de dados|Função no sistema|
|--------------------------|-----------------|
|Task|Tarefa, que registra uma ação necessária pela SINFRA, geralmente com a utilização de mão-de-obra, material ou serviço de algum contrato. |
|Asset|Ativo (qualquer imóvel listado no manual de endereçamento desenvolvido pela arquitetura) ou equipamento/subsistema de algum dos sistemas cuja manutenção é realizada pela SINFRA (como elevadores, aparelhos de ar-condicionado, geradores, quadros elétricos etc.). As relações entre um ativo e outro servem para indicar a localização de um ativo (em que sala está determinado aparelho?) ou a hierarquia entre eles (tal quadro elétrico é alimentado por qual estação transformadora?).|
|Contract|Contrato (ou projeto de contratação) com fiscalização ou gestão realizadas pela SINFRA.|
|Person|Usuário do CMMS (efetivos, comissionados, terceirizados).|
|Spec|Especificação técnica de um suprimento.|
|Supply|Suprimento (material ou serviço) vinculado a um contrato, com respectivos preço unitário e quantitativo, e que possui uma especificação técnica.|
|Team|Equipe, grupo de usuários do CMMS responsável por alguma ação pendente em uma tarefa.|
|Project|Agrupa várias tarefas para alguma atividade da SINFRA que necessita da utilização de vários contratos e/ou tarefas.|


# Grafo das relações entre as entidades

A imagem abaixo mostra as principais relações entre as entidades existentes no banco de dados.
Como trata-se de um banco de dados relacional (RDBMS), essas relações são registradas por meio de chaves estrangeiras e/ou tabelas de associação (a depender do tipo de relação --> 0 ou 1 para 1 ou muitos).

![alttext](https://www.draw.io/?lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=CMMS#R7Vtdk6I4FP01PrZFwvdja0%2FPdFXPVu%2FaU7u9L1tZiMo0EjfEaZ1fv0GCQIJfiMBU6YNlLhDIPZeTc2%2FiQB8v1p8pWs6%2FEh%2BHA6j564H%2BMIDQ0QD%2FTgyb1AAsXVhmNPBTm5YbJsFPLE7MrKvAx7GwpSZGSMiCZdnokSjCHivZEKXko3zalIR%2BybBEM6wYJh4KVeufgc%2FmYlzQzu1fcDCbZ3cGlpseWaDsZDGSeI588lEw6Z8G%2BpgSwtJfi%2FUYh4nzyn553HN092AUR%2ByUCzx%2F%2FDyafPsHvT3%2B4W%2F%2BfvJ%2F%2F766E738QOFKDFg8LNtkHuC9cGfzxuhjHjA8WSIvOfLB8ea2OVuEvAX4TxQvUwSmwRrzm47UJ8xuhynD64JJPPFnTBaY0Q0%2FRRzVoZleIuLnzrGEOz8KaAjTvABEZkMC%2F9mu69xF%2FIfw0hkeg4rHXlH8rniNj48%2FyShmlLzjMQkJ5faIRIkfp0EYSiYUBrOINz3uKszto8RFAQ%2FDe3FgEfh%2B0veIklXkJ%2B590HgrRP%2FicIS899nWnvU6gPp0%2B9mdQqiPaeGwtv0kT8jxDKIZt8K89YynTNxhTmjwk0QMZTAfiYImQLdk0G0VdKMCdHgt0M1f7TWxYceviaV47D6OMdv3nhT80%2FwrUwVI069REyDaJ4DYatjbCohf%2BD2UyI%2F8%2B2SmTbAIURwHXhlQvA7YX4mjh6ZovRWOPKwFBtvGJmtE%2FPkLFyXNt%2BKx%2FLJtK7tuLwwxWVEPH58JGaIzzI5TAfZLukEFtYCZWYFZZqM4RCz4UVYbVUCKO7yQgI8sjxldK8eMaUvBkA5cXFaUB3JPjtSTJYdV6hqlp21k7QZeP9hA37UINKT3062YllolWaCKkW8x58KbGGlOjOwY9xDqrbIy0BXUxxQjhtum5paI%2BVRmBr1iZiDP5lZdZt7lwjs53DYz913%2BmvIs6GhdM7Oqfyer5TLc7OPmmwDmMNoyjKBrqlUVMJ9g6%2FMsKLBszrln8WyuhzuTwKBfGlgJG1evybSmI2dgMmdfm2mdnjOtrkseAkDvmmpdxWevGC32Ee1NBDcDu9ExNWcdF2B%2Firxw5V8ig88XwaAlEeycys39UsGmRM2mVVsEg6ENTBs6tsn1nu3YElPrzhA6BrQBNGzDkp%2F0yrwN1ZSsX7xtyjmEm9XYO1tHMRSXjTmpUeTtLRLfqLsO8vIr6Noq8u0yt5pOJsijIOq0gHFFYZ3Rw3H2tnrF3pYlJ2RmTfq2FWXttqusoZqQ94uhd%2BX2Xb3I7FhYQzX5nfBx72PnWwWj4oWpArFdslUzylHin4SNSMt0O4TltbyhBvQjnLttvWAacG8kEXKpjDZPJGLYLyI25cU5O5tEzyViS5Mj1LgaEX8dr6xn8H53999m8vz6GwyfJo%2B933EEgTRT7XzfAg9XegwqHrttpTgGoryDqArEa%2FFwJYhqgviSDhBqZFqfh%2BuwcEsbKiqo9hAh9IRpeb50hB9PrljIZWlDZogrM62aYF%2B0e6e4dFGjNgauFminZ1dOr0LNNPShoeclLbccLkBz9aHrFkpe9eLQkLUD77jdQOx76gWUBfYWU69Kj6mZ1wsl3%2FGtNNZoaQzsLW90pRLUZO3inT11FIJ1lkRoOkerWIY%2BRCs9YXMg12%2Bcuksd8jbDK5bKKv2qrqdeoht6s%2BXhUAz9YnvLoGMcXAxzNLcJ5QBcKaRtM1lkazUYs6m5sT3orlkKSOg4p7KiJlWvbOto9Yr3JBNj02x5YgBnIrknEWzIVZbaKwvK%2BpbCu7UjlDfzv%2Belp%2Bd%2FctQ%2F%2FQ8%3D)