-- Active: 1692332274730@@127.0.0.1@3306
CREATE DATABASE IF NOT EXISTS
    ecommerce CHARACTER SET = 'utf8mb4';
USE ecommerce;

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `ecomerce`.`endereco`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS endereco (
    endereco_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    rua VARCHAR(255),
    numero VARCHAR(10),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(50),
    CEP CHAR(8),
    pais VARCHAR(100) NOT NULL
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `ecomerce`.`Usuarios`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Usuarios (
    usuario_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL, -- usar uma criptografia forte para a senha
    role ENUM('Cliente', 'Administrador', 'Vendedor Terceirizado', 'Atendimento ao Cliente', 'Logística', 'Marketing', 'Fornecedor') NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `ecomerce`.`BusinessEntities`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BusinessEntities (
    entity_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tipo_pessoa ENUM('Física', 'Jurídica') NOT NULL,
    endereco_id INT,
    first_name VARCHAR(100),
    middle_name VARCHAR(100),
    last_name VARCHAR(100),
    razao_social VARCHAR(255),
    nome_fantasia VARCHAR(255),
    telefone VARCHAR(30),
    email VARCHAR(100),
    cpf_cnpj CHAR(25) UNIQUE,
    website VARCHAR(255),
    tipo_entidade ENUM('Cliente', 'Fornecedor', 'Vendedor', 'Frete Terceirizado') NOT NULL,
    FOREIGN KEY (endereco_id) REFERENCES endereco(endereco_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `ecomerce`.`client`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS client (
    cliente_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    usuario_id INT NOT NULL, -- ligação com a tabela de Usuarios
    occupation VARCHAR(100),
    Bdate DATE,
    Sex VARCHAR(25) NOT NULL,
    marital_status VARCHAR(45) NOT NULL,
    FOREIGN KEY (entity_id) REFERENCES BusinessEntities(entity_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `ecomerce`.`fornecedores`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fornecedores (
    fornecedor_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    -- Informações específicas do fornecedor
    cnpj CHAR(14) UNIQUE,
    nome_contato VARCHAR(255),
    telefone_contato VARCHAR(20),
    FOREIGN KEY (entity_id) REFERENCES BusinessEntities(entity_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `ecomerce`.`terceiro_vendedor`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS terceiro_vendedor (
    vendedor_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    local VARCHAR(255),
    FOREIGN KEY (entity_id) REFERENCES BusinessEntities(entity_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `categorias`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE categorias (
    categoria_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,                 -- Descrição opcional sobre a categoria
    categoria_pai_id INT,           -- ID de referência à categoria principal (para subcategorias)
    imagem_url VARCHAR(255),        -- URL de uma imagem representativa para a categoria (se desejado)
    data_criacao DATE NOT NULL,     -- Data em que a categoria foi criada
    data_atualizacao DATE,          -- Data da última atualização da categoria
    ativo BOOLEAN NOT NULL,         -- Indica se a categoria está ativa ou não
    FOREIGN KEY (categoria_pai_id) REFERENCES categorias(categoria_id)  -- Garante integridade referencial para subcategorias
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Tabela `local`
-- Representa diferentes locais de armazenamento ou vendas.
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS local (
    local_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,      -- Nome do local, como "Armazém Principal"
    descricao TEXT,                  -- Descrição adicional ou detalhes sobre o local
    CONSTRAINT uc_nome UNIQUE (nome) -- Garantindo que não haja dois locais com o mesmo nome
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `produtos`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product (
    produto_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    imagem_url VARCHAR(255),
    categoria_id INT NOT NULL,
    marca VARCHAR(100),
    SKU VARCHAR(100) UNIQUE,
    peso DECIMAL(5,2),
    dimensoes VARCHAR(100),
    data_criacao DATE NOT NULL,
    data_atualizacao DATE,
    ativo BOOLEAN NOT NULL,
    desconto DECIMAL(10,2),
    destaque BOOLEAN,
    avaliacao_media DECIMAL(3,2) DEFAULT 0,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id) ON DELETE CASCADE
);

-- Tabela de Relação Produto-Vendedor Terceirizado
CREATE TABLE IF NOT EXISTS product_vendedor (
    relation_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    vendedor_id INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    FOREIGN KEY (produto_id) REFERENCES product(produto_id) ON DELETE CASCADE,
    FOREIGN KEY (vendedor_id) REFERENCES terceiro_vendedor(vendedor_id) ON DELETE CASCADE
);

-- Tabela de Relação Produto-Fornecedor
CREATE TABLE IF NOT EXISTS product_fornecedor (
    relation_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    fornecedor_id INT NOT NULL,
    status_disponibilidade ENUM('Disponível', 'Indisponível', 'Aguardando Reposição') NOT NULL DEFAULT 'Disponível',
    FOREIGN KEY (produto_id) REFERENCES product(produto_id) ON DELETE CASCADE,
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(fornecedor_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Tabela `estoque`
-- Relaciona produtos com locais, rastreando a quantidade de cada produto em um determinado local.
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS estoque (
    estoque_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    local_id INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    FOREIGN KEY (produto_id) REFERENCES product(produto_id) ON DELETE CASCADE,
    FOREIGN KEY (local_id) REFERENCES local(local_id) ON DELETE CASCADE,
    CONSTRAINT uc_produto_local UNIQUE (produto_id, local_id)  -- Evita entradas duplicadas para o mesmo produto no mesmo local
);
-- ----------------------------------------------------------------------------------------------------------------------
-- Table `pedidos`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedidos (
    pedido_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NULL,    -- Descrição ou observações do pedido
    status_pedido ENUM('Em andamento', 'Processando', 'Enviado', 'Entregue', 'Cancelado') 
        NOT NULL DEFAULT 'Processando',
    
    cliente_id INT NOT NULL,        -- ID do cliente que fez o pedido
    vendedor_terceiro_id INT,       -- ID do terceiro vendedor (se aplicável)
    
    frete_entity_id INT,
    frete DECIMAL(10,2) NULL,       -- Valor do frete
    codigo_rastreamento VARCHAR(50),
    data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Data e hora do pedido
    FOREIGN KEY (cliente_id) 
        REFERENCES client(cliente_id) 
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,
    FOREIGN KEY (vendedor_terceiro_id) 
        REFERENCES terceiro_vendedor(vendedor_id) 
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    FOREIGN KEY (frete_entity_id) 
        REFERENCES BusinessEntities(entity_id) 
        ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table  rastreamento frete
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rastreamento (
    rastreamento_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    status ENUM('Aguardando Coleta', 'Em Trânsito', 'Entregue', 'Atrasado', 'Devolvido', 'Cancelado') NOT NULL DEFAULT 'Aguardando Coleta',
    data_status DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacoes TEXT,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `pagamentos`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE pagamentos (
    pagamento_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    token_pagamento VARCHAR(255) NOT NULL,                -- Token representando os detalhes do pagamento
    tipo_cartao ENUM('Visa', 'MasterCard', 'American Express', 'Discover', 'Outro') NULL, -- Tipo do cartão para referência
    ultimos_quatro_digitos CHAR(4) NULL,                  -- Últimos 4 dígitos do cartão para referência
    data_expiracao CHAR(5) NULL,                          -- Data de expiração para referência no formato MM/AA
    valor DECIMAL(10,2) NOT NULL,                         -- Valor do pagamento
    data_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_pagamento ENUM('Pendente', 'Aprovado', 'Recusado', 'Estornado') NOT NULL DEFAULT 'Pendente',
    INDEX idx_pedido_pagamento (pedido_id),
    CONSTRAINT fk_pagamentos_pedidos
        FOREIGN KEY (pedido_id)
        REFERENCES pedidos (pedido_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Table `avaliacoes`
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS avaliacoes (
    avaliacao_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    usuario_id INT NOT NULL,
    rating DECIMAL(3,2),      -- Avaliação numérica (por exemplo, 4.5 estrelas)
    comentario TEXT,          -- Comentário opcional
    data_avaliacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (produto_id) REFERENCES product(produto_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Tabela de Histórico de Estoque
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS estoque_historico (
    historico_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    estoque_id INT NOT NULL,
    produto_id INT NOT NULL,
    local_id INT NOT NULL,
    quantidade INT,
    data_alteracao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (produto_id) REFERENCES product(produto_id) ON DELETE CASCADE,
    FOREIGN KEY (local_id) REFERENCES local(local_id) ON DELETE CASCADE,
    FOREIGN KEY (estoque_id) REFERENCES estoque(estoque_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------------------------------------------------
-- Tabela de Itens pedidos
-- ----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS itens_pedido (
    item_pedido_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES product(produto_id) ON DELETE CASCADE
);

