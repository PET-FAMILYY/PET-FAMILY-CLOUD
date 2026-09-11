-- ============================================================
-- Pet Family API — verify-database.sql
-- ============================================================
-- Apenas consultas (nenhum DDL, nenhuma credencial). Rode com:
--   ./azure/04-database-access.sh azure/verify-database.sql
-- ou cole os blocos manualmente numa sessão psql interativa.
-- Serve para comprovar, no vídeo, que tabelas/dados/alterações
-- realmente estão persistidos no PostgreSQL do Azure.
-- ============================================================

-- 1) Tabelas criadas no schema public
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2) Histórico do Flyway (confirma V1, V2, V3 aplicadas)
SELECT installed_rank, version, description, success, installed_on
FROM flyway_schema_history
ORDER BY installed_rank;

-- 3) Listar pets cadastrados (CRUD 1)
SELECT id, nome, especie, raca, idade, peso, tutor_id
FROM pets
ORDER BY id;

-- 4) Listar consultas cadastradas (CRUD 2)
SELECT id, data, horario, tipo_consulta, status, pet_id
FROM consultas
ORDER BY id;

-- 5) Pet + suas consultas (relacionamento pets <-> consultas via JOIN)
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

-- 6) Contagem de registros por tabela (visão geral rápida)
SELECT 'tutores' AS tabela, COUNT(*) AS total FROM tutores
UNION ALL SELECT 'usuarios', COUNT(*) FROM usuarios
UNION ALL SELECT 'pets', COUNT(*) FROM pets
UNION ALL SELECT 'consultas', COUNT(*) FROM consultas
UNION ALL SELECT 'consulta_slots', COUNT(*) FROM consulta_slots
UNION ALL SELECT 'lembretes', COUNT(*) FROM lembretes
UNION ALL SELECT 'interacoes_ia', COUNT(*) FROM interacoes_ia
ORDER BY tabela;

-- 7) Últimos IDs usados por tabela (para citar na demonstração/vídeo)
SELECT 'pets' AS tabela, MAX(id) AS ultimo_id FROM pets
UNION ALL SELECT 'consultas', MAX(id) FROM consultas
ORDER BY tabela;

-- 8) Consultas mais recentemente alteradas/realizadas (após operações da API)
SELECT id, data, horario, tipo_consulta, status, observacoes, pet_id
FROM consultas
WHERE status IN ('REALIZADA', 'CANCELADA')
ORDER BY id DESC;

-- 9) Conferir que uma exclusão via API realmente removeu o registro
--    (troque :id_excluido pelo ID usado na demonstração; deve
--    retornar 0 linhas depois do DELETE /consultas/{id})
-- SELECT * FROM consultas WHERE id = :id_excluido;
