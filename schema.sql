CREATE TABLE "cs_user" ( -- tabelas de usuários que são os clientes atendidos
    user_id serial4 NOT NULL, -- código unico do usuário cliente
    "name" varchar(150) NOT NULL, -- nome do usuário cliente
    email varchar(70) NULL, -- email do usuário cliente
    username varchar(255) NULL,-- nome do usuário que acessa o sistema
    CONSTRAINT cs_user_email_key UNIQUE (email), -- restrição de uso único do email
    CONSTRAINT user_pkey PRIMARY KEY (user_id)  -- chave primária
);


CREATE TABLE cs_agents (-- tabela de agentes técnicos que atende os usuários clientes
    agent_id serial4 NOT NULL, -- código único que identifica o agente técnico 
    nome varchar(150) NULL,-- nome do agente técnico
    email varchar NOT NULL,-- email do usuário técnico
    username varchar NOT NULL,-- usuário para acesso aos sistema
    CONSTRAINT agent_id_pk PRIMARY KEY (agent_id) -- chave primária
);


CREATE TABLE cs_events (-- tabela que registra um evento específico que conterá várias ações de diálogo entre cliente e usuário
    event_id serial4 NOT NULL, -- código único que identifica o evento
    descricao varchar NOT NULL,-- descrição do evento. Nela está contida a expicação da solictação de serviço ou problema específico. Ex. Criação de usuário para acesso ao módulo financeiro
    data_abertura timestamptz NOT NULL, -- data da solicitação do evento
    data_baixa timestamptz NULL,-- data de encerramento do evento. Se esta data estiver nula é porque o evento ainda está aberto (em atendimento), caso contrário o evento está encerrado
    status_id int4 NOT NULL, -- situação do evento 0 = novo; 1 = aguardando técnico; 3 - aguardando cliente; 4 - encerrado  
    CONSTRAINT event_id PRIMARY KEY (event_id)
);


CREATE TABLE cs_acoes (  -- tabela que registra o diálogo das ações feitas pelo usuário ou agente
    acao_id serial4 NOT NULL,  -- chave sequnecial única gerada automaticamente que identifica o diálogo da ação pelo usuário ou agente 
    event_id int4 NOT NULL, -- código que liga a ação ao evento, ou seja um evento pode ter N ações feitas por usuários ou agentes  
    descricao text NOT NULL, -- descrição do diálogo. A partir deste texto de conversação deve ser feita a análise de sentimentos
    agent_id int4 NULL,      -- identifica qual agente escreveu a descrição - se estiver preenchido é por que é uma ação de agente então user_id deve ser nulo
    user_id int4 NULL,  -- identifica qual usuário escreveu a descrição - se estiver preenchido indica que a ação foi de um usuário cliente e agent_id deve ester nulo
    data_acao timestamptz NULL,  -- registra a data que a ação foi descrita
    CONSTRAINT acoes_pk PRIMARY KEY (acao_id)
);

CREATE TABLE cs_sentimentos (
    sentimento_id serial4 NOT NULL,
    acao_id int4 NOT NULL,
    sentimento text NOT NULL,
    CONSTRAINT sentimento_id PRIMARY KEY (sentimento_id)

);

CREATE INDEX cs_acoes_event_id_idx ON cs_acoes USING btree (event_id);

-- cs_acoes foreign keys
ALTER TABLE cs_acoes ADD CONSTRAINT cs_acoes_cs_events_fk FOREIGN KEY (event_id) REFERENCES cs_events(event_id);
ALTER TABLE cs_acoes ADD CONSTRAINT cs_acoes_cs_user_fk FOREIGN KEY (user_id) REFERENCES cs_user(user_id);
ALTER TABLE cs_acoes ADD CONSTRAINT cs_acoes_cs_agents_fk FOREIGN KEY (agent_id) REFERENCES cs_agents(agent_id);

ALTER TABLE cs_sentimentos ADD CONSTRAINT cs_sentimentos_cs_acoes_fk FOREIGN KEY (acao_id) REFERENCES cs_acoes(acao_id);

--Observações:
-- Os atributos sobre a análise de sentimentos não forão definidos, pois devem ser a partir de análise da melhor forma. Desta forma, o modelo atual pode ser adaptado para receber novos atributos ou entidades
-- Faz-se necesário especificar a análise de sentimento para cada ação e do evento como todo, de modo que possamos verificar situações de ações isoladas e também de forma geral atribuindo um sentimento ou nota para o evento a partir das análise das ações. 