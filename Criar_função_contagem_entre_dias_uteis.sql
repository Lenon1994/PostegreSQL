-- Criar tabela feriados para usar como referencia, serão feriados que serão desconsiderados para contagem de dias uteis entre datas.
CREATE TABLE public.feriados
(
    data date,
    descricao text
);

ALTER TABLE IF EXISTS public.feriados
    OWNER to postgres;

-- Inserir valores na tabela feriados:
--Exemplo:
INSERT INTO public.feriados(
	data, descricao)
	VALUES 
	('2022-12-25', 'Natal'),
	('2023-01-01', 'Confraternização Universal'),
	('2023-04-07', 'Paixão de Cristo'),
	('2023-04-21', 'Tiradentes'),
	('2023-05-01', 'Dia Mundial do Trabalho'),
	('2023-09-07', 'Independência do Brasil'),
	('2023-10-12', 'Nossa Senhora Aparecida'),
	('2023-11-02', 'Finados'),
	('2023-11-15', 'Proclamação da República'),
	('2023-12-25', 'Natal'),
	('2024-01-01', 'Confraternização Universal');


	

-- Criar função para realizar a contagem de dias uteis desconsiderando (Sábados, Domingos e feriados)

CREATE OR REPLACE FUNCTION public.contagem_entre_dias_uteis(IN from_date date,IN to_date date)
    RETURNS bigint
    LANGUAGE 'sql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100
    
AS $BODY$
	select count(d::date) as d
from generate_series(from_date, to_date, '1 day'::interval) d
	where extract('dow' from d) not in (0,6) and
	NOT EXISTS (SELECT data FROM feriados WHERE d::date = data) 
$BODY$;




-- Como usar a função?  

--Exemplo abaixo utilizando uma tabela de teste.

CREATE TABLE public.datas
(
    start_date date,
    end_date date,
);

ALTER TABLE IF EXISTS public.feriados
    OWNER to postgres;


--Inseridos valores na taela
INSERT INTO public.datas(
	start_date, end_date)
	VALUES 
	('2022-12-01','2022-12-31'),
	('2023-01-01','2023-01-31'),
	('2023-02-01','2023-02-28'),
	('2023-03-01','2023-03-31'),
	('2023-04-01','2023-04-30'),
	('2023-05-01','2023-05-31');


--Realizando a consulta utilizando a função desenvolvida

SELECT
   start_date,
   end_date,
   contagem_entre_dias_uteis(start_date,end_date) as resultado
FROM datas





-- Caso precise aprimorar o modelo a nivel de estado ou municipio será necessário acrescentar na tabela feriados essa informação para que seja adicionado essa condição na função.





