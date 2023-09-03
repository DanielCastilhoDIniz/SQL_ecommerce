# SQL_ecommerce
Estudo SQL (mySQL) para o cenário de e-commerce


## Descrição do Projeto Lógico das Tabelas

### **1. Tabela `endereco`:**
Esta tabela armazena as informações detalhadas sobre endereços, sendo usada como referência para outras entidades do sistema que precisam de um endereço.

### **2. Tabela `Usuarios`:**
Armazena informações básicas de cada usuário registrado no sistema. O campo `role` determina o tipo de usuário e suas permissões no sistema (cliente, administrador, vendedor terceirizado, etc.).

### **3. Tabela `BusinessEntities`:**
Uma tabela genérica que contém entidades de negócios, que podem ser pessoas físicas ou jurídicas. Estas entidades podem ter diversos papéis no sistema, como clientes, fornecedores, vendedores ou entidades de frete.

### **4. Tabela `client`:**
Registra detalhes específicos de clientes, com uma ligação para a tabela de usuários (para autenticação e outras funcionalidades) e uma ligação para `BusinessEntities` para dados gerais.

### **5. Tabela `fornecedores`:**
Contém informações sobre os fornecedores. Cada fornecedor tem uma ligação para uma entidade de negócios, onde se encontram informações gerais.

### **6. Tabela `terceiro_vendedor`:**
Armazena detalhes sobre vendedores terceirizados. Eles também são referenciados na tabela `BusinessEntities`.

### **7. Tabela `categorias`:**
Classifica os produtos em diferentes categorias. Suporta uma hierarquia de categorias através da coluna `categoria_pai_id`, permitindo a criação de subcategorias.

### **8. Tabela `local`:**
Define diferentes locais onde os produtos podem ser armazenados ou vendidos.

### **9. Tabela `product`:**
Guarda informações detalhadas sobre cada produto, incluindo nome, preço, descrição, categoria e outros atributos relevantes.

### **10. Tabela `product_vendedor`:**
Estabelece uma relação entre produtos e vendedores terceirizados. Indica quais produtos são vendidos por quais vendedores terceirizados.

### **11. Tabela `product_fornecedor`:**
Mostra a relação entre produtos e seus fornecedores, juntamente com a disponibilidade de cada produto.

### **12. Tabela `estoque`:**
Relaciona os produtos com os locais, rastreando a quantidade disponível de cada produto em um determinado local.

### **13. Tabela `pedidos`:**
Armazena detalhes sobre os pedidos feitos pelos clientes. Inclui informações como status do pedido, cliente que fez o pedido, frete, entre outros.

### **14. Tabela `rastreamento`:**
Registra o status de rastreamento para cada pedido. Mostra a progressão de um pedido, desde a coleta até a entrega.

### **15. Tabela `pagamentos`:**
Guarda detalhes sobre os pagamentos feitos por pedidos. Inclui informações como valor do pagamento, data do pagamento e status do pagamento.

### **16. Tabela `avaliacoes`:**
Registra avaliações feitas por usuários para produtos específicos. Cada avaliação inclui uma classificação e um comentário opcional.

### **17. Tabela `estoque_historico`:**
Oferece um registro histórico das alterações no estoque. Permite rastrear quando um produto foi adicionado ou removido de um local específico.

### **18. Tabela `itens_pedido`:**
Relaciona os produtos com os pedidos. Armazena detalhes como a quantidade de um produto em um pedido específico, o preço unitário e quaisquer descontos aplicados.

---

## Lista de Possíveis Melhorias para o Esquema do Banco de Dados:

1. **Normalização de Endereços**:
   - **Problema**: Múltiplas tabelas podem precisar de informações de endereço.
   - **Solução**: Transformar `endereco` em uma tabela independente e relacioná-la por meio de chaves estrangeiras sempre que um endereço for necessário, evitando redundância e mantendo a consistência.

2. **Segurança de Senhas**:
   - **Problema**: Armazenar senhas, mesmo que criptografadas, pode ser arriscado.
   - **Solução**: Implementar um sistema de hash de senha (como bcrypt) com salto. Além disso, considerar a adição de autenticação de dois fatores para melhorar a segurança.

3. **Informações de Cartão de Pagamento**:
   - **Problema**: Armazenar informações de cartão, mesmo que parciais, pode ser uma preocupação de segurança.
   - **Solução**: Utilizar um serviço de pagamento terceirizado (como Stripe, PayPal etc.) para gerenciar pagamentos e não armazenar detalhes do cartão no banco de dados local.

4. **Avaliações e Comentários**:
   - **Problema**: Avaliações podem ser manipuladas ou spam.
   - **Solução**: Implementar um sistema para verificar e validar avaliações. Além disso, um recurso para os usuários reportarem avaliações inadequadas pode ser útil.

5. **Histórico de Rastreamento**:
   - **Problema**: O rastreamento atualmente só tem um status por vez.
   - **Solução**: Transformar a tabela de rastreamento em um log de eventos para que cada etapa do processo de envio seja registrada sequencialmente.

6. **Logs de Alteração**:
   - **Problema**: As alterações nos registros, especialmente em tabelas sensíveis como `pedidos` ou `estoque`, não são rastreadas.
   - **Solução**: Criar tabelas de logs para manter um histórico de todas as alterações feitas nos registros.

7. **Gestão de Promoções e Cupons**:
   - **Problema**: O esquema atual não tem um sistema para gerenciar descontos além do nível do produto.
   - **Solução**: Adicionar uma tabela para promoções ou cupons que podem ser aplicados aos pedidos.

8. **Suporte para Multi-moedas**:
   - **Problema**: Se o e-commerce operar em várias regiões, o suporte para múltiplas moedas pode ser necessário.
   - **Solução**: Adicionar uma coluna de moeda e considerar uma tabela de taxas de câmbio atualizável.

9. **Imagens dos Produtos**:
   - **Problema**: Atualmente, apenas uma imagem URL é suportada por produto.
   - **Solução**: Criar uma tabela de `imagens_produto` para suportar múltiplas imagens por produto.

10. **Relacionamento entre Vendedor e Produto**:
   - **Problema**: Um vendedor terceirizado pode vender múltiplos produtos. O design atual pode não ser eficiente se um vendedor tiver centenas de produtos.
   - **Solução**: Considerar uma tabela associativa adicional ou otimizar a relação atual.

11. **Melhorias na UI/UX**:
   - Baseado em feedback do usuário, pode-se identificar elementos que são mais requisitados ou campos que poderiam ser adicionados para melhorar a experiência do usuário.

