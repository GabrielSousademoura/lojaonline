
SET search_path TO public;


CREATE OR REPLACE VIEW public.vw_admcore_cliente_completo AS
SELECT
    c.id_cliente,
    p.id_pessoa,
    p.nome,
    p.nome_social,
    COALESCE(p.nome_social, p.nome) AS nome_exibicao,
    p.cpfcnpj,
    p.tipo_pessoa,
    p.data_nascimento,
    p.rg,
    c.apelido,
    c.foto_url,
    c.biografia,
    c.status_cliente,
    l.email AS email_login,
    l.email_verificado,
    l.status_login,
    l.ultimo_login,
    contatos.email_contato,
    contatos.telefone,
    contatos.celular,
    contatos.whatsapp,
    e.id_endereco AS id_endereco_principal,
    e.tipo_endereco AS tipo_endereco_principal,
    e.logradouro,
    e.numero,
    e.complemento,
    e.bairro,
    e.cidade,
    e.estado,
    e.cep,
    c.data_cadastro,
    c.data_atualizacao
FROM public.admcore_cliente c
JOIN public.admcore_pessoa p
    ON p.id_pessoa = c.id_pessoa
LEFT JOIN public.cauth_login l
    ON l.id_cliente = c.id_cliente
LEFT JOIN LATERAL (
    SELECT
        (
            SELECT cc.valor
            FROM public.admcore_clientecontato cc
            WHERE cc.id_cliente = c.id_cliente
              AND cc.tipo_contato = 'email'
            ORDER BY cc.principal DESC, cc.verificado DESC, cc.id_contato ASC
            LIMIT 1
        ) AS email_contato,
        (
            SELECT cc.valor
            FROM public.admcore_clientecontato cc
            WHERE cc.id_cliente = c.id_cliente
              AND cc.tipo_contato = 'telefone'
            ORDER BY cc.principal DESC, cc.verificado DESC, cc.id_contato ASC
            LIMIT 1
        ) AS telefone,
        (
            SELECT cc.valor
            FROM public.admcore_clientecontato cc
            WHERE cc.id_cliente = c.id_cliente
              AND cc.tipo_contato = 'celular'
            ORDER BY cc.principal DESC, cc.verificado DESC, cc.id_contato ASC
            LIMIT 1
        ) AS celular,
        (
            SELECT cc.valor
            FROM public.admcore_clientecontato cc
            WHERE cc.id_cliente = c.id_cliente
              AND cc.tipo_contato = 'whatsapp'
            ORDER BY cc.principal DESC, cc.verificado DESC, cc.id_contato ASC
            LIMIT 1
        ) AS whatsapp
) contatos ON TRUE
LEFT JOIN LATERAL (
    SELECT e1.*
    FROM public.admcore_endereco e1
    WHERE e1.id_cliente = c.id_cliente
    ORDER BY e1.principal DESC, e1.id_endereco ASC
    LIMIT 1
) e ON TRUE;


CREATE OR REPLACE VIEW public.vw_marketplace_categoria_hierarquia AS
SELECT
    c.id_categoria,
    c.id_categoria_pai,
    pai.nome AS categoria_pai,
    c.nome,
    c.slug,
    c.descricao,
    c.ativo,
    c.data_cadastro,
    c.data_atualizacao
FROM public.marketplace_categoria c
LEFT JOIN public.marketplace_categoria pai
    ON pai.id_categoria = c.id_categoria_pai;


CREATE OR REPLACE VIEW public.vw_marketplace_anuncio_detalhado AS
SELECT
    a.id_anuncio,
    a.id_vendedor,
    pv.nome AS nome_vendedor,
    cv.apelido AS apelido_vendedor,
    cv.foto_url AS foto_vendedor,
    cv.status_cliente AS status_vendedor,
    a.id_categoria,
    cat.nome AS categoria,
    cat.slug AS categoria_slug,
    cat.id_categoria_pai,
    cat_pai.nome AS categoria_pai,
    a.id_endereco_origem,
    e.cidade AS cidade_origem,
    e.estado AS estado_origem,
    a.titulo,
    a.descricao,
    a.condicao_produto,
    a.preco,
    a.quantidade,
    a.aceita_proposta,
    a.tipo_entrega,
    a.status_anuncio,
    a.visualizacoes,
    foto.url_foto AS foto_principal_url,
    COALESCE(fotos.total_fotos, 0) AS total_fotos,
    COALESCE(favs.total_favoritos, 0) AS total_favoritos,
    COALESCE(pedidos.total_vendas, 0) AS total_vendas,
    COALESCE(aval.avaliacao_media_vendedor, 0) AS avaliacao_media_vendedor,
    COALESCE(aval.total_avaliacoes_vendedor, 0) AS total_avaliacoes_vendedor,
    a.data_publicacao,
    a.data_expiracao,
    a.data_cadastro,
    a.data_atualizacao
FROM public.marketplace_anuncio a
JOIN public.admcore_cliente cv
    ON cv.id_cliente = a.id_vendedor
JOIN public.admcore_pessoa pv
    ON pv.id_pessoa = cv.id_pessoa
JOIN public.marketplace_categoria cat
    ON cat.id_categoria = a.id_categoria
LEFT JOIN public.marketplace_categoria cat_pai
    ON cat_pai.id_categoria = cat.id_categoria_pai
LEFT JOIN public.admcore_endereco e
    ON e.id_endereco = a.id_endereco_origem
LEFT JOIN LATERAL (
    SELECT af.url_foto
    FROM public.marketplace_anunciofoto af
    WHERE af.id_anuncio = a.id_anuncio
    ORDER BY af.principal DESC, af.ordem ASC, af.id_foto ASC
    LIMIT 1
) foto ON TRUE
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS total_fotos
    FROM public.marketplace_anunciofoto af
    WHERE af.id_anuncio = a.id_anuncio
) fotos ON TRUE
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS total_favoritos
    FROM public.marketplace_favorito f
    WHERE f.id_anuncio = a.id_anuncio
) favs ON TRUE
LEFT JOIN LATERAL (
    SELECT COUNT(DISTINCT pi.id_pedido) AS total_vendas
    FROM public.marketplace_pedidoitem pi
    JOIN public.marketplace_pedido p
        ON p.id_pedido = pi.id_pedido
    WHERE pi.id_anuncio = a.id_anuncio
      AND p.status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido')
) pedidos ON TRUE
LEFT JOIN LATERAL (
    SELECT
        AVG(av.nota)::NUMERIC(10,2) AS avaliacao_media_vendedor,
        COUNT(*) AS total_avaliacoes_vendedor
    FROM public.marketplace_avaliacao av
    WHERE av.id_avaliado = a.id_vendedor
      AND av.papel_avaliado = 'vendedor'
) aval ON TRUE;


CREATE OR REPLACE VIEW public.vw_marketplace_anuncio_publico AS
SELECT
    id_anuncio,
    id_vendedor,
    nome_vendedor,
    apelido_vendedor,
    id_categoria,
    categoria,
    categoria_slug,
    cidade_origem,
    estado_origem,
    titulo,
    descricao,
    condicao_produto,
    preco,
    quantidade,
    aceita_proposta,
    tipo_entrega,
    visualizacoes,
    foto_principal_url,
    total_fotos,
    total_favoritos,
    avaliacao_media_vendedor,
    total_avaliacoes_vendedor,
    data_publicacao,
    data_expiracao
FROM public.vw_marketplace_anuncio_detalhado
WHERE status_anuncio = 'ativo'
  AND status_vendedor = 'ativo'
  AND quantidade > 0
  AND (data_expiracao IS NULL OR data_expiracao >= CURRENT_TIMESTAMP);


CREATE OR REPLACE VIEW public.vw_marketplace_favorito_detalhado AS
SELECT
    f.id_favorito,
    f.id_cliente,
    pc.nome AS nome_cliente,
    f.id_anuncio,
    a.titulo,
    a.preco,
    a.status_anuncio,
    a.foto_principal_url,
    a.id_vendedor,
    a.nome_vendedor,
    a.cidade_origem,
    a.estado_origem,
    f.data_cadastro
FROM public.marketplace_favorito f
JOIN public.admcore_cliente c
    ON c.id_cliente = f.id_cliente
JOIN public.admcore_pessoa pc
    ON pc.id_pessoa = c.id_pessoa
JOIN public.vw_marketplace_anuncio_detalhado a
    ON a.id_anuncio = f.id_anuncio;


CREATE OR REPLACE VIEW public.vw_marketplace_carrinho_detalhado AS
SELECT
    car.id_carrinho,
    car.id_cliente,
    pcli.nome AS nome_cliente,
    car.status_carrinho,
    ci.id_carrinho_item,
    ci.id_anuncio,
    a.titulo,
    a.id_vendedor,
    a.nome_vendedor,
    a.status_anuncio,
    a.preco,
    ci.quantidade,
    (a.preco * ci.quantidade)::DECIMAL(12,2) AS total_item,
    a.foto_principal_url,
    car.data_cadastro AS data_carrinho,
    ci.data_cadastro AS data_item
FROM public.marketplace_carrinho car
JOIN public.admcore_cliente cli
    ON cli.id_cliente = car.id_cliente
JOIN public.admcore_pessoa pcli
    ON pcli.id_pessoa = cli.id_pessoa
JOIN public.marketplace_carrinhoitem ci
    ON ci.id_carrinho = car.id_carrinho
JOIN public.vw_marketplace_anuncio_detalhado a
    ON a.id_anuncio = ci.id_anuncio;


CREATE OR REPLACE VIEW public.vw_marketplace_conversa_resumo AS
SELECT
    conv.id_conversa,
    conv.id_anuncio,
    a.titulo AS titulo_anuncio,
    a.foto_principal_url,
    conv.id_comprador,
    pc.nome AS nome_comprador,
    cc.apelido AS apelido_comprador,
    conv.id_vendedor,
    pv.nome AS nome_vendedor,
    cv.apelido AS apelido_vendedor,
    conv.status_conversa,
    ultima.id_mensagem AS id_ultima_mensagem,
    ultima.id_remetente AS id_ultimo_remetente,
    pr.nome AS nome_ultimo_remetente,
    ultima.mensagem AS ultima_mensagem,
    ultima.lida AS ultima_mensagem_lida,
    ultima.data_cadastro AS data_ultima_mensagem,
    COALESCE(pendentes.total_nao_lidas, 0) AS total_nao_lidas,
    conv.data_cadastro,
    conv.data_atualizacao
FROM public.marketplace_conversa conv
JOIN public.vw_marketplace_anuncio_detalhado a
    ON a.id_anuncio = conv.id_anuncio
JOIN public.admcore_cliente cc
    ON cc.id_cliente = conv.id_comprador
JOIN public.admcore_pessoa pc
    ON pc.id_pessoa = cc.id_pessoa
JOIN public.admcore_cliente cv
    ON cv.id_cliente = conv.id_vendedor
JOIN public.admcore_pessoa pv
    ON pv.id_pessoa = cv.id_pessoa
LEFT JOIN LATERAL (
    SELECT m.*
    FROM public.marketplace_mensagem m
    WHERE m.id_conversa = conv.id_conversa
    ORDER BY m.data_cadastro DESC, m.id_mensagem DESC
    LIMIT 1
) ultima ON TRUE
LEFT JOIN public.admcore_cliente cr
    ON cr.id_cliente = ultima.id_remetente
LEFT JOIN public.admcore_pessoa pr
    ON pr.id_pessoa = cr.id_pessoa
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS total_nao_lidas
    FROM public.marketplace_mensagem m
    WHERE m.id_conversa = conv.id_conversa
      AND m.lida = FALSE
) pendentes ON TRUE;


CREATE OR REPLACE VIEW public.vw_marketplace_pedido_detalhado AS
SELECT
    ped.id_pedido,
    ped.codigo_pedido,
    ped.id_comprador,
    pc.nome AS nome_comprador,
    cc.apelido AS apelido_comprador,
    ped.id_vendedor,
    pv.nome AS nome_vendedor,
    cv.apelido AS apelido_vendedor,
    ped.id_endereco_entrega,
    ee.cidade AS cidade_entrega,
    ee.estado AS estado_entrega,
    ped.status_pedido,
    ped.subtotal,
    ped.valor_frete,
    ped.valor_desconto,
    ped.valor_taxa_plataforma,
    ped.total,
    itens.total_itens,
    itens.quantidade_total,
    pag.id_pagamento,
    pag.status_pagamento,
    pag.valor AS valor_pagamento,
    pag.parcelas,
    fp.codigo AS forma_pagamento_codigo,
    fp.nome AS forma_pagamento,
    pag.gateway,
    pag.gateway_pagamento_id,
    pag.cartao_bandeira_snapshot,
    pag.cartao_ultimos4_snapshot,
    env.id_envio,
    env.modalidade_envio,
    env.transportadora,
    env.codigo_rastreamento,
    env.status_envio,
    env.data_postagem,
    env.data_entrega,
    ped.observacao,
    ped.data_pedido,
    ped.data_atualizacao
FROM public.marketplace_pedido ped
JOIN public.admcore_cliente cc
    ON cc.id_cliente = ped.id_comprador
JOIN public.admcore_pessoa pc
    ON pc.id_pessoa = cc.id_pessoa
JOIN public.admcore_cliente cv
    ON cv.id_cliente = ped.id_vendedor
JOIN public.admcore_pessoa pv
    ON pv.id_pessoa = cv.id_pessoa
LEFT JOIN public.admcore_endereco ee
    ON ee.id_endereco = ped.id_endereco_entrega
LEFT JOIN LATERAL (
    SELECT
        COUNT(*) AS total_itens,
        COALESCE(SUM(pi.quantidade), 0) AS quantidade_total
    FROM public.marketplace_pedidoitem pi
    WHERE pi.id_pedido = ped.id_pedido
) itens ON TRUE
LEFT JOIN LATERAL (
    SELECT pgt.*
    FROM public.financeiro_pagamento pgt
    WHERE pgt.id_pedido = ped.id_pedido
    ORDER BY pgt.data_pagamento DESC, pgt.id_pagamento DESC
    LIMIT 1
) pag ON TRUE
LEFT JOIN public.financeiro_formapagamento fp
    ON fp.id_forma_pagamento = pag.id_forma_pagamento
LEFT JOIN public.logistica_envio env
    ON env.id_pedido = ped.id_pedido;


CREATE OR REPLACE VIEW public.vw_marketplace_pedidoitem_detalhado AS
SELECT
    pi.id_pedido_item,
    pi.id_pedido,
    ped.codigo_pedido,
    ped.status_pedido,
    ped.id_comprador,
    pc.nome AS nome_comprador,
    ped.id_vendedor,
    pv.nome AS nome_vendedor,
    pi.id_anuncio,
    a.titulo AS titulo_atual_anuncio,
    pi.titulo_snapshot,
    pi.preco_unitario_snapshot,
    pi.quantidade,
    pi.total_item,
    a.status_anuncio,
    a.foto_principal_url,
    pi.data_cadastro
FROM public.marketplace_pedidoitem pi
JOIN public.marketplace_pedido ped
    ON ped.id_pedido = pi.id_pedido
JOIN public.admcore_cliente cc
    ON cc.id_cliente = ped.id_comprador
JOIN public.admcore_pessoa pc
    ON pc.id_pessoa = cc.id_pessoa
JOIN public.admcore_cliente cv
    ON cv.id_cliente = ped.id_vendedor
JOIN public.admcore_pessoa pv
    ON pv.id_pessoa = cv.id_pessoa
JOIN public.vw_marketplace_anuncio_detalhado a
    ON a.id_anuncio = pi.id_anuncio;


CREATE OR REPLACE VIEW public.vw_financeiro_pagamento_detalhado AS
SELECT
    pag.id_pagamento,
    pag.id_pedido,
    ped.codigo_pedido,
    ped.id_comprador,
    ped.nome_comprador,
    ped.id_vendedor,
    ped.nome_vendedor,
    pag.id_forma_pagamento,
    fp.codigo AS forma_pagamento_codigo,
    fp.nome AS forma_pagamento,
    pag.id_cartao,
    bc.codigo AS bandeira_codigo,
    bc.nome AS bandeira_nome,
    pag.valor,
    pag.parcelas,
    pag.status_pagamento,
    pag.gateway,
    pag.gateway_pagamento_id,
    pag.nsu,
    pag.tid,
    pag.codigo_autorizacao,
    pag.cartao_bandeira_snapshot,
    pag.cartao_ultimos4_snapshot,
    pag.data_autorizacao,
    pag.data_captura,
    pag.data_pagamento,
    pag.data_atualizacao
FROM public.financeiro_pagamento pag
JOIN public.vw_marketplace_pedido_detalhado ped
    ON ped.id_pedido = pag.id_pedido
JOIN public.financeiro_formapagamento fp
    ON fp.id_forma_pagamento = pag.id_forma_pagamento
LEFT JOIN public.financeiro_cartaocliente cc
    ON cc.id_cartao = pag.id_cartao
LEFT JOIN public.financeiro_bandeiracartao bc
    ON bc.id_bandeira_cartao = cc.id_bandeira_cartao;


CREATE OR REPLACE VIEW public.vw_financeiro_cartaocliente_resumo AS
SELECT
    cc.id_cartao,
    cc.id_cliente,
    p.nome AS nome_cliente,
    bc.codigo AS bandeira_codigo,
    bc.nome AS bandeira_nome,
    cc.gateway,
    cc.titular_nome,
    cc.ultimos4,
    cc.mes_expiracao,
    cc.ano_expiracao,
    cc.principal,
    cc.status_cartao,
    cc.data_cadastro,
    cc.data_atualizacao
FROM public.financeiro_cartaocliente cc
JOIN public.admcore_cliente c
    ON c.id_cliente = cc.id_cliente
JOIN public.admcore_pessoa p
    ON p.id_pessoa = c.id_pessoa
JOIN public.financeiro_bandeiracartao bc
    ON bc.id_bandeira_cartao = cc.id_bandeira_cartao;


CREATE OR REPLACE VIEW public.vw_financeiro_repasse_vendedor AS
SELECT
    r.id_repasse,
    r.id_pedido,
    ped.codigo_pedido,
    r.id_vendedor,
    pv.nome AS nome_vendedor,
    cv.apelido AS apelido_vendedor,
    r.id_recebedor,
    rec.gateway,
    rec.gateway_recebedor_id,
    rec.tipo_recebedor,
    rec.status_recebedor,
    r.valor_bruto,
    r.valor_taxa_plataforma,
    r.valor_liquido,
    r.status_repasse,
    pag.status_pagamento,
    ped.status_pedido,
    r.data_prevista,
    r.data_pagamento,
    r.gateway_repasse_id,
    r.data_cadastro,
    r.data_atualizacao
FROM public.financeiro_repasse r
JOIN public.marketplace_pedido ped
    ON ped.id_pedido = r.id_pedido
JOIN public.admcore_cliente cv
    ON cv.id_cliente = r.id_vendedor
JOIN public.admcore_pessoa pv
    ON pv.id_pessoa = cv.id_pessoa
LEFT JOIN public.financeiro_recebedor rec
    ON rec.id_recebedor = r.id_recebedor
LEFT JOIN LATERAL (
    SELECT pgt.status_pagamento
    FROM public.financeiro_pagamento pgt
    WHERE pgt.id_pedido = r.id_pedido
    ORDER BY pgt.data_pagamento DESC, pgt.id_pagamento DESC
    LIMIT 1
) pag ON TRUE;


CREATE OR REPLACE VIEW public.vw_logistica_envio_detalhado AS
SELECT
    env.id_envio,
    env.id_pedido,
    ped.codigo_pedido,
    ped.id_comprador,
    pc.nome AS nome_comprador,
    ped.id_vendedor,
    pv.nome AS nome_vendedor,
    env.id_endereco_origem,
    eo.cidade AS cidade_origem,
    eo.estado AS estado_origem,
    env.id_endereco_destino,
    ed.logradouro AS destino_logradouro,
    ed.numero AS destino_numero,
    ed.bairro AS destino_bairro,
    ed.cidade AS cidade_destino,
    ed.estado AS estado_destino,
    ed.cep AS cep_destino,
    env.modalidade_envio,
    env.transportadora,
    env.codigo_rastreamento,
    env.valor_frete,
    env.status_envio,
    env.data_postagem,
    env.data_entrega,
    env.data_cadastro,
    env.data_atualizacao
FROM public.logistica_envio env
JOIN public.marketplace_pedido ped
    ON ped.id_pedido = env.id_pedido
JOIN public.admcore_cliente cc
    ON cc.id_cliente = ped.id_comprador
JOIN public.admcore_pessoa pc
    ON pc.id_pessoa = cc.id_pessoa
JOIN public.admcore_cliente cv
    ON cv.id_cliente = ped.id_vendedor
JOIN public.admcore_pessoa pv
    ON pv.id_pessoa = cv.id_pessoa
LEFT JOIN public.admcore_endereco eo
    ON eo.id_endereco = env.id_endereco_origem
LEFT JOIN public.admcore_endereco ed
    ON ed.id_endereco = env.id_endereco_destino;


CREATE OR REPLACE VIEW public.vw_marketplace_avaliacao_resumo_cliente AS
SELECT
    c.id_cliente,
    p.nome,
    c.apelido,
    COALESCE(AVG(av.nota)::NUMERIC(10,2), 0) AS avaliacao_media_geral,
    COUNT(av.id_avaliacao) AS total_avaliacoes,
    COALESCE((AVG(av.nota) FILTER (WHERE av.papel_avaliado = 'vendedor'))::NUMERIC(10,2), 0) AS avaliacao_media_vendedor,
    COUNT(av.id_avaliacao) FILTER (WHERE av.papel_avaliado = 'vendedor') AS total_avaliacoes_vendedor,
    COALESCE((AVG(av.nota) FILTER (WHERE av.papel_avaliado = 'comprador'))::NUMERIC(10,2), 0) AS avaliacao_media_comprador,
    COUNT(av.id_avaliacao) FILTER (WHERE av.papel_avaliado = 'comprador') AS total_avaliacoes_comprador
FROM public.admcore_cliente c
JOIN public.admcore_pessoa p
    ON p.id_pessoa = c.id_pessoa
LEFT JOIN public.marketplace_avaliacao av
    ON av.id_avaliado = c.id_cliente
GROUP BY
    c.id_cliente,
    p.nome,
    c.apelido;


CREATE OR REPLACE VIEW public.vw_marketplace_denuncia_detalhada AS
SELECT
    d.id_denuncia,
    d.id_denunciante,
    pd.nome AS nome_denunciante,
    d.id_cliente_denunciado,
    pden.nome AS nome_cliente_denunciado,
    d.id_anuncio,
    a.titulo AS titulo_anuncio,
    a.id_vendedor AS id_vendedor_anuncio,
    a.nome_vendedor AS nome_vendedor_anuncio,
    d.motivo,
    d.descricao,
    d.status_denuncia,
    d.data_cadastro,
    d.data_atualizacao
FROM public.marketplace_denuncia d
JOIN public.admcore_cliente cd
    ON cd.id_cliente = d.id_denunciante
JOIN public.admcore_pessoa pd
    ON pd.id_pessoa = cd.id_pessoa
LEFT JOIN public.admcore_cliente cden
    ON cden.id_cliente = d.id_cliente_denunciado
LEFT JOIN public.admcore_pessoa pden
    ON pden.id_pessoa = cden.id_pessoa
LEFT JOIN public.vw_marketplace_anuncio_detalhado a
    ON a.id_anuncio = d.id_anuncio;


CREATE OR REPLACE VIEW public.vw_dashboard_resumo_geral AS
SELECT
    (SELECT COUNT(*) FROM public.admcore_cliente WHERE status_cliente <> 'excluido') AS total_clientes,
    (SELECT COUNT(*) FROM public.admcore_cliente WHERE status_cliente = 'ativo') AS clientes_ativos,
    (SELECT COUNT(*) FROM public.marketplace_anuncio) AS total_anuncios,
    (SELECT COUNT(*) FROM public.marketplace_anuncio WHERE status_anuncio = 'ativo') AS anuncios_ativos,
    (SELECT COUNT(*) FROM public.marketplace_pedido) AS total_pedidos,
    (SELECT COUNT(*) FROM public.marketplace_pedido WHERE status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido')) AS pedidos_validos,
    (SELECT COALESCE(SUM(total), 0) FROM public.marketplace_pedido WHERE status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido')) AS valor_total_vendido,
    (SELECT COALESCE(SUM(valor_taxa_plataforma), 0) FROM public.marketplace_pedido WHERE status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido')) AS valor_total_taxa_plataforma,
    (SELECT COUNT(*) FROM public.financeiro_pagamento WHERE status_pagamento = 'pendente') AS pagamentos_pendentes,
    (SELECT COUNT(*) FROM public.financeiro_repasse WHERE status_repasse IN ('pendente', 'liberado')) AS repasses_pendentes,
    (SELECT COALESCE(SUM(valor_liquido), 0) FROM public.financeiro_repasse WHERE status_repasse IN ('pendente', 'liberado')) AS valor_repasses_pendentes,
    (SELECT COUNT(*) FROM public.logistica_envio WHERE status_envio IN ('pendente', 'preparando', 'postado', 'em_transito')) AS envios_em_aberto,
    (SELECT COUNT(*) FROM public.marketplace_denuncia WHERE status_denuncia IN ('aberta', 'em_analise')) AS denuncias_em_aberto;


CREATE OR REPLACE VIEW public.vw_dashboard_vendedor AS
SELECT
    c.id_cliente AS id_vendedor,
    p.nome AS nome_vendedor,
    c.apelido AS apelido_vendedor,
    COALESCE(an.total_anuncios, 0) AS total_anuncios,
    COALESCE(an.anuncios_ativos, 0) AS anuncios_ativos,
    COALESCE(vendas.total_vendas, 0) AS total_vendas,
    COALESCE(vendas.vendas_validas, 0) AS vendas_validas,
    COALESCE(vendas.valor_total_vendido, 0) AS valor_total_vendido,
    COALESCE(vendas.valor_taxa_plataforma, 0) AS valor_taxa_plataforma,
    COALESCE(rep.valor_a_receber, 0) AS valor_a_receber,
    COALESCE(rep.valor_ja_recebido, 0) AS valor_ja_recebido,
    COALESCE(av.avaliacao_media_vendedor, 0) AS avaliacao_media_vendedor,
    COALESCE(av.total_avaliacoes_vendedor, 0) AS total_avaliacoes_vendedor
FROM public.admcore_cliente c
JOIN public.admcore_pessoa p
    ON p.id_pessoa = c.id_pessoa
LEFT JOIN LATERAL (
    SELECT
        COUNT(*) AS total_anuncios,
        COUNT(*) FILTER (WHERE a.status_anuncio = 'ativo') AS anuncios_ativos
    FROM public.marketplace_anuncio a
    WHERE a.id_vendedor = c.id_cliente
) an ON TRUE
LEFT JOIN LATERAL (
    SELECT
        COUNT(*) AS total_vendas,
        COUNT(*) FILTER (WHERE ped.status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido')) AS vendas_validas,
        COALESCE(SUM(ped.total) FILTER (WHERE ped.status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido')), 0) AS valor_total_vendido,
        COALESCE(SUM(ped.valor_taxa_plataforma) FILTER (WHERE ped.status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido')), 0) AS valor_taxa_plataforma
    FROM public.marketplace_pedido ped
    WHERE ped.id_vendedor = c.id_cliente
) vendas ON TRUE
LEFT JOIN LATERAL (
    SELECT
        COALESCE(SUM(r.valor_liquido) FILTER (WHERE r.status_repasse IN ('pendente', 'liberado')), 0) AS valor_a_receber,
        COALESCE(SUM(r.valor_liquido) FILTER (WHERE r.status_repasse = 'pago'), 0) AS valor_ja_recebido
    FROM public.financeiro_repasse r
    WHERE r.id_vendedor = c.id_cliente
) rep ON TRUE
LEFT JOIN LATERAL (
    SELECT
        COALESCE(AVG(av.nota)::NUMERIC(10,2), 0) AS avaliacao_media_vendedor,
        COUNT(*) AS total_avaliacoes_vendedor
    FROM public.marketplace_avaliacao av
    WHERE av.id_avaliado = c.id_cliente
      AND av.papel_avaliado = 'vendedor'
) av ON TRUE;


CREATE OR REPLACE VIEW public.vw_dashboard_comprador AS
SELECT
    c.id_cliente AS id_comprador,
    p.nome AS nome_comprador,
    c.apelido AS apelido_comprador,
    COALESCE(comp.total_compras, 0) AS total_compras,
    COALESCE(comp.compras_validas, 0) AS compras_validas,
    COALESCE(comp.compras_canceladas, 0) AS compras_canceladas,
    COALESCE(comp.valor_total_compras, 0) AS valor_total_compras,
    COALESCE(fav.total_favoritos, 0) AS total_favoritos,
    comp.data_ultima_compra,
    COALESCE(av.avaliacao_media_comprador, 0) AS avaliacao_media_comprador,
    COALESCE(av.total_avaliacoes_comprador, 0) AS total_avaliacoes_comprador
FROM public.admcore_cliente c
JOIN public.admcore_pessoa p
    ON p.id_pessoa = c.id_pessoa
LEFT JOIN LATERAL (
    SELECT
        COUNT(*) AS total_compras,
        COUNT(*) FILTER (WHERE ped.status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido')) AS compras_validas,
        COUNT(*) FILTER (WHERE ped.status_pedido = 'cancelado') AS compras_canceladas,
        COALESCE(SUM(ped.total) FILTER (WHERE ped.status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido')), 0) AS valor_total_compras,
        MAX(ped.data_pedido) AS data_ultima_compra
    FROM public.marketplace_pedido ped
    WHERE ped.id_comprador = c.id_cliente
) comp ON TRUE
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS total_favoritos
    FROM public.marketplace_favorito f
    WHERE f.id_cliente = c.id_cliente
) fav ON TRUE
LEFT JOIN LATERAL (
    SELECT
        COALESCE(AVG(av.nota)::NUMERIC(10,2), 0) AS avaliacao_media_comprador,
        COUNT(*) AS total_avaliacoes_comprador
    FROM public.marketplace_avaliacao av
    WHERE av.id_avaliado = c.id_cliente
      AND av.papel_avaliado = 'comprador'
) av ON TRUE;


CREATE OR REPLACE VIEW public.vw_history_linha_tempo_pedido AS
SELECT
    h.id_pedido,
    ped.codigo_pedido,
    'pedido'::VARCHAR(20) AS tipo_evento,
    h.status_anterior,
    h.status_novo,
    h.id_cliente_responsavel,
    pr.nome AS nome_responsavel,
    h.observacao,
    h.data_cadastro AS data_evento
FROM public.history_historico_status_pedido h
JOIN public.marketplace_pedido ped
    ON ped.id_pedido = h.id_pedido
LEFT JOIN public.admcore_cliente cr
    ON cr.id_cliente = h.id_cliente_responsavel
LEFT JOIN public.admcore_pessoa pr
    ON pr.id_pessoa = cr.id_pessoa

UNION ALL

SELECT
    ped.id_pedido,
    ped.codigo_pedido,
    'pagamento'::VARCHAR(20) AS tipo_evento,
    h.status_anterior,
    h.status_novo,
    NULL::BIGINT AS id_cliente_responsavel,
    NULL::VARCHAR(120) AS nome_responsavel,
    h.observacao,
    h.data_cadastro AS data_evento
FROM public.history_historico_status_pagamento h
JOIN public.financeiro_pagamento pag
    ON pag.id_pagamento = h.id_pagamento
JOIN public.marketplace_pedido ped
    ON ped.id_pedido = pag.id_pedido

UNION ALL

SELECT
    ped.id_pedido,
    ped.codigo_pedido,
    'envio'::VARCHAR(20) AS tipo_evento,
    h.status_anterior,
    h.status_novo,
    NULL::BIGINT AS id_cliente_responsavel,
    NULL::VARCHAR(120) AS nome_responsavel,
    h.observacao,
    h.data_cadastro AS data_evento
FROM public.history_historico_status_envio h
JOIN public.logistica_envio env
    ON env.id_envio = h.id_envio
JOIN public.marketplace_pedido ped
    ON ped.id_pedido = env.id_pedido;


CREATE OR REPLACE VIEW public.vw_history_linha_tempo_anuncio AS
SELECT
    h.id_anuncio,
    a.titulo,
    a.id_vendedor,
    a.nome_vendedor,
    h.status_anterior,
    h.status_novo,
    h.id_cliente_responsavel,
    pr.nome AS nome_responsavel,
    h.observacao,
    h.data_cadastro AS data_evento
FROM public.history_historico_status_anuncio h
JOIN public.vw_marketplace_anuncio_detalhado a
    ON a.id_anuncio = h.id_anuncio
LEFT JOIN public.admcore_cliente cr
    ON cr.id_cliente = h.id_cliente_responsavel
LEFT JOIN public.admcore_pessoa pr
    ON pr.id_pessoa = cr.id_pessoa;


CREATE OR REPLACE VIEW public.vw_suporte_pedido_completo AS
SELECT
    ped.id_pedido,
    ped.codigo_pedido,
    ped.status_pedido,
    ped.id_comprador,
    ped.nome_comprador,
    ped.id_vendedor,
    ped.nome_vendedor,
    ped.total,
    ped.status_pagamento,
    ped.forma_pagamento,
    ped.status_envio,
    ped.codigo_rastreamento,
    ped.modalidade_envio,
    ped.transportadora,
    ped.cidade_entrega,
    ped.estado_entrega,
    COALESCE(den.total_denuncias, 0) AS total_denuncias_relacionadas,
    COALESCE(msg.total_mensagens, 0) AS total_mensagens_relacionadas,
    hist.ultimo_evento,
    hist.data_ultimo_evento,
    ped.data_pedido,
    ped.data_atualizacao
FROM public.vw_marketplace_pedido_detalhado ped
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS total_denuncias
    FROM public.marketplace_denuncia d
    WHERE d.id_cliente_denunciado IN (ped.id_comprador, ped.id_vendedor)
) den ON TRUE
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS total_mensagens
    FROM public.marketplace_conversa conv
    JOIN public.marketplace_mensagem m
        ON m.id_conversa = conv.id_conversa
    WHERE conv.id_comprador = ped.id_comprador
      AND conv.id_vendedor = ped.id_vendedor
) msg ON TRUE
LEFT JOIN LATERAL (
    SELECT
        CONCAT(lt.tipo_evento, ': ', COALESCE(lt.status_anterior, 'inicio'), ' -> ', lt.status_novo) AS ultimo_evento,
        lt.data_evento AS data_ultimo_evento
    FROM public.vw_history_linha_tempo_pedido lt
    WHERE lt.id_pedido = ped.id_pedido
    ORDER BY lt.data_evento DESC
    LIMIT 1
) hist ON TRUE;

