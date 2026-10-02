CREATE TABLE aeronaves (
    id INT AUTO_INCREMENT PRIMARY KEY,
    modelo VARCHAR(100) NOT NULL,
    codigo_cauda VARCHAR(10) NOT NULL UNIQUE,
    capacidade INT NOT NULL CHECK (capacidade > 0)
);

CREATE TABLE pilotos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    codigo_anac VARCHAR(6) NOT NULL UNIQUE,
    horas_voo INT NOT NULL DEFAULT 0 CHECK (horas_voo >= 0)
);

CREATE TABLE voos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    aeronave_id INT NOT NULL,
    piloto_id INT NOT NULL,
    numero_voo VARCHAR(20) NOT NULL,
    origem VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Agendado' CHECK (status IN ('Agendado', 'Em Voo', 'Concluido', 'Cancelado')),
    CONSTRAINT fk_voos_aeronave FOREIGN KEY (aeronave_id) REFERENCES aeronaves(id),
    CONSTRAINT fk_voos_piloto FOREIGN KEY (piloto_id) REFERENCES pilotos(id)
);

CREATE TABLE passageiros (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE passagens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    voo_id INT NOT NULL,
    passageiro_id INT NOT NULL,
    assento VARCHAR(4) NOT NULL,
    classe VARCHAR(20) NOT NULL DEFAULT 'Economica' CHECK (classe IN ('Economica', 'Executiva')),
    valor DECIMAL(10, 2) NOT NULL CHECK (valor > 0),
    CONSTRAINT fk_passagens_voo FOREIGN KEY (voo_id) REFERENCES voos(id),
    CONSTRAINT fk_passagens_passageiro FOREIGN KEY (passageiro_id) REFERENCES passageiros(id)
);


INSERT INTO aeronaves (modelo, codigo_cauda, capacidade) VALUES
('Boeing 737-800', 'PTT-ABC', 180),
('Airbus A320', 'PTT-DEF', 174),
('Embraer E195', 'PTT-GHI', 118),
('ATR 72-600', 'PTT-JKL', 68),
('Boeing 787-9', 'PTT-MNO', 250);


INSERT INTO pilotos (nome, codigo_anac, horas_voo) VALUES
('Carlos Silva', '123456', 1200),
('Ana Souza', '234567', 850),
('Marcos Lima', '345678', 2100),
('Julia Alves', '456789', 500),
('Roberto Costa', '567890', 3400);


INSERT INTO passageiros (nome, cpf, email) VALUES
('João Santos', '11122233344', 'joao.santos@email.com'),
('Maria Oliveira', '22233344455', 'maria.oliveira@email.com'),
('Pedro Rocha', '33344455566', 'pedro.rocha@email.com'),
('Amanda Pereira', '44455566677', 'amanda.pereira@email.com'),
('Lucas Mendes', '55566677788', 'lucas.mendes@email.com');


INSERT INTO voos (aeronave_id, piloto_id, numero_voo, origem, destino, data_hora, status) VALUES
(1, 1, 'LA3001', 'São Paulo', 'Rio de Janeiro', '2026-10-15 10:00:00', 'Agendado'),
(2, 2, 'AD4002', 'Campinas', 'Salvador', '2026-10-02 11:00:00', 'Em Voo'),
(3, 3, 'G31003', 'Brasília', 'Florianópolis', '2026-10-01 14:00:00', 'Concluido'),
(4, 4, 'LA3004', 'Belo Horizonte', 'Curitiba', '2026-10-05 18:00:00', 'Agendado'),
(5, 5, 'AD4005', 'Recife', 'Fortaleza', '2026-09-30 08:00:00', 'Cancelado');


INSERT INTO passagens (voo_id, passageiro_id, assento, classe, valor) VALUES
(1, 1, '01A', 'Executiva', 1250.00),
(2, 2, '02B', 'Executiva', 980.00),
(1, 3, '12A', 'Economica', 450.00),
(3, 4, '15C', 'Economica', 380.00),
(4, 5, '18D', 'Economica', 520.00);


SELECT 
    v.numero_voo,
    v.origem,
    v.destino,
    a.modelo AS modelo_aeronave,
    p.nome AS nome_piloto
FROM voos v
INNER JOIN aeronaves a ON v.aeronave_id = a.id
INNER JOIN pilotos p ON v.piloto_id = p.id
WHERE v.status IN ('Agendado', 'Em Voo');



SELECT 
    p.nome AS nome_passageiro,
    v.numero_voo,
    pg.assento,
    pg.valor
FROM passagens pg
INNER JOIN passageiros p ON pg.passageiro_id = p.id
INNER JOIN voos v ON pg.voo_id = v.id
WHERE pg.classe = 'Executiva' 
  AND pg.valor > 800.00
ORDER BY pg.valor DESC;


CREATE VIEW vw_painel_aeroporto AS
SELECT 
    v.numero_voo,
    v.data_hora,
    v.origem,
    v.destino,
    a.modelo AS modelo_aeronave,
    a.codigo_cauda,
    v.status
FROM voos v
INNER JOIN aeronaves a ON v.aeronave_id = a.id;


CREATE VIEW vw_faturamento_por_voo AS
SELECT 
    v.id AS voo_id,
    v.numero_voo,
    v.destino,
    COUNT(pg.id) AS quantidade_passageiros,
    COALESCE(SUM(pg.valor), 0.00) AS receita_total
FROM voos v
LEFT JOIN passagens pg ON v.id = pg.voo_id
GROUP BY v.id, v.numero_voo, v.destino;