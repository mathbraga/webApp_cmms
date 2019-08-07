\! clear

drop function if exists create_wo;

create or replace function create_wo(jsonb)
returns int
language plpgsql
as $$
declare
  id_new integer;
  asset text;
begin   
        -- BEGIN TRANSACTION;
        INSERT INTO work_orders (
          status1,
          prioridade,
          origem,
          responsavel,
          categoria,
          servico,
          descricao,
          data_inicial,
          data_prazo,
          realizado,
          data_criacao,
          data_atualiz,
          sigad,
          solic_orgao,
          solic_nome,
          contato_nome,
          contato_email,
          contato_tel,
          mensagem,
          orcamento,
          conferido,
          lugar,
          executante,
          os_num,
          ans,
          status2,
          multitarefa
        ) VALUES (
          (select $1->'status1')::text,
          (select $1->'prioridade')::text,
          (select $1->'origem')::text,
          (select $1->'responsavel')::text,
          (select $1->'categoria')::text,
          (select $1->'servico')::text,
          (select $1->'descricao')::text,
          (select $1->'data_inicial')::text,
          (select $1->'data_prazo')::text,
          (select $1->'realizado')::integer,
          (select $1->'data_criacao')::text,
          (select $1->'data_atualiz')::text,
          (select $1->'sigad')::text,
          (select $1->'solic_orgao')::text,
          (select $1->'solic_nome')::text,
          (select $1->'contato_nome')::text,
          (select $1->'contato_email')::text,
          (select $1->'contato_tel')::text,
          (select $1->'mensagem')::text,
          (select $1->'orcamento')::text,
          (select $1->'conferido')::text,
          (select $1->'lugar')::text,
          (select $1->'executante')::text,
          (select $1->'os_num')::text,
          (select $1->'ans')::text,
          (select $1->'status2')::text,
          (select $1->'multitarefa')::text
        ) RETURNING id INTO STRICT id_new;

        -- FOREACH asset IN ARRAY (select $1->'assetsList') LOOP
          -- INSERT INTO wos_assets (wo_id, asset_id)
          --   VALUES (id_new, (select $1->'assetsList'->0));
        -- END LOOP;
        -- COMMIT;
        RETURN id_new;
end; $$;
