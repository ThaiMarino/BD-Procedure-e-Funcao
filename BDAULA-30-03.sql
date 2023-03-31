-- 1. 1. Acesse todas as vendas efetuadas, exibindo código do produto 
-- vendido, nome do produto, valor unitário do produto, nome do cliente, data da venda.

SELECT * FROM vendas;

-- QUASE ACERTEI NO INNER JOIN
SELECT * FROM vendas
INNER JOIN ProdutosVendidos
ON ProdutosVendidos.produto_codigoproduto = ProdutosVendidos.vendas_codigovenda
INNER JOIN produto
ON produto.produto_codigoproduto = vendas.produto_codigoproduto
INNER JOIN cliente
ON  cliente.codigocliente = vendas.codigocliente;

SELECT datavenda, descricaoproduto,preco_unitario FROM ProdutosVendidos;


show tables from dbvendasNovo;

-- DÁ PRA CRIAR UMA PROCEDURE PORQUE SAO VARIOS DADOS DE VÁRIOS CLIENTES
-- INNER JOIN COMEÇA SEMPRE PELAS PONTAS
SELECT p.codigoproduto,
p.descricaoproduto,
p.preco_unitario,
c.nomecliente,
v.datavenda
FROM produto p 
INNER JOIN ProdutosVendidos pv 
ON p.codigoproduto = pv.produto_codigoproduto
INNER JOIN vendas v
ON pv.vendas_codigovenda = v.codigovenda
INNER JOIN cliente c
ON v.cliente_codigocliente = c.codigocliente


-- ESTE ESTÁ CERTO
DELIMITER $$
CREATE PROCEDURE venda()
begin
SELECT p.codigoproduto,
p.descricaoproduto,
p.preco_unitario,
c.nomecliente,
v.datavenda
FROM produto p 
INNER JOIN ProdutosVendidos pv 
ON p.codigoproduto = pv.produto_codigoproduto
INNER JOIN vendas v
ON pv.vendas_codigovenda = v.codigovenda
INNER JOIN cliente c
ON v.cliente_codigocliente = c.codigocliente;

end$$
DELIMITER ; 

CALL venda();

-- 2A. Faça uma stored procedure que exiba vendas 
-- efetuadas de determinado produto. 

-- *CONSEGUI*********
-- LEMBRAR DE COLOCAR O PARAMETRO () NO CREATE

DELIMITER $$
CREATE PROCEDURE vendaproduto(cod int)
begin
SELECT pv.vendas_codigovenda,
p.descricaoproduto
FROM vendas v
INNER JOIN ProdutosVendidos pv
ON v.codigovenda = pv.vendas_codigovenda
INNER JOIN produto p
ON pv.produto_codigoproduto = p.codigoproduto
WHERE p.codigoproduto = cod;

end $$
DELIMITER ; 

DROP PROCEDURE vendaproduto;
CALL vendaproduto(2);


-- 2B. Faça uma stored procedure que exiba produtos de uma determinada venda

DELIMITER $$
CREATE PROCEDURE venda_espc(cod_venda int)
begin
SELECT v.codigovenda,
p.codigoproduto
FROM vendas v
INNER JOIN ProdutosVendidos pv
ON v.codigovenda = pv.vendas_codigovenda
INNER JOIN produto p
ON pv.produto_codigoproduto = p.codigoproduto
WHERE v.codigovenda = cod_venda;

end $$
DELIMITER ; 

CALL venda_espc(100);


-- 2C. Implemente o exercício1 criando uma procedure especificando a venda de um cliente
-- **** CONSEGUIII ****
DELIMITER $$
CREATE PROCEDURE venda_cliente(cod_cliente INT)
begin
SELECT 
c.nomecliente,
v.codigovenda,
v.datavenda
FROM cliente c
INNER JOIN vendas v
ON c.codigocliente = v.cliente_codigocliente
WHERE c.codigocliente = cod_cliente;

end$$
DELIMITER ; 
DROP PROCEDURE venda_cliente;
CALL venda_cliente(502);

-- 3. Faça uma função que calcule o valor da venda de
-- determinado produto (função dentro de uma stored procedure)

delimiter &&
create function calc(qt int, val decimal(15,2))
returns decimal(15,2)
No SQL
begin
	return qt * val;
end&&
delimiter ;

-- procedure
delimiter &&
create procedure vendaProd(cod int)
begin
	select p.descricaoproduto, p.preco_unitario, pv.qtde_vendida
    , calc(pv.qtde_vendida, p.preco_unitario) as total
    from produto p
	inner join produtosvendidos pv 
	on p.codigoproduto = pv.produto_codigoproduto
	inner join vendas v 
	on pv.vendas_codigovenda = v.codigovenda
    where p.codigoproduto = cod;
end&&
delimiter ;

call vendaProd(1);

DELIMITER %%
create procedure exibirCalculoVenda(codProduto int)
begin
	declare qtdeTotal int;
    declare valorUnitario decimal(10,2);
    set qtdeTotal = (select sum(qtde_vendida) from produtosvendidos where produto_codigoproduto = codProduto);
    set valorUnitario = (select preco_unitario from produto where codigoproduto = codProduto);
    
	select 
    p.codigoproduto as 'Código produto', 
    p.descricaoproduto as 'Decrição produto', 
    p.preco_unitario as 'Preço unitário:',
    sum(pv.qtde_vendida) as 'Quantia total',
    calcularVendaGenerico(qtdeTotal, valorUnitario) as 'Valor total' 
    from produto p
    inner join produtosvendidos pv on pv.produto_codigoproduto = p.codigoproduto
    where codigoproduto = codProduto;
end %%
DELIMITER 

CALL exibirCalculoVenda(1);


-- Opção 1::
-- Crie uma procedure para atualizar os dados existentes e
-- Crie uma procedure para inserir novos dados
-- ESTÁ ERRADO
DELIMITER %%
CREATE PROCEDURE alterarNome(codProduto int, novaDesc CHAR(45))
begin
	SELECT * FROM produto p;
    update produto
    set descricaoproduto = novaDesc
    where p.codigoproduto = codProduto;

end %%
DELIMITER ; 
DROP PROCEDURE alterarNome;
CALL alterarNome(1, 'Lápis Desenho');


-- Como faço para alterar para dados reais trocando:
-- grupos 1,2,3… por:cadernos/fichários, canetas/lápis, produtos
-- de informática, mochilas/estojos, material de escritório.
DELIMITER %%
CREATE PROCEDURE alterarGrupo(codGrupo int, novaDesc CHAR(45))
begin
    UPDATE grupo_produto gp
    set descricaogrupo_produto = novaDesc
    where gp.idgrupo_produto = codGrupo;
    select * from grupo_produto;
end %%
DELIMITER ; 
DROP PROCEDURE alterarGrupo;


CALL alterarGrupo(5, 'Papel');

-- CRIE UMA PROCEDURE PARA INSERIR NOVOS DADOS
 DELIMITER $$
 CREATE PROCEDURE insertProd(codPro int, novaDesc varchar(45), preco decimal(15,2))
	begin
		insert into DBVendasNovo.produto (codigoproduto, descricaoproduto, preco_unitario)
        values (codPro, novaDesc, preco);
    end;
 $$
 DELIMITER ; 
 
 DROP PROCEDURE insertProd;
 CALL insertProd(7, 'Caneta Stabilo', '15.00');
 
 select * from produto;




-- USEI DE EXEMPLO
-- 5.B)Crie uma procedure para inserir um filme de sua preferência.
-- Filmes: O Dilema das Redes, 2hrs, documentário 
-- O Projeto Adam,1h46,ficção
 DELIMITER $$
 CREATE PROCEDURE insertFilme(id int, nome varchar(200), dur time, gen int)
	begin
		insert into cinema.filme (idFilme, titulo, duracao, genero_idgenero)
        values (id, nome, dur, gen);
    end;
 $$
 DELIMITER ; 
 
 CALL insertFilme(16, 'O Dilema das Redes', '2:00', 7);
 CALL insertFilme(17, 'O Projeto Adam', '1:46', 8);
 
 
 




