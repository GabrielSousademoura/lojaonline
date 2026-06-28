
BEGIN;

SET LOCAL search_path TO public;
SET LOCAL synchronous_commit = off;


CREATE TEMP TABLE tmp_mass_config ON COMMIT DROP AS
SELECT
    20000::INTEGER AS qtd_clientes,
    80000::INTEGER AS qtd_anuncios,
    250000::INTEGER AS qtd_favoritos,
    60000::INTEGER AS qtd_conversas,
    5::INTEGER AS mensagens_por_conversa,
    3::INTEGER AS fotos_por_anuncio,
    4::INTEGER AS atributos_por_anuncio,
    3::INTEGER AS itens_por_carrinho,
    50000::INTEGER AS qtd_pedidos,
    5000::INTEGER AS qtd_denuncias,
    'TESTE_MASSA_V1'::TEXT AS lote;


INSERT INTO public.financeiro_formapagamento (codigo, nome) VALUES
('cartao_credito', 'Cartão de crédito'),
('cartao_debito', 'Cartão de débito'),
('pix', 'Pix'),
('boleto', 'Boleto'),
('saldo_carteira', 'Saldo em carteira')
ON CONFLICT (codigo) DO UPDATE
SET nome = EXCLUDED.nome,
    ativo = TRUE;

INSERT INTO public.financeiro_bandeiracartao (codigo, nome) VALUES
('visa', 'Visa'),
('mastercard', 'Mastercard'),
('elo', 'Elo'),
('amex', 'American Express'),
('hipercard', 'Hipercard'),
('diners', 'Diners Club'),
('discover', 'Discover'),
('outros', 'Outros')
ON CONFLICT (codigo) DO UPDATE
SET nome = EXCLUDED.nome,
    ativo = TRUE;


INSERT INTO public.marketplace_categoria (nome, slug, descricao, ativo)
VALUES
('Eletrônicos', 'teste-eletronicos', 'Categoria fictícia para eletrônicos', TRUE),
('Celulares', 'teste-celulares', 'Categoria fictícia para celulares', TRUE),
('Informática', 'teste-informatica', 'Categoria fictícia para informática', TRUE),
('Casa e móveis', 'teste-casa-moveis', 'Categoria fictícia para casa e móveis', TRUE),
('Moda', 'teste-moda', 'Categoria fictícia para moda', TRUE),
('Beleza', 'teste-beleza', 'Categoria fictícia para beleza', TRUE),
('Esporte', 'teste-esporte', 'Categoria fictícia para esporte', TRUE),
('Livros', 'teste-livros', 'Categoria fictícia para livros', TRUE),
('Games', 'teste-games', 'Categoria fictícia para games', TRUE),
('Brinquedos', 'teste-brinquedos', 'Categoria fictícia para brinquedos', TRUE),
('Veículos e peças', 'teste-veiculos-pecas', 'Categoria fictícia para veículos e peças', TRUE),
('Serviços digitais', 'teste-servicos-digitais', 'Categoria fictícia para serviços digitais', TRUE)
ON CONFLICT (slug) DO UPDATE
SET nome = EXCLUDED.nome,
    descricao = EXCLUDED.descricao,
    ativo = TRUE;

INSERT INTO public.marketplace_categoria (id_categoria_pai, nome, slug, descricao, ativo)
SELECT p.id_categoria, v.nome, v.slug, v.descricao, TRUE
FROM (
    VALUES
    ('teste-eletronicos', 'TVs', 'teste-tvs', 'Subcategoria fictícia'),
    ('teste-eletronicos', 'Áudio e vídeo', 'teste-audio-video', 'Subcategoria fictícia'),
    ('teste-celulares', 'Smartphones Android', 'teste-smartphones-android', 'Subcategoria fictícia'),
    ('teste-celulares', 'iPhones', 'teste-iphones', 'Subcategoria fictícia'),
    ('teste-informatica', 'Notebooks', 'teste-notebooks', 'Subcategoria fictícia'),
    ('teste-informatica', 'Monitores', 'teste-monitores', 'Subcategoria fictícia'),
    ('teste-casa-moveis', 'Sofás', 'teste-sofas', 'Subcategoria fictícia'),
    ('teste-casa-moveis', 'Mesas', 'teste-mesas', 'Subcategoria fictícia'),
    ('teste-moda', 'Roupas femininas', 'teste-roupas-femininas', 'Subcategoria fictícia'),
    ('teste-moda', 'Roupas masculinas', 'teste-roupas-masculinas', 'Subcategoria fictícia'),
    ('teste-beleza', 'Perfumes', 'teste-perfumes', 'Subcategoria fictícia'),
    ('teste-esporte', 'Bicicletas', 'teste-bicicletas', 'Subcategoria fictícia'),
    ('teste-livros', 'Literatura', 'teste-literatura', 'Subcategoria fictícia'),
    ('teste-games', 'Consoles', 'teste-consoles', 'Subcategoria fictícia'),
    ('teste-brinquedos', 'Bonecos e jogos', 'teste-bonecos-jogos', 'Subcategoria fictícia'),
    ('teste-veiculos-pecas', 'Peças automotivas', 'teste-pecas-automotivas', 'Subcategoria fictícia'),
    ('teste-servicos-digitais', 'Design', 'teste-design', 'Subcategoria fictícia'),
    ('teste-servicos-digitais', 'Programação', 'teste-programacao', 'Subcategoria fictícia')
) AS v(slug_pai, nome, slug, descricao)
INNER JOIN public.marketplace_categoria p ON p.slug = v.slug_pai
ON CONFLICT (slug) DO UPDATE
SET nome = EXCLUDED.nome,
    descricao = EXCLUDED.descricao,
    ativo = TRUE,
    id_categoria_pai = EXCLUDED.id_categoria_pai;


INSERT INTO public.admcore_pessoa (
    nome,
    nome_social,
    cpfcnpj,
    tipo_pessoa,
    data_nascimento,
    rg,
    data_cadastro
)
SELECT
    (ARRAY['Ana','Bruno','Carla','Daniel','Eduarda','Felipe','Gabriela','Henrique','Isabela','João','Larissa','Marcos','Natália','Otávio','Patrícia','Rafael','Sofia','Thiago','Vanessa','William'])
        [((g - 1) % 20)::INTEGER + 1]
    || ' ' ||
    (ARRAY['Silva','Santos','Oliveira','Souza','Pereira','Costa','Rodrigues','Almeida','Nascimento','Lima','Araújo','Fernandes','Carvalho','Gomes','Martins','Barbosa','Ribeiro','Rocha','Dias','Mendes'])
        [((g - 1) % 20)::INTEGER + 1]
    || ' Teste ' || g AS nome,
    CASE WHEN g % 11 = 0 THEN 'Social Teste ' || g ELSE NULL END AS nome_social,
    CASE
        WHEN g % 5 = 0 THEN LPAD((90000000000000::BIGINT + g)::TEXT, 14, '0')
        ELSE LPAD((70000000000::BIGINT + g)::TEXT, 11, '0')
    END AS cpfcnpj,
    CASE WHEN g % 5 = 0 THEN 'J' ELSE 'F' END AS tipo_pessoa,
    DATE '1965-01-01' + ((g % 15000)::INTEGER) AS data_nascimento,
    'RGTESTE' || LPAD(g::TEXT, 12, '0') AS rg,
    CURRENT_TIMESTAMP - ((g % 720)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM generate_series(1, (SELECT qtd_clientes FROM tmp_mass_config)) AS gs(g)
ON CONFLICT (cpfcnpj) DO NOTHING;


INSERT INTO public.admcore_cliente (
    id_pessoa,
    apelido,
    foto_url,
    biografia,
    status_cliente,
    data_cadastro
)
SELECT
    p.id_pessoa,
    'user_teste_' || LPAD(g::TEXT, 8, '0') AS apelido,
    'https://cdn.exemplo.local/usuarios/user_teste_' || LPAD(g::TEXT, 8, '0') || '.jpg' AS foto_url,
    'Biografia fictícia do usuário de teste ' || g AS biografia,
    CASE
        WHEN g % 200 = 0 THEN 'bloqueado'
        WHEN g % 97 = 0 THEN 'inativo'
        ELSE 'ativo'
    END AS status_cliente,
    CURRENT_TIMESTAMP - ((g % 720)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM generate_series(1, (SELECT qtd_clientes FROM tmp_mass_config)) AS gs(g)
INNER JOIN public.admcore_pessoa p
    ON p.cpfcnpj = CASE
        WHEN g % 5 = 0 THEN LPAD((90000000000000::BIGINT + g)::TEXT, 14, '0')
        ELSE LPAD((70000000000::BIGINT + g)::TEXT, 11, '0')
    END
ON CONFLICT DO NOTHING;

CREATE TEMP TABLE tmp_fake_cliente ON COMMIT DROP AS
SELECT
    c.id_cliente,
    c.id_pessoa,
    c.apelido,
    ROW_NUMBER() OVER (ORDER BY c.id_cliente)::INTEGER AS rn
FROM public.admcore_cliente c
INNER JOIN public.admcore_pessoa p ON p.id_pessoa = c.id_pessoa
WHERE c.apelido LIKE 'user_teste_%';

CREATE INDEX tmp_fake_cliente_rn_idx ON tmp_fake_cliente (rn);
CREATE INDEX tmp_fake_cliente_id_idx ON tmp_fake_cliente (id_cliente);

CREATE TEMP TABLE tmp_fake_cliente_total ON COMMIT DROP AS
SELECT COUNT(*)::INTEGER AS total FROM tmp_fake_cliente;

DO $$
BEGIN
    IF (SELECT total FROM tmp_fake_cliente_total) = 0 THEN
        RAISE EXCEPTION 'Nenhum cliente fictício encontrado. Verifique a carga de admcore_pessoa/admcore_cliente.';
    END IF;
END $$;


INSERT INTO public.cauth_login (
    id_cliente,
    email,
    senha_hash,
    email_verificado,
    ultimo_login,
    status_login,
    data_cadastro
)
SELECT
    c.id_cliente,
    c.apelido || '@teste.local' AS email,
    '$2b$12$fakehash.' || MD5(c.id_cliente::TEXT || c.apelido) AS senha_hash,
    (c.rn % 4 <> 0) AS email_verificado,
    CURRENT_TIMESTAMP - ((c.rn % 120)::TEXT || ' days')::INTERVAL AS ultimo_login,
    CASE
        WHEN c.rn % 200 = 0 THEN 'bloqueado'
        WHEN c.rn % 19 = 0 THEN 'pendente'
        ELSE 'ativo'
    END AS status_login,
    CURRENT_TIMESTAMP - ((c.rn % 720)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM tmp_fake_cliente c
ON CONFLICT DO NOTHING;


INSERT INTO public.admcore_clientecontato (
    id_cliente,
    tipo_contato,
    valor,
    principal,
    verificado,
    data_cadastro
)
SELECT
    c.id_cliente,
    'email',
    c.apelido || '@teste.local',
    TRUE,
    TRUE,
    CURRENT_TIMESTAMP - ((c.rn % 720)::TEXT || ' days')::INTERVAL
FROM tmp_fake_cliente c
ON CONFLICT (id_cliente, tipo_contato, valor) DO NOTHING;

INSERT INTO public.admcore_clientecontato (
    id_cliente,
    tipo_contato,
    valor,
    principal,
    verificado,
    data_cadastro
)
SELECT
    c.id_cliente,
    'celular',
    '+55' || LPAD(((85000000000::BIGINT + c.rn))::TEXT, 11, '0'),
    TRUE,
    (c.rn % 3 <> 0),
    CURRENT_TIMESTAMP - ((c.rn % 720)::TEXT || ' days')::INTERVAL
FROM tmp_fake_cliente c
ON CONFLICT (id_cliente, tipo_contato, valor) DO NOTHING;

INSERT INTO public.admcore_clientecontato (
    id_cliente,
    tipo_contato,
    valor,
    principal,
    verificado,
    data_cadastro
)
SELECT
    c.id_cliente,
    'whatsapp',
    '+55' || LPAD(((86000000000::BIGINT + c.rn))::TEXT, 11, '0'),
    FALSE,
    (c.rn % 4 <> 0),
    CURRENT_TIMESTAMP - ((c.rn % 720)::TEXT || ' days')::INTERVAL
FROM tmp_fake_cliente c
WHERE c.rn % 2 = 0
ON CONFLICT (id_cliente, tipo_contato, valor) DO NOTHING;


INSERT INTO public.admcore_endereco (
    id_cliente,
    tipo_endereco,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    estado,
    cep,
    ponto_referencia,
    principal,
    data_cadastro
)
SELECT
    c.id_cliente,
    'residencial',
    'Rua Teste ' || c.rn,
    ((c.rn % 999) + 1)::TEXT,
    CASE WHEN c.rn % 4 = 0 THEN 'Apto ' || ((c.rn % 200) + 1) ELSE NULL END,
    (ARRAY['Centro','Aldeota','Meireles','Boa Viagem','Savassi','Pinheiros','Copacabana','Asa Sul','Batista Campos','Jardins'])
        [((c.rn - 1) % 10)::INTEGER + 1],
    (ARRAY['Fortaleza','Recife','Belo Horizonte','São Paulo','Rio de Janeiro','Brasília','Belém','Curitiba','Salvador','Goiânia'])
        [((c.rn - 1) % 10)::INTEGER + 1],
    (ARRAY['CE','PE','MG','SP','RJ','DF','PA','PR','BA','GO'])
        [((c.rn - 1) % 10)::INTEGER + 1],
    LPAD((60000000 + c.rn % 9000000)::TEXT, 8, '0'),
    'Ponto de referência teste ' || c.rn,
    TRUE,
    CURRENT_TIMESTAMP - ((c.rn % 720)::TEXT || ' days')::INTERVAL
FROM tmp_fake_cliente c
WHERE NOT EXISTS (
    SELECT 1
    FROM public.admcore_endereco e
    WHERE e.id_cliente = c.id_cliente
      AND e.tipo_endereco = 'residencial'
      AND e.principal = TRUE
      AND e.logradouro = 'Rua Teste ' || c.rn
);

INSERT INTO public.admcore_endereco (
    id_cliente,
    tipo_endereco,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    estado,
    cep,
    ponto_referencia,
    principal,
    data_cadastro
)
SELECT
    c.id_cliente,
    'entrega',
    'Avenida Entrega Teste ' || c.rn,
    ((c.rn % 1200) + 10)::TEXT,
    NULL,
    'Bairro Entrega ' || ((c.rn % 50) + 1),
    (ARRAY['Fortaleza','Recife','Belo Horizonte','São Paulo','Rio de Janeiro','Brasília','Belém','Curitiba','Salvador','Goiânia'])
        [((c.rn + 3) % 10)::INTEGER + 1],
    (ARRAY['CE','PE','MG','SP','RJ','DF','PA','PR','BA','GO'])
        [((c.rn + 3) % 10)::INTEGER + 1],
    LPAD((61000000 + c.rn % 9000000)::TEXT, 8, '0'),
    NULL,
    FALSE,
    CURRENT_TIMESTAMP - ((c.rn % 720)::TEXT || ' days')::INTERVAL
FROM tmp_fake_cliente c
WHERE c.rn % 3 = 0
  AND NOT EXISTS (
    SELECT 1
    FROM public.admcore_endereco e
    WHERE e.id_cliente = c.id_cliente
      AND e.tipo_endereco = 'entrega'
      AND e.logradouro = 'Avenida Entrega Teste ' || c.rn
);

CREATE TEMP TABLE tmp_fake_endereco_principal ON COMMIT DROP AS
SELECT DISTINCT ON (e.id_cliente)
    e.id_cliente,
    e.id_endereco
FROM public.admcore_endereco e
INNER JOIN tmp_fake_cliente c ON c.id_cliente = e.id_cliente
ORDER BY e.id_cliente, e.principal DESC, e.id_endereco;

CREATE INDEX tmp_fake_endereco_principal_cliente_idx ON tmp_fake_endereco_principal (id_cliente);


CREATE TEMP TABLE tmp_fake_categoria ON COMMIT DROP AS
SELECT
    id_categoria,
    slug,
    ROW_NUMBER() OVER (ORDER BY id_categoria)::INTEGER AS rn
FROM public.marketplace_categoria
WHERE slug LIKE 'teste-%'
  AND ativo = TRUE;

CREATE INDEX tmp_fake_categoria_rn_idx ON tmp_fake_categoria (rn);

CREATE TEMP TABLE tmp_fake_categoria_total ON COMMIT DROP AS
SELECT COUNT(*)::INTEGER AS total FROM tmp_fake_categoria;

CREATE TEMP TABLE tmp_fake_bandeira ON COMMIT DROP AS
SELECT
    id_bandeira_cartao,
    codigo,
    ROW_NUMBER() OVER (ORDER BY id_bandeira_cartao)::INTEGER AS rn
FROM public.financeiro_bandeiracartao
WHERE codigo IN ('visa','mastercard','elo','amex','hipercard','diners','discover','outros');

CREATE INDEX tmp_fake_bandeira_rn_idx ON tmp_fake_bandeira (rn);

CREATE TEMP TABLE tmp_fake_bandeira_total ON COMMIT DROP AS
SELECT COUNT(*)::INTEGER AS total FROM tmp_fake_bandeira;


INSERT INTO public.marketplace_anuncio (
    id_vendedor,
    id_categoria,
    id_endereco_origem,
    titulo,
    descricao,
    condicao_produto,
    preco,
    quantidade,
    aceita_proposta,
    tipo_entrega,
    status_anuncio,
    visualizacoes,
    data_publicacao,
    data_expiracao,
    data_cadastro
)
SELECT
    c.id_cliente AS id_vendedor,
    cat.id_categoria,
    ep.id_endereco AS id_endereco_origem,
    'Produto fictício marketplace #' || LPAD(g::TEXT, 8, '0') AS titulo,
    'Descrição fictícia do anúncio ' || g || '. Produto usado para testes de listagem, busca, compra, venda e moderação.' AS descricao,
    CASE
        WHEN g % 7 = 0 THEN 'novo'
        WHEN g % 3 = 0 THEN 'seminovo'
        ELSE 'usado'
    END AS condicao_produto,
    ROUND((20 + ((g * 37) % 15000) + ((g % 99) / 100.0))::NUMERIC, 2) AS preco,
    ((g % 5) + 1)::INTEGER AS quantidade,
    (g % 4 <> 0) AS aceita_proposta,
    CASE
        WHEN g % 11 = 0 THEN 'digital'
        WHEN g % 7 = 0 THEN 'transportadora'
        WHEN g % 5 = 0 THEN 'correios'
        WHEN g % 3 = 0 THEN 'retirada'
        ELSE 'combinar'
    END AS tipo_entrega,
    CASE
        WHEN g % 41 = 0 THEN 'bloqueado'
        WHEN g % 37 = 0 THEN 'expirado'
        WHEN g % 29 = 0 THEN 'cancelado'
        WHEN g % 23 = 0 THEN 'vendido'
        WHEN g % 17 = 0 THEN 'pausado'
        WHEN g % 13 = 0 THEN 'rascunho'
        ELSE 'ativo'
    END AS status_anuncio,
    ((g * 13) % 5000)::INTEGER AS visualizacoes,
    CASE WHEN g % 13 = 0 THEN NULL ELSE CURRENT_TIMESTAMP - ((g % 365)::TEXT || ' days')::INTERVAL END AS data_publicacao,
    CASE WHEN g % 13 = 0 THEN NULL ELSE CURRENT_TIMESTAMP + (((90 - (g % 60))::TEXT) || ' days')::INTERVAL END AS data_expiracao,
    CURRENT_TIMESTAMP - ((g % 365)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM generate_series(1, (SELECT qtd_anuncios FROM tmp_mass_config)) AS gs(g)
CROSS JOIN tmp_fake_cliente_total ct
CROSS JOIN tmp_fake_categoria_total cat_total
INNER JOIN tmp_fake_cliente c
    ON c.rn = (((g - 1) % ct.total)::INTEGER + 1)
INNER JOIN tmp_fake_categoria cat
    ON cat.rn = (((g - 1) % cat_total.total)::INTEGER + 1)
LEFT JOIN tmp_fake_endereco_principal ep
    ON ep.id_cliente = c.id_cliente
WHERE NOT EXISTS (
    SELECT 1
    FROM public.marketplace_anuncio a
    WHERE a.id_vendedor = c.id_cliente
      AND a.titulo = 'Produto fictício marketplace #' || LPAD(g::TEXT, 8, '0')
);

CREATE TEMP TABLE tmp_fake_anuncio ON COMMIT DROP AS
SELECT
    a.id_anuncio,
    a.id_vendedor,
    c.rn AS vendedor_rn,
    a.id_categoria,
    a.id_endereco_origem,
    a.titulo,
    a.preco,
    a.status_anuncio,
    ROW_NUMBER() OVER (ORDER BY a.id_anuncio)::INTEGER AS rn
FROM public.marketplace_anuncio a
INNER JOIN tmp_fake_cliente c ON c.id_cliente = a.id_vendedor
WHERE a.titulo LIKE 'Produto fictício marketplace #%';

CREATE INDEX tmp_fake_anuncio_rn_idx ON tmp_fake_anuncio (rn);
CREATE INDEX tmp_fake_anuncio_id_idx ON tmp_fake_anuncio (id_anuncio);
CREATE INDEX tmp_fake_anuncio_vendedor_idx ON tmp_fake_anuncio (id_vendedor);

CREATE TEMP TABLE tmp_fake_anuncio_total ON COMMIT DROP AS
SELECT COUNT(*)::INTEGER AS total FROM tmp_fake_anuncio;

DO $$
BEGIN
    IF (SELECT total FROM tmp_fake_anuncio_total) = 0 THEN
        RAISE EXCEPTION 'Nenhum anúncio fictício encontrado. Verifique a carga de marketplace_anuncio.';
    END IF;
END $$;


INSERT INTO public.marketplace_anunciofoto (
    id_anuncio,
    url_foto,
    ordem,
    principal,
    data_cadastro
)
SELECT
    a.id_anuncio,
    'https://cdn.exemplo.local/anuncios/' || a.id_anuncio || '/foto_' || f.ordem || '.jpg' AS url_foto,
    f.ordem,
    (f.ordem = 1) AS principal,
    CURRENT_TIMESTAMP - ((a.rn % 365)::TEXT || ' days')::INTERVAL
FROM tmp_fake_anuncio a
CROSS JOIN generate_series(1, (SELECT fotos_por_anuncio FROM tmp_mass_config)) AS f(ordem)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.marketplace_anunciofoto af
    WHERE af.id_anuncio = a.id_anuncio
      AND af.url_foto = 'https://cdn.exemplo.local/anuncios/' || a.id_anuncio || '/foto_' || f.ordem || '.jpg'
);


INSERT INTO public.marketplace_anuncioatributo (
    id_anuncio,
    chave,
    valor,
    data_cadastro
)
SELECT
    a.id_anuncio,
    atributo.chave,
    atributo.valor,
    CURRENT_TIMESTAMP - ((a.rn % 365)::TEXT || ' days')::INTERVAL
FROM tmp_fake_anuncio a
CROSS JOIN LATERAL (
    VALUES
    ('marca', (ARRAY['Samsung','Apple','LG','Sony','Dell','Lenovo','Nike','Adidas','Genérico','Philips']) [((a.rn - 1) % 10)::INTEGER + 1]),
    ('cor', (ARRAY['preto','branco','azul','vermelho','cinza','verde','amarelo','marrom']) [((a.rn - 1) % 8)::INTEGER + 1]),
    ('estado_conservacao', (ARRAY['excelente','bom','regular','com marcas de uso']) [((a.rn - 1) % 4)::INTEGER + 1]),
    ('garantia', CASE WHEN a.rn % 5 = 0 THEN 'sim' ELSE 'não' END)
) AS atributo(chave, valor)
ON CONFLICT (id_anuncio, chave) DO NOTHING;


INSERT INTO public.marketplace_favorito (
    id_cliente,
    id_anuncio,
    data_cadastro
)
SELECT
    comprador.id_cliente,
    a.id_anuncio,
    CURRENT_TIMESTAMP - ((g % 180)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM generate_series(1, (SELECT qtd_favoritos FROM tmp_mass_config)) AS gs(g)
CROSS JOIN tmp_fake_cliente_total ct
CROSS JOIN tmp_fake_anuncio_total at
INNER JOIN tmp_fake_anuncio a
    ON a.rn = (((g * 53) % at.total)::INTEGER + 1)
INNER JOIN tmp_fake_cliente comprador
    ON comprador.rn = CASE
        WHEN (((g * 37) % ct.total)::INTEGER + 1) = a.vendedor_rn
            THEN ((a.vendedor_rn % ct.total) + 1)
        ELSE (((g * 37) % ct.total)::INTEGER + 1)
    END
WHERE comprador.id_cliente <> a.id_vendedor
ON CONFLICT (id_cliente, id_anuncio) DO NOTHING;


INSERT INTO public.marketplace_conversa (
    id_anuncio,
    id_comprador,
    id_vendedor,
    status_conversa,
    data_cadastro
)
SELECT
    a.id_anuncio,
    comprador.id_cliente,
    a.id_vendedor,
    CASE
        WHEN g % 31 = 0 THEN 'bloqueada'
        WHEN g % 9 = 0 THEN 'arquivada'
        ELSE 'aberta'
    END AS status_conversa,
    CURRENT_TIMESTAMP - ((g % 240)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM generate_series(1, (SELECT qtd_conversas FROM tmp_mass_config)) AS gs(g)
CROSS JOIN tmp_fake_cliente_total ct
CROSS JOIN tmp_fake_anuncio_total at
INNER JOIN tmp_fake_anuncio a
    ON a.rn = (((g * 29) % at.total)::INTEGER + 1)
INNER JOIN tmp_fake_cliente comprador
    ON comprador.rn = CASE
        WHEN (((g * 31) % ct.total)::INTEGER + 1) = a.vendedor_rn
            THEN ((a.vendedor_rn % ct.total) + 1)
        ELSE (((g * 31) % ct.total)::INTEGER + 1)
    END
WHERE comprador.id_cliente <> a.id_vendedor
ON CONFLICT (id_anuncio, id_comprador) DO NOTHING;

CREATE TEMP TABLE tmp_fake_conversa ON COMMIT DROP AS
SELECT
    cv.id_conversa,
    cv.id_anuncio,
    cv.id_comprador,
    cv.id_vendedor,
    ROW_NUMBER() OVER (ORDER BY cv.id_conversa)::INTEGER AS rn
FROM public.marketplace_conversa cv
INNER JOIN tmp_fake_anuncio a ON a.id_anuncio = cv.id_anuncio;

CREATE INDEX tmp_fake_conversa_rn_idx ON tmp_fake_conversa (rn);
CREATE INDEX tmp_fake_conversa_id_idx ON tmp_fake_conversa (id_conversa);


INSERT INTO public.marketplace_mensagem (
    id_conversa,
    id_remetente,
    mensagem,
    lida,
    data_leitura,
    data_cadastro
)
SELECT
    cv.id_conversa,
    CASE WHEN m.n % 2 = 0 THEN cv.id_vendedor ELSE cv.id_comprador END AS id_remetente,
    'Mensagem fictícia ' || m.n || ' da conversa ' || cv.id_conversa || ' - lote TESTE_MASSA_V1' AS mensagem,
    (m.n % 5 <> 0) AS lida,
    CASE WHEN m.n % 5 <> 0 THEN CURRENT_TIMESTAMP - (((cv.rn + m.n) % 200)::TEXT || ' days')::INTERVAL ELSE NULL END AS data_leitura,
    CURRENT_TIMESTAMP - (((cv.rn + m.n) % 240)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM tmp_fake_conversa cv
CROSS JOIN generate_series(1, (SELECT mensagens_por_conversa FROM tmp_mass_config)) AS m(n)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.marketplace_mensagem msg
    WHERE msg.id_conversa = cv.id_conversa
      AND msg.mensagem = 'Mensagem fictícia ' || m.n || ' da conversa ' || cv.id_conversa || ' - lote TESTE_MASSA_V1'
);


INSERT INTO public.marketplace_carrinho (
    id_cliente,
    status_carrinho,
    data_cadastro
)
SELECT
    c.id_cliente,
    CASE
        WHEN c.rn % 17 = 0 THEN 'cancelado'
        WHEN c.rn % 11 = 0 THEN 'abandonado'
        WHEN c.rn % 7 = 0 THEN 'convertido'
        ELSE 'ativo'
    END AS status_carrinho,
    CURRENT_TIMESTAMP - ((c.rn % 90)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM tmp_fake_cliente c
WHERE NOT EXISTS (
    SELECT 1
    FROM public.marketplace_carrinho car
    WHERE car.id_cliente = c.id_cliente
      AND car.data_cadastro >= CURRENT_TIMESTAMP - INTERVAL '1000 days'
);

CREATE TEMP TABLE tmp_fake_carrinho ON COMMIT DROP AS
SELECT
    car.id_carrinho,
    car.id_cliente,
    c.rn AS cliente_rn,
    ROW_NUMBER() OVER (ORDER BY car.id_carrinho)::INTEGER AS rn
FROM public.marketplace_carrinho car
INNER JOIN tmp_fake_cliente c ON c.id_cliente = car.id_cliente;

CREATE INDEX tmp_fake_carrinho_rn_idx ON tmp_fake_carrinho (rn);


INSERT INTO public.marketplace_carrinhoitem (
    id_carrinho,
    id_anuncio,
    quantidade,
    data_cadastro
)
SELECT
    car.id_carrinho,
    a.id_anuncio,
    ((car.rn + item.n) % 2 + 1)::INTEGER AS quantidade,
    CURRENT_TIMESTAMP - (((car.rn + item.n) % 90)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM tmp_fake_carrinho car
CROSS JOIN generate_series(1, (SELECT itens_por_carrinho FROM tmp_mass_config)) AS item(n)
CROSS JOIN tmp_fake_anuncio_total at
INNER JOIN tmp_fake_anuncio a
    ON a.rn = (((car.rn * 19 + item.n * 23) % at.total)::INTEGER + 1)
WHERE a.id_vendedor <> car.id_cliente
ON CONFLICT (id_carrinho, id_anuncio) DO NOTHING;


CREATE TEMP TABLE tmp_pedido_seed ON COMMIT DROP AS
SELECT
    g::INTEGER AS seq,
    'PED-TESTE-' || LPAD(g::TEXT, 9, '0') AS codigo_pedido,
    a.id_anuncio,
    a.titulo,
    a.preco,
    a.id_vendedor,
    comprador.id_cliente AS id_comprador,
    e.id_endereco AS id_endereco_entrega,
    ((g % 2) + 1)::INTEGER AS quantidade,
    CASE
        WHEN g % 67 = 0 THEN 'disputa'
        WHEN g % 47 = 0 THEN 'reembolsado'
        WHEN g % 31 = 0 THEN 'cancelado'
        WHEN g % 13 = 0 THEN 'concluido'
        WHEN g % 11 = 0 THEN 'entregue'
        WHEN g % 7 = 0 THEN 'enviado'
        WHEN g % 5 = 0 THEN 'em_preparacao'
        WHEN g % 3 = 0 THEN 'pago'
        WHEN g % 2 = 0 THEN 'aguardando_pagamento'
        ELSE 'criado'
    END AS status_pedido,
    ROUND((a.preco * ((g % 2) + 1))::NUMERIC, 2) AS subtotal,
    CASE WHEN a.preco > 100 THEN 0 ELSE ROUND((12 + (g % 35))::NUMERIC, 2) END AS valor_frete,
    CASE WHEN g % 10 = 0 THEN ROUND((a.preco * 0.05)::NUMERIC, 2) ELSE 0::NUMERIC END AS valor_desconto,
    ROUND((a.preco * ((g % 2) + 1) * 0.10)::NUMERIC, 2) AS valor_taxa_plataforma,
    CURRENT_TIMESTAMP - ((g % 300)::TEXT || ' days')::INTERVAL AS data_pedido
FROM generate_series(1, (SELECT qtd_pedidos FROM tmp_mass_config)) AS gs(g)
CROSS JOIN tmp_fake_cliente_total ct
CROSS JOIN tmp_fake_anuncio_total at
INNER JOIN tmp_fake_anuncio a
    ON a.rn = (((g * 17) % at.total)::INTEGER + 1)
INNER JOIN tmp_fake_cliente comprador
    ON comprador.rn = CASE
        WHEN (((a.vendedor_rn + g * 13) % ct.total)::INTEGER + 1) = a.vendedor_rn
            THEN ((a.vendedor_rn % ct.total) + 1)
        ELSE (((a.vendedor_rn + g * 13) % ct.total)::INTEGER + 1)
    END
LEFT JOIN tmp_fake_endereco_principal e ON e.id_cliente = comprador.id_cliente
WHERE comprador.id_cliente <> a.id_vendedor;

CREATE INDEX tmp_pedido_seed_codigo_idx ON tmp_pedido_seed (codigo_pedido);
CREATE INDEX tmp_pedido_seed_anuncio_idx ON tmp_pedido_seed (id_anuncio);

INSERT INTO public.marketplace_pedido (
    codigo_pedido,
    id_comprador,
    id_vendedor,
    id_endereco_entrega,
    status_pedido,
    subtotal,
    valor_frete,
    valor_desconto,
    valor_taxa_plataforma,
    total,
    observacao,
    data_pedido
)
SELECT
    s.codigo_pedido,
    s.id_comprador,
    s.id_vendedor,
    s.id_endereco_entrega,
    s.status_pedido,
    s.subtotal,
    s.valor_frete,
    s.valor_desconto,
    s.valor_taxa_plataforma,
    ROUND((s.subtotal + s.valor_frete - s.valor_desconto + s.valor_taxa_plataforma)::NUMERIC, 2) AS total,
    'Pedido fictício gerado pela massa TESTE_MASSA_V1' AS observacao,
    s.data_pedido
FROM tmp_pedido_seed s
ON CONFLICT (codigo_pedido) DO NOTHING;

CREATE TEMP TABLE tmp_fake_pedido ON COMMIT DROP AS
SELECT
    p.id_pedido,
    p.codigo_pedido,
    p.id_comprador,
    p.id_vendedor,
    p.id_endereco_entrega,
    p.status_pedido,
    p.subtotal,
    p.valor_frete,
    p.valor_desconto,
    p.valor_taxa_plataforma,
    p.total,
    p.data_pedido,
    s.id_anuncio,
    s.titulo,
    s.preco,
    s.quantidade,
    ROW_NUMBER() OVER (ORDER BY p.id_pedido)::INTEGER AS rn
FROM public.marketplace_pedido p
INNER JOIN tmp_pedido_seed s ON s.codigo_pedido = p.codigo_pedido;

CREATE INDEX tmp_fake_pedido_id_idx ON tmp_fake_pedido (id_pedido);
CREATE INDEX tmp_fake_pedido_rn_idx ON tmp_fake_pedido (rn);


INSERT INTO public.marketplace_pedidoitem (
    id_pedido,
    id_anuncio,
    titulo_snapshot,
    preco_unitario_snapshot,
    quantidade,
    total_item,
    data_cadastro
)
SELECT
    p.id_pedido,
    p.id_anuncio,
    p.titulo,
    p.preco,
    p.quantidade,
    ROUND((p.preco * p.quantidade)::NUMERIC, 2) AS total_item,
    CURRENT_TIMESTAMP - ((p.rn % 300)::TEXT || ' days')::INTERVAL
FROM tmp_fake_pedido p
ON CONFLICT (id_pedido, id_anuncio) DO NOTHING;


INSERT INTO public.marketplace_cupom (
    codigo,
    tipo_desconto,
    valor_desconto,
    valor_minimo_pedido,
    data_inicio,
    data_validade,
    ativo,
    data_cadastro
)
SELECT
    'CUPOMTESTE' || LPAD(g::TEXT, 4, '0') AS codigo,
    CASE WHEN g % 2 = 0 THEN 'percentual' ELSE 'valor_fixo' END AS tipo_desconto,
    CASE WHEN g % 2 = 0 THEN (5 + (g % 30))::NUMERIC ELSE (10 + (g % 80))::NUMERIC END AS valor_desconto,
    (50 + (g % 400))::NUMERIC AS valor_minimo_pedido,
    CURRENT_TIMESTAMP - INTERVAL '30 days',
    CURRENT_TIMESTAMP + ((30 + g)::TEXT || ' days')::INTERVAL,
    TRUE,
    CURRENT_TIMESTAMP
FROM generate_series(1, 80) AS gs(g)
ON CONFLICT (codigo) DO UPDATE
SET tipo_desconto = EXCLUDED.tipo_desconto,
    valor_desconto = EXCLUDED.valor_desconto,
    valor_minimo_pedido = EXCLUDED.valor_minimo_pedido,
    data_validade = EXCLUDED.data_validade,
    ativo = TRUE;

CREATE TEMP TABLE tmp_fake_cupom ON COMMIT DROP AS
SELECT
    id_cupom,
    ROW_NUMBER() OVER (ORDER BY id_cupom)::INTEGER AS rn
FROM public.marketplace_cupom
WHERE codigo LIKE 'CUPOMTESTE%';

CREATE INDEX tmp_fake_cupom_rn_idx ON tmp_fake_cupom (rn);

CREATE TEMP TABLE tmp_fake_cupom_total ON COMMIT DROP AS
SELECT COUNT(*)::INTEGER AS total FROM tmp_fake_cupom;

INSERT INTO public.marketplace_pedidocupom (
    id_pedido,
    id_cupom,
    valor_desconto_aplicado,
    data_cadastro
)
SELECT
    p.id_pedido,
    cup.id_cupom,
    p.valor_desconto,
    p.data_pedido
FROM tmp_fake_pedido p
CROSS JOIN tmp_fake_cupom_total ct
INNER JOIN tmp_fake_cupom cup
    ON cup.rn = (((p.rn - 1) % ct.total)::INTEGER + 1)
WHERE p.valor_desconto > 0
ON CONFLICT (id_pedido, id_cupom) DO NOTHING;


INSERT INTO public.financeiro_cartaocliente (
    id_cliente,
    id_bandeira_cartao,
    gateway,
    token_gateway,
    titular_nome,
    ultimos4,
    mes_expiracao,
    ano_expiracao,
    principal,
    status_cartao,
    data_cadastro
)
SELECT
    c.id_cliente,
    b.id_bandeira_cartao,
    'gateway_teste' AS gateway,
    'tok_teste_' || MD5('cartao_cliente_' || c.id_cliente::TEXT || '_1') AS token_gateway,
    p.nome AS titular_nome,
    LPAD(((c.rn * 17) % 10000)::TEXT, 4, '0') AS ultimos4,
    ((c.rn % 12) + 1)::SMALLINT AS mes_expiracao,
    (2028 + (c.rn % 6))::SMALLINT AS ano_expiracao,
    TRUE AS principal,
    CASE WHEN c.rn % 97 = 0 THEN 'bloqueado' ELSE 'ativo' END AS status_cartao,
    CURRENT_TIMESTAMP - ((c.rn % 500)::TEXT || ' days')::INTERVAL
FROM tmp_fake_cliente c
INNER JOIN public.admcore_pessoa p ON p.id_pessoa = c.id_pessoa
CROSS JOIN tmp_fake_bandeira_total bt
INNER JOIN tmp_fake_bandeira b ON b.rn = (((c.rn - 1) % bt.total)::INTEGER + 1)
WHERE c.rn % 10 <> 0
ON CONFLICT (gateway, token_gateway) DO NOTHING;

INSERT INTO public.financeiro_cartaocliente (
    id_cliente,
    id_bandeira_cartao,
    gateway,
    token_gateway,
    titular_nome,
    ultimos4,
    mes_expiracao,
    ano_expiracao,
    principal,
    status_cartao,
    data_cadastro
)
SELECT
    c.id_cliente,
    b.id_bandeira_cartao,
    'gateway_teste' AS gateway,
    'tok_teste_' || MD5('cartao_cliente_' || c.id_cliente::TEXT || '_2') AS token_gateway,
    p.nome AS titular_nome,
    LPAD(((c.rn * 23) % 10000)::TEXT, 4, '0') AS ultimos4,
    (((c.rn + 4) % 12) + 1)::SMALLINT AS mes_expiracao,
    (2029 + (c.rn % 6))::SMALLINT AS ano_expiracao,
    FALSE AS principal,
    'ativo' AS status_cartao,
    CURRENT_TIMESTAMP - ((c.rn % 500)::TEXT || ' days')::INTERVAL
FROM tmp_fake_cliente c
INNER JOIN public.admcore_pessoa p ON p.id_pessoa = c.id_pessoa
CROSS JOIN tmp_fake_bandeira_total bt
INNER JOIN tmp_fake_bandeira b ON b.rn = (((c.rn + 3) % bt.total)::INTEGER + 1)
WHERE c.rn % 4 = 0
ON CONFLICT (gateway, token_gateway) DO NOTHING;

CREATE TEMP TABLE tmp_fake_cartao ON COMMIT DROP AS
SELECT DISTINCT ON (fc.id_cliente)
    fc.id_cliente,
    fc.id_cartao,
    fc.id_bandeira_cartao,
    b.codigo AS bandeira_codigo,
    fc.ultimos4
FROM public.financeiro_cartaocliente fc
INNER JOIN tmp_fake_cliente c ON c.id_cliente = fc.id_cliente
INNER JOIN public.financeiro_bandeiracartao b ON b.id_bandeira_cartao = fc.id_bandeira_cartao
WHERE fc.status_cartao = 'ativo'
ORDER BY fc.id_cliente, fc.principal DESC, fc.id_cartao;

CREATE INDEX tmp_fake_cartao_cliente_idx ON tmp_fake_cartao (id_cliente);


INSERT INTO public.financeiro_recebedor (
    id_cliente,
    gateway,
    gateway_recebedor_id,
    tipo_recebedor,
    chave_pix_mascarada,
    banco_codigo,
    agencia,
    conta_ultimos4,
    status_recebedor,
    data_cadastro
)
SELECT DISTINCT
    a.id_vendedor AS id_cliente,
    'gateway_teste' AS gateway,
    'rec_teste_' || a.id_vendedor AS gateway_recebedor_id,
    CASE WHEN a.id_vendedor % 5 = 0 THEN 'pessoa_juridica' ELSE 'pessoa_fisica' END AS tipo_recebedor,
    '***' || RIGHT(a.id_vendedor::TEXT, 4) || '@pix.teste' AS chave_pix_mascarada,
    LPAD(((a.id_vendedor % 999) + 1)::TEXT, 3, '0') AS banco_codigo,
    LPAD(((a.id_vendedor % 9999) + 1)::TEXT, 4, '0') AS agencia,
    LPAD(((a.id_vendedor * 7) % 10000)::TEXT, 4, '0') AS conta_ultimos4,
    CASE
        WHEN a.id_vendedor % 97 = 0 THEN 'bloqueado'
        WHEN a.id_vendedor % 53 = 0 THEN 'pendente'
        ELSE 'ativo'
    END AS status_recebedor,
    CURRENT_TIMESTAMP - ((a.id_vendedor % 400)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM tmp_fake_anuncio a
ON CONFLICT DO NOTHING;

CREATE TEMP TABLE tmp_fake_recebedor ON COMMIT DROP AS
SELECT r.id_recebedor, r.id_cliente
FROM public.financeiro_recebedor r
INNER JOIN tmp_fake_cliente c ON c.id_cliente = r.id_cliente
WHERE r.gateway = 'gateway_teste';

CREATE INDEX tmp_fake_recebedor_cliente_idx ON tmp_fake_recebedor (id_cliente);


INSERT INTO public.financeiro_pagamento (
    id_pedido,
    id_forma_pagamento,
    id_cartao,
    valor,
    parcelas,
    status_pagamento,
    gateway,
    gateway_pagamento_id,
    nsu,
    tid,
    codigo_autorizacao,
    cartao_bandeira_snapshot,
    cartao_ultimos4_snapshot,
    data_autorizacao,
    data_captura,
    data_pagamento
)
SELECT
    p.id_pedido,
    fp.id_forma_pagamento,
    CASE WHEN fp.codigo IN ('cartao_credito', 'cartao_debito') THEN cart.id_cartao ELSE NULL END AS id_cartao,
    p.total AS valor,
    CASE WHEN fp.codigo = 'cartao_credito' THEN ((p.rn % 6) + 1)::SMALLINT ELSE 1::SMALLINT END AS parcelas,
    CASE
        WHEN p.status_pedido IN ('cancelado') THEN 'cancelado'
        WHEN p.status_pedido IN ('reembolsado') THEN 'estornado'
        WHEN p.status_pedido IN ('criado', 'aguardando_pagamento') THEN 'pendente'
        WHEN p.status_pedido IN ('disputa') THEN 'autorizado'
        ELSE 'aprovado'
    END AS status_pagamento,
    'gateway_teste' AS gateway,
    'pay_teste_' || p.codigo_pedido AS gateway_pagamento_id,
    'NSU' || LPAD(p.rn::TEXT, 10, '0') AS nsu,
    'TID' || LPAD(p.rn::TEXT, 10, '0') AS tid,
    'AUTH' || LPAD((p.rn % 999999)::TEXT, 6, '0') AS codigo_autorizacao,
    CASE WHEN fp.codigo IN ('cartao_credito', 'cartao_debito') THEN cart.bandeira_codigo ELSE NULL END AS cartao_bandeira_snapshot,
    CASE WHEN fp.codigo IN ('cartao_credito', 'cartao_debito') THEN cart.ultimos4 ELSE NULL END AS cartao_ultimos4_snapshot,
    CASE WHEN p.status_pedido NOT IN ('criado', 'aguardando_pagamento') THEN p.data_pedido + INTERVAL '10 minutes' ELSE NULL END AS data_autorizacao,
    CASE WHEN p.status_pedido IN ('pago', 'em_preparacao', 'enviado', 'entregue', 'concluido') THEN p.data_pedido + INTERVAL '20 minutes' ELSE NULL END AS data_captura,
    p.data_pedido + INTERVAL '5 minutes' AS data_pagamento
FROM tmp_fake_pedido p
LEFT JOIN tmp_fake_cartao cart ON cart.id_cliente = p.id_comprador
INNER JOIN public.financeiro_formapagamento fp ON fp.codigo = CASE
    WHEN (p.rn % 5 IN (0, 1)) AND cart.id_cartao IS NOT NULL THEN 'cartao_credito'
    WHEN (p.rn % 5 = 2) AND cart.id_cartao IS NOT NULL THEN 'cartao_debito'
    WHEN p.rn % 5 = 3 THEN 'boleto'
    WHEN p.rn % 5 = 4 THEN 'saldo_carteira'
    ELSE 'pix'
END
WHERE NOT EXISTS (
    SELECT 1
    FROM public.financeiro_pagamento pg
    WHERE pg.id_pedido = p.id_pedido
);

CREATE TEMP TABLE tmp_fake_pagamento ON COMMIT DROP AS
SELECT
    pg.id_pagamento,
    pg.id_pedido,
    pg.status_pagamento,
    pg.valor,
    ROW_NUMBER() OVER (ORDER BY pg.id_pagamento)::INTEGER AS rn
FROM public.financeiro_pagamento pg
INNER JOIN tmp_fake_pedido p ON p.id_pedido = pg.id_pedido;

CREATE INDEX tmp_fake_pagamento_id_idx ON tmp_fake_pagamento (id_pagamento);
CREATE INDEX tmp_fake_pagamento_pedido_idx ON tmp_fake_pagamento (id_pedido);


INSERT INTO public.financeiro_pagamentoevento (
    id_pagamento,
    status_pagamento,
    mensagem,
    payload_gateway,
    data_cadastro
)
SELECT
    pg.id_pagamento,
    ev.status_pagamento,
    ev.mensagem,
    jsonb_build_object(
        'lote', 'TESTE_MASSA_V1',
        'gateway', 'gateway_teste',
        'id_pagamento', pg.id_pagamento,
        'status', ev.status_pagamento
    ) AS payload_gateway,
    CURRENT_TIMESTAMP - (((pg.rn + ev.ordem) % 300)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM tmp_fake_pagamento pg
CROSS JOIN LATERAL (
    VALUES
    (1, 'pendente', 'Pagamento criado no gateway fictício'),
    (2, CASE WHEN pg.status_pagamento IN ('autorizado','aprovado','estornado') THEN 'autorizado' ELSE pg.status_pagamento END, 'Pagamento autorizado ou mantido no status atual'),
    (3, pg.status_pagamento, 'Status final fictício do pagamento')
) AS ev(ordem, status_pagamento, mensagem)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.financeiro_pagamentoevento pe
    WHERE pe.id_pagamento = pg.id_pagamento
      AND pe.status_pagamento = ev.status_pagamento
      AND pe.mensagem = ev.mensagem
);


INSERT INTO public.financeiro_repasse (
    id_pedido,
    id_vendedor,
    id_recebedor,
    valor_bruto,
    valor_taxa_plataforma,
    valor_liquido,
    status_repasse,
    data_prevista,
    data_pagamento,
    gateway_repasse_id,
    data_cadastro
)
SELECT
    p.id_pedido,
    p.id_vendedor,
    r.id_recebedor,
    p.subtotal AS valor_bruto,
    p.valor_taxa_plataforma,
    GREATEST(0, p.subtotal - p.valor_taxa_plataforma) AS valor_liquido,
    CASE
        WHEN p.status_pedido IN ('cancelado','reembolsado') THEN 'cancelado'
        WHEN p.status_pedido IN ('concluido') THEN 'pago'
        WHEN p.status_pedido IN ('entregue') THEN 'liberado'
        WHEN p.status_pedido IN ('disputa') THEN 'bloqueado'
        ELSE 'pendente'
    END AS status_repasse,
    p.data_pedido + INTERVAL '15 days' AS data_prevista,
    CASE WHEN p.status_pedido = 'concluido' THEN p.data_pedido + INTERVAL '16 days' ELSE NULL END AS data_pagamento,
    'rep_teste_' || p.codigo_pedido AS gateway_repasse_id,
    p.data_pedido
FROM tmp_fake_pedido p
LEFT JOIN tmp_fake_recebedor r ON r.id_cliente = p.id_vendedor
WHERE p.status_pedido NOT IN ('criado', 'aguardando_pagamento')
  AND NOT EXISTS (
    SELECT 1
    FROM public.financeiro_repasse rep
    WHERE rep.id_pedido = p.id_pedido
);


INSERT INTO public.logistica_envio (
    id_pedido,
    id_endereco_origem,
    id_endereco_destino,
    modalidade_envio,
    transportadora,
    codigo_rastreamento,
    valor_frete,
    status_envio,
    data_postagem,
    data_entrega,
    data_cadastro
)
SELECT
    p.id_pedido,
    a.id_endereco_origem,
    p.id_endereco_entrega,
    CASE
        WHEN p.rn % 11 = 0 THEN 'digital'
        WHEN p.rn % 7 = 0 THEN 'transportadora'
        WHEN p.rn % 5 = 0 THEN 'correios'
        WHEN p.rn % 3 = 0 THEN 'retirada'
        ELSE 'combinar'
    END AS modalidade_envio,
    CASE
        WHEN p.rn % 7 = 0 THEN 'Transportadora Teste'
        WHEN p.rn % 5 = 0 THEN 'Correios Teste'
        ELSE NULL
    END AS transportadora,
    CASE WHEN p.status_pedido IN ('enviado','entregue','concluido') THEN 'BRTESTE' || LPAD(p.rn::TEXT, 12, '0') ELSE NULL END AS codigo_rastreamento,
    p.valor_frete,
    CASE
        WHEN p.status_pedido IN ('cancelado','reembolsado') THEN 'cancelado'
        WHEN p.status_pedido IN ('concluido','entregue') THEN 'entregue'
        WHEN p.status_pedido IN ('enviado') THEN 'em_transito'
        WHEN p.status_pedido IN ('em_preparacao','pago','disputa') THEN 'preparando'
        ELSE 'pendente'
    END AS status_envio,
    CASE WHEN p.status_pedido IN ('enviado','entregue','concluido') THEN p.data_pedido + INTERVAL '2 days' ELSE NULL END AS data_postagem,
    CASE WHEN p.status_pedido IN ('entregue','concluido') THEN p.data_pedido + INTERVAL '7 days' ELSE NULL END AS data_entrega,
    p.data_pedido
FROM tmp_fake_pedido p
LEFT JOIN tmp_fake_anuncio a ON a.id_anuncio = p.id_anuncio
WHERE NOT EXISTS (
    SELECT 1
    FROM public.logistica_envio e
    WHERE e.id_pedido = p.id_pedido
)
ON CONFLICT (id_pedido) DO NOTHING;

CREATE TEMP TABLE tmp_fake_envio ON COMMIT DROP AS
SELECT
    e.id_envio,
    e.id_pedido,
    e.status_envio,
    ROW_NUMBER() OVER (ORDER BY e.id_envio)::INTEGER AS rn
FROM public.logistica_envio e
INNER JOIN tmp_fake_pedido p ON p.id_pedido = e.id_pedido;

CREATE INDEX tmp_fake_envio_id_idx ON tmp_fake_envio (id_envio);
CREATE INDEX tmp_fake_envio_pedido_idx ON tmp_fake_envio (id_pedido);


INSERT INTO public.marketplace_avaliacao (
    id_pedido,
    id_avaliador,
    id_avaliado,
    papel_avaliado,
    nota,
    comentario,
    data_avaliacao
)
SELECT
    p.id_pedido,
    p.id_comprador AS id_avaliador,
    p.id_vendedor AS id_avaliado,
    'vendedor' AS papel_avaliado,
    ((p.rn % 5) + 1)::SMALLINT AS nota,
    'Avaliação fictícia do comprador para o vendedor no pedido ' || p.codigo_pedido,
    p.data_pedido + INTERVAL '10 days'
FROM tmp_fake_pedido p
WHERE p.status_pedido IN ('entregue', 'concluido')
ON CONFLICT (id_pedido, id_avaliador, id_avaliado) DO NOTHING;

INSERT INTO public.marketplace_avaliacao (
    id_pedido,
    id_avaliador,
    id_avaliado,
    papel_avaliado,
    nota,
    comentario,
    data_avaliacao
)
SELECT
    p.id_pedido,
    p.id_vendedor AS id_avaliador,
    p.id_comprador AS id_avaliado,
    'comprador' AS papel_avaliado,
    (((p.rn + 2) % 5) + 1)::SMALLINT AS nota,
    'Avaliação fictícia do vendedor para o comprador no pedido ' || p.codigo_pedido,
    p.data_pedido + INTERVAL '11 days'
FROM tmp_fake_pedido p
WHERE p.status_pedido IN ('entregue', 'concluido')
ON CONFLICT (id_pedido, id_avaliador, id_avaliado) DO NOTHING;


INSERT INTO public.marketplace_denuncia (
    id_denunciante,
    id_cliente_denunciado,
    id_anuncio,
    motivo,
    descricao,
    status_denuncia,
    data_cadastro
)
SELECT
    denunciante.id_cliente AS id_denunciante,
    a.id_vendedor AS id_cliente_denunciado,
    a.id_anuncio,
    CASE
        WHEN g % 6 = 0 THEN 'produto_proibido'
        WHEN g % 5 = 0 THEN 'golpe'
        WHEN g % 4 = 0 THEN 'spam'
        WHEN g % 3 = 0 THEN 'ofensa'
        WHEN g % 2 = 0 THEN 'fraude'
        ELSE 'outro'
    END AS motivo,
    'Denúncia fictícia para teste de moderação #' || g AS descricao,
    CASE
        WHEN g % 13 = 0 THEN 'encerrada'
        WHEN g % 11 = 0 THEN 'improcedente'
        WHEN g % 7 = 0 THEN 'procedente'
        WHEN g % 3 = 0 THEN 'em_analise'
        ELSE 'aberta'
    END AS status_denuncia,
    CURRENT_TIMESTAMP - ((g % 180)::TEXT || ' days')::INTERVAL AS data_cadastro
FROM generate_series(1, (SELECT qtd_denuncias FROM tmp_mass_config)) AS gs(g)
CROSS JOIN tmp_fake_cliente_total ct
CROSS JOIN tmp_fake_anuncio_total at
INNER JOIN tmp_fake_anuncio a
    ON a.rn = (((g * 43) % at.total)::INTEGER + 1)
INNER JOIN tmp_fake_cliente denunciante
    ON denunciante.rn = CASE
        WHEN (((g * 47) % ct.total)::INTEGER + 1) = a.vendedor_rn
            THEN ((a.vendedor_rn % ct.total) + 1)
        ELSE (((g * 47) % ct.total)::INTEGER + 1)
    END
WHERE denunciante.id_cliente <> a.id_vendedor
  AND NOT EXISTS (
    SELECT 1
    FROM public.marketplace_denuncia d
    WHERE d.id_denunciante = denunciante.id_cliente
      AND d.id_anuncio = a.id_anuncio
      AND d.descricao = 'Denúncia fictícia para teste de moderação #' || g
);


INSERT INTO public.history_historico_status_anuncio (
    id_anuncio,
    status_anterior,
    status_novo,
    id_cliente_responsavel,
    observacao,
    data_cadastro
)
SELECT
    a.id_anuncio,
    NULL,
    'rascunho',
    a.id_vendedor,
    'Criação fictícia do anúncio - TESTE_MASSA_V1',
    CURRENT_TIMESTAMP - ((a.rn % 365)::TEXT || ' days')::INTERVAL
FROM tmp_fake_anuncio a
WHERE NOT EXISTS (
    SELECT 1 FROM public.history_historico_status_anuncio h
    WHERE h.id_anuncio = a.id_anuncio
      AND h.observacao = 'Criação fictícia do anúncio - TESTE_MASSA_V1'
);

INSERT INTO public.history_historico_status_anuncio (
    id_anuncio,
    status_anterior,
    status_novo,
    id_cliente_responsavel,
    observacao,
    data_cadastro
)
SELECT
    a.id_anuncio,
    'rascunho',
    a.status_anuncio,
    a.id_vendedor,
    'Publicação/alteração fictícia do anúncio - TESTE_MASSA_V1',
    CURRENT_TIMESTAMP - ((a.rn % 300)::TEXT || ' days')::INTERVAL
FROM tmp_fake_anuncio a
WHERE a.status_anuncio <> 'rascunho'
  AND NOT EXISTS (
    SELECT 1 FROM public.history_historico_status_anuncio h
    WHERE h.id_anuncio = a.id_anuncio
      AND h.observacao = 'Publicação/alteração fictícia do anúncio - TESTE_MASSA_V1'
);


INSERT INTO public.history_historico_status_pedido (
    id_pedido,
    status_anterior,
    status_novo,
    id_cliente_responsavel,
    observacao,
    data_cadastro
)
SELECT
    p.id_pedido,
    NULL,
    'criado',
    p.id_comprador,
    'Criação fictícia do pedido - TESTE_MASSA_V1',
    p.data_pedido
FROM tmp_fake_pedido p
WHERE NOT EXISTS (
    SELECT 1 FROM public.history_historico_status_pedido h
    WHERE h.id_pedido = p.id_pedido
      AND h.observacao = 'Criação fictícia do pedido - TESTE_MASSA_V1'
);

INSERT INTO public.history_historico_status_pedido (
    id_pedido,
    status_anterior,
    status_novo,
    id_cliente_responsavel,
    observacao,
    data_cadastro
)
SELECT
    p.id_pedido,
    'criado',
    p.status_pedido,
    p.id_vendedor,
    'Evolução fictícia do pedido - TESTE_MASSA_V1',
    p.data_pedido + INTERVAL '1 hour'
FROM tmp_fake_pedido p
WHERE p.status_pedido <> 'criado'
  AND NOT EXISTS (
    SELECT 1 FROM public.history_historico_status_pedido h
    WHERE h.id_pedido = p.id_pedido
      AND h.observacao = 'Evolução fictícia do pedido - TESTE_MASSA_V1'
);


INSERT INTO public.history_historico_status_pagamento (
    id_pagamento,
    status_anterior,
    status_novo,
    observacao,
    data_cadastro
)
SELECT
    pg.id_pagamento,
    NULL,
    'pendente',
    'Criação fictícia do pagamento - TESTE_MASSA_V1',
    CURRENT_TIMESTAMP - ((pg.rn % 300)::TEXT || ' days')::INTERVAL
FROM tmp_fake_pagamento pg
WHERE NOT EXISTS (
    SELECT 1 FROM public.history_historico_status_pagamento h
    WHERE h.id_pagamento = pg.id_pagamento
      AND h.observacao = 'Criação fictícia do pagamento - TESTE_MASSA_V1'
);

INSERT INTO public.history_historico_status_pagamento (
    id_pagamento,
    status_anterior,
    status_novo,
    observacao,
    data_cadastro
)
SELECT
    pg.id_pagamento,
    'pendente',
    pg.status_pagamento,
    'Evolução fictícia do pagamento - TESTE_MASSA_V1',
    CURRENT_TIMESTAMP - ((pg.rn % 280)::TEXT || ' days')::INTERVAL
FROM tmp_fake_pagamento pg
WHERE pg.status_pagamento <> 'pendente'
  AND NOT EXISTS (
    SELECT 1 FROM public.history_historico_status_pagamento h
    WHERE h.id_pagamento = pg.id_pagamento
      AND h.observacao = 'Evolução fictícia do pagamento - TESTE_MASSA_V1'
);


INSERT INTO public.history_historico_status_envio (
    id_envio,
    status_anterior,
    status_novo,
    observacao,
    data_cadastro
)
SELECT
    e.id_envio,
    NULL,
    'pendente',
    'Criação fictícia do envio - TESTE_MASSA_V1',
    CURRENT_TIMESTAMP - ((e.rn % 280)::TEXT || ' days')::INTERVAL
FROM tmp_fake_envio e
WHERE NOT EXISTS (
    SELECT 1 FROM public.history_historico_status_envio h
    WHERE h.id_envio = e.id_envio
      AND h.observacao = 'Criação fictícia do envio - TESTE_MASSA_V1'
);

INSERT INTO public.history_historico_status_envio (
    id_envio,
    status_anterior,
    status_novo,
    observacao,
    data_cadastro
)
SELECT
    e.id_envio,
    'pendente',
    e.status_envio,
    'Evolução fictícia do envio - TESTE_MASSA_V1',
    CURRENT_TIMESTAMP - ((e.rn % 260)::TEXT || ' days')::INTERVAL
FROM tmp_fake_envio e
WHERE e.status_envio <> 'pendente'
  AND NOT EXISTS (
    SELECT 1 FROM public.history_historico_status_envio h
    WHERE h.id_envio = e.id_envio
      AND h.observacao = 'Evolução fictícia do envio - TESTE_MASSA_V1'
);


INSERT INTO public.history_auditoria (
    tabela,
    id_registro,
    acao,
    id_cliente_responsavel,
    dados_anteriores,
    dados_novos,
    ip_origem,
    user_agent,
    data_cadastro
)
SELECT
    'marketplace_anuncio' AS tabela,
    a.id_anuncio AS id_registro,
    CASE WHEN a.rn % 3 = 0 THEN 'update' ELSE 'insert' END AS acao,
    a.id_vendedor AS id_cliente_responsavel,
    CASE WHEN a.rn % 3 = 0 THEN jsonb_build_object('status_anuncio', 'rascunho') ELSE NULL END AS dados_anteriores,
    jsonb_build_object('status_anuncio', a.status_anuncio, 'titulo', a.titulo, 'lote', 'TESTE_MASSA_V1') AS dados_novos,
    '192.168.' || ((a.rn % 255)::TEXT) || '.' || (((a.rn * 3) % 255)::TEXT) AS ip_origem,
    'Mozilla/5.0 Teste Massa Ficticia' AS user_agent,
    CURRENT_TIMESTAMP - ((a.rn % 300)::TEXT || ' days')::INTERVAL
FROM tmp_fake_anuncio a
WHERE a.rn <= 100000
  AND NOT EXISTS (
    SELECT 1
    FROM public.history_auditoria aud
    WHERE aud.tabela = 'marketplace_anuncio'
      AND aud.id_registro = a.id_anuncio
      AND aud.dados_novos ->> 'lote' = 'TESTE_MASSA_V1'
);

INSERT INTO public.history_auditoria (
    tabela,
    id_registro,
    acao,
    id_cliente_responsavel,
    dados_anteriores,
    dados_novos,
    ip_origem,
    user_agent,
    data_cadastro
)
SELECT
    'marketplace_pedido' AS tabela,
    p.id_pedido AS id_registro,
    CASE WHEN p.status_pedido = 'criado' THEN 'insert' ELSE 'update' END AS acao,
    p.id_comprador AS id_cliente_responsavel,
    CASE WHEN p.status_pedido <> 'criado' THEN jsonb_build_object('status_pedido', 'criado') ELSE NULL END AS dados_anteriores,
    jsonb_build_object('status_pedido', p.status_pedido, 'total', p.total, 'lote', 'TESTE_MASSA_V1') AS dados_novos,
    '10.0.' || ((p.rn % 255)::TEXT) || '.' || (((p.rn * 5) % 255)::TEXT) AS ip_origem,
    'Mozilla/5.0 Teste Massa Ficticia' AS user_agent,
    p.data_pedido
FROM tmp_fake_pedido p
WHERE p.rn <= 100000
  AND NOT EXISTS (
    SELECT 1
    FROM public.history_auditoria aud
    WHERE aud.tabela = 'marketplace_pedido'
      AND aud.id_registro = p.id_pedido
      AND aud.dados_novos ->> 'lote' = 'TESTE_MASSA_V1'
);


UPDATE public.marketplace_anuncio a
SET visualizacoes = a.visualizacoes + ((a.id_anuncio % 200)::INTEGER)
WHERE a.titulo LIKE 'Produto fictício marketplace #%'
  AND a.status_anuncio = 'ativo';


CREATE TEMP TABLE tmp_resumo_massa ON COMMIT DROP AS
SELECT 'admcore_pessoa' AS tabela, COUNT(*)::BIGINT AS total FROM public.admcore_pessoa p WHERE p.rg LIKE 'RGTESTE%'
UNION ALL
SELECT 'admcore_cliente', COUNT(*) FROM public.admcore_cliente c WHERE c.apelido LIKE 'user_teste_%'
UNION ALL
SELECT 'cauth_login', COUNT(*) FROM public.cauth_login l WHERE l.email LIKE 'user_teste_%@teste.local'
UNION ALL
SELECT 'admcore_clientecontato', COUNT(*) FROM public.admcore_clientecontato cc INNER JOIN tmp_fake_cliente c ON c.id_cliente = cc.id_cliente
UNION ALL
SELECT 'admcore_endereco', COUNT(*) FROM public.admcore_endereco e INNER JOIN tmp_fake_cliente c ON c.id_cliente = e.id_cliente
UNION ALL
SELECT 'marketplace_categoria', COUNT(*) FROM public.marketplace_categoria WHERE slug LIKE 'teste-%'
UNION ALL
SELECT 'marketplace_anuncio', COUNT(*) FROM public.marketplace_anuncio WHERE titulo LIKE 'Produto fictício marketplace #%'
UNION ALL
SELECT 'marketplace_anunciofoto', COUNT(*) FROM public.marketplace_anunciofoto af INNER JOIN tmp_fake_anuncio a ON a.id_anuncio = af.id_anuncio
UNION ALL
SELECT 'marketplace_anuncioatributo', COUNT(*) FROM public.marketplace_anuncioatributo aa INNER JOIN tmp_fake_anuncio a ON a.id_anuncio = aa.id_anuncio
UNION ALL
SELECT 'marketplace_favorito', COUNT(*) FROM public.marketplace_favorito f INNER JOIN tmp_fake_anuncio a ON a.id_anuncio = f.id_anuncio
UNION ALL
SELECT 'marketplace_conversa', COUNT(*) FROM public.marketplace_conversa cv INNER JOIN tmp_fake_anuncio a ON a.id_anuncio = cv.id_anuncio
UNION ALL
SELECT 'marketplace_mensagem', COUNT(*) FROM public.marketplace_mensagem m WHERE m.mensagem LIKE '%TESTE_MASSA_V1%'
UNION ALL
SELECT 'marketplace_carrinho', COUNT(*) FROM public.marketplace_carrinho car INNER JOIN tmp_fake_cliente c ON c.id_cliente = car.id_cliente
UNION ALL
SELECT 'marketplace_carrinhoitem', COUNT(*) FROM public.marketplace_carrinhoitem ci INNER JOIN tmp_fake_carrinho car ON car.id_carrinho = ci.id_carrinho
UNION ALL
SELECT 'marketplace_pedido', COUNT(*) FROM public.marketplace_pedido p WHERE p.codigo_pedido LIKE 'PED-TESTE-%'
UNION ALL
SELECT 'marketplace_pedidoitem', COUNT(*) FROM public.marketplace_pedidoitem pi INNER JOIN tmp_fake_pedido p ON p.id_pedido = pi.id_pedido
UNION ALL
SELECT 'marketplace_cupom', COUNT(*) FROM public.marketplace_cupom WHERE codigo LIKE 'CUPOMTESTE%'
UNION ALL
SELECT 'marketplace_pedidocupom', COUNT(*) FROM public.marketplace_pedidocupom pc INNER JOIN tmp_fake_pedido p ON p.id_pedido = pc.id_pedido
UNION ALL
SELECT 'financeiro_cartaocliente', COUNT(*) FROM public.financeiro_cartaocliente fc INNER JOIN tmp_fake_cliente c ON c.id_cliente = fc.id_cliente
UNION ALL
SELECT 'financeiro_recebedor', COUNT(*) FROM public.financeiro_recebedor r INNER JOIN tmp_fake_cliente c ON c.id_cliente = r.id_cliente
UNION ALL
SELECT 'financeiro_pagamento', COUNT(*) FROM public.financeiro_pagamento pg INNER JOIN tmp_fake_pedido p ON p.id_pedido = pg.id_pedido
UNION ALL
SELECT 'financeiro_pagamentoevento', COUNT(*) FROM public.financeiro_pagamentoevento pe INNER JOIN tmp_fake_pagamento pg ON pg.id_pagamento = pe.id_pagamento
UNION ALL
SELECT 'financeiro_repasse', COUNT(*) FROM public.financeiro_repasse r INNER JOIN tmp_fake_pedido p ON p.id_pedido = r.id_pedido
UNION ALL
SELECT 'logistica_envio', COUNT(*) FROM public.logistica_envio e INNER JOIN tmp_fake_pedido p ON p.id_pedido = e.id_pedido
UNION ALL
SELECT 'marketplace_avaliacao', COUNT(*) FROM public.marketplace_avaliacao av INNER JOIN tmp_fake_pedido p ON p.id_pedido = av.id_pedido
UNION ALL
SELECT 'marketplace_denuncia', COUNT(*) FROM public.marketplace_denuncia d WHERE d.descricao LIKE 'Denúncia fictícia%'
UNION ALL
SELECT 'history_historico_status_anuncio', COUNT(*) FROM public.history_historico_status_anuncio h WHERE h.observacao LIKE '%TESTE_MASSA_V1%'
UNION ALL
SELECT 'history_historico_status_pedido', COUNT(*) FROM public.history_historico_status_pedido h WHERE h.observacao LIKE '%TESTE_MASSA_V1%'
UNION ALL
SELECT 'history_historico_status_pagamento', COUNT(*) FROM public.history_historico_status_pagamento h WHERE h.observacao LIKE '%TESTE_MASSA_V1%'
UNION ALL
SELECT 'history_historico_status_envio', COUNT(*) FROM public.history_historico_status_envio h WHERE h.observacao LIKE '%TESTE_MASSA_V1%'
UNION ALL
SELECT 'history_auditoria', COUNT(*) FROM public.history_auditoria h WHERE h.dados_novos ->> 'lote' = 'TESTE_MASSA_V1';


COMMIT;
