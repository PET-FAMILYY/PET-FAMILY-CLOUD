SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT installed_rank, version, description, success, installed_on
FROM flyway_schema_history
ORDER BY installed_rank;

SELECT id, nome, especie, raca, idade, peso, tutor_id
FROM pets
ORDER BY id;

SELECT id, data, horario, tipo_consulta, status, pet_id
FROM consultas
ORDER BY id;

SELECT
    p.id          AS pet_id,
    p.nome        AS pet_nome,
    p.especie,
    c.id          AS consulta_id,
    c.data        AS consulta_data,
    c.tipo_consulta,
    c.status      AS consulta_status
FROM pets p
JOIN consultas c ON c.pet_id = p.id
ORDER BY p.id, c.data;

SELECT 'tutores' AS tabela, COUNT(*) AS total FROM tutores
UNION ALL SELECT 'usuarios', COUNT(*) FROM usuarios
UNION ALL SELECT 'pets', COUNT(*) FROM pets
UNION ALL SELECT 'consultas', COUNT(*) FROM consultas
UNION ALL SELECT 'consulta_slots', COUNT(*) FROM consulta_slots
UNION ALL SELECT 'lembretes', COUNT(*) FROM lembretes
UNION ALL SELECT 'interacoes_ia', COUNT(*) FROM interacoes_ia
ORDER BY tabela;

SELECT 'pets' AS tabela, MAX(id) AS ultimo_id FROM pets
UNION ALL SELECT 'consultas', MAX(id) FROM consultas
ORDER BY tabela;

SELECT id, data, horario, tipo_consulta, status, observacoes, pet_id
FROM consultas
WHERE status IN ('REALIZADA', 'CANCELADA')
ORDER BY id DESC;
