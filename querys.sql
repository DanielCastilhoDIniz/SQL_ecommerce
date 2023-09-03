
-- Active: 1692332274730@@127.0.0.1@3306@ecommerce

-- retorna endereços:
SELECT * FROM endereco;

-- retorna categorias:
SELECT * FROM categorias;

-- retorna categorias pai:
SELECT * FROM categorias 
WHERE categoria_pai_id IS NULL;

-- retorna contagem de clientes masculinos e casados :
SELECT COUNT(sex) 
FROM  client 
WHERE `Sex`='Masculino' AND marital_status ='casado';

-- retorna clientes masculinos casados
SELECT cliente_id, occupation  
FROM  client 
WHERE `Sex`='Masculino' AND marital_status ='casado';

-- retorna pedidos em processamento
SELECT pedido_id 
FROM pedidos 
WHERE status_pedido = 'Processando'; 


-- Quantos pedidos foram feitos no total?
SELECT COUNT(pedido_id) as Total_de_Pedidos FROM pedidos;

-- idade dos clientes
SELECT cliente_id, TIMESTAMPDIFF(YEAR, Bdate, CURDATE()) AS idade
FROM client;

-- Quantos pedidos foram feitos por cada cliente?
SELECT cliente_id, COUNT(pedido_id) as total_pedidos
FROM pedidos
GROUP BY cliente_id;

-- Qual é o valor médio por pedido?
SELECT pedido_id, COUNT(item_pedido_id) AS total_itens, ROUND(AVG(quantidade * preco_unitario ),2 ) AS Average_Pedido, SUM(quantidade * preco_unitario ) AS Total_pedido_R$  
FROM  itens_pedido
GROUP BY(pedido_id);

-- retorna valor total de cada pedido;
SELECT pedido_id, COUNT(item_pedido_id) AS total_itens, SUM(quantidade * preco_unitario ) AS Total_pedido_R$  
FROM  itens_pedido
GROUP BY(pedido_id);

-- Quem são os produtos mais pedidos?
SELECT SUM(it.quantidade), p.nome
FROM itens_pedido it
JOIN product p ON p.produto_id =it.produto_id
GROUP BY (p.nome)
ORDER BY SUM(it.quantidade) DESC;

-- dias desde o ultimo pedido do cliente
SELECT cliente_id, DATEDIFF(CURDATE(), MAX(data_pedido)) AS dias_desde_ultimo_pedido
FROM pedidos
GROUP BY cliente_id;


-- Algum vendedor também é fornecedor?
SELECT t.vendedor_id, f.fornecedor_id
FROM terceiro_vendedor t
JOIN fornecedores f ON t.entity_id = f.entity_id;

-- Relação de produtos, fornecedores e estoques:
SELECT p.nome AS nome_produto, 
       f.nome_contato AS nome_fornecedor, 
       e.quantidade AS quantidade_em_estoque
FROM product p
JOIN product_fornecedor pf ON p.produto_id = pf.produto_id
JOIN fornecedores f ON pf.fornecedor_id = f.fornecedor_id
JOIN estoque e ON p.produto_id = e.produto_id;

-- Relação de nomes dos fornecedores e nomes dos produtos:
SELECT f.nome_contato AS nome_fornecedor, 
       p.nome AS nome_produto
FROM fornecedores f
JOIN product_fornecedor pf ON f.fornecedor_id = pf.fornecedor_id
JOIN product p ON pf.produto_id = p.produto_id;

-- valor total do pedido + valor do frete:
SELECT 
    ped.pedido_id, 
    SUM(it.quantidade * prod.preco) + COALESCE(ped.frete, 0) AS valor_total
FROM 
    pedidos ped
JOIN 
    itens_pedido it ON ped.pedido_id = it.pedido_id
JOIN 
    product prod ON it.produto_id = prod.produto_id
GROUP BY 
    ped.pedido_id, 
    ped.frete;


SELECT cliente_id, COUNT(pedido_id) AS total_pedidos
FROM pedidos
GROUP BY cliente_id
HAVING total_pedidos >= 1;


SELECT 
    pr.nome AS Produto,
    pr.preco AS Preço,
    ped.descricao AS Descrição_Pedido,
    ped.data_pedido AS Data_Pedido,
    ped.status_pedido AS Status,
    be.first_name AS Nome_Cliente,
    be.last_name AS Sobrenome_Cliente,
    tv.local AS Local_Vendedor_Terceiro
FROM 
    product_vendedor pv
JOIN product pr ON pv.produto_id = pr.produto_id
JOIN pedidos ped ON pv.vendedor_id = ped.vendedor_terceiro_id
JOIN client cl ON ped.cliente_id = cl.cliente_id
JOIN businessentities be ON be.entity_id = cl.entity_id
JOIN terceiro_vendedor tv ON pv.vendedor_id = tv.vendedor_id
ORDER BY ped.data_pedido DESC;