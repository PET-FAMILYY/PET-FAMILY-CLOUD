-- ============================================================
-- Pet Family API — seed-veterinario.sql
-- ============================================================
-- O DataInitializer (dados de demonstração) só roda no perfil
-- "dev" — de propósito, para não colocar dados fictícios em
-- produção. Como não existe endpoint público para criar um
-- usuário VETERINARIO (só /auth/registrar, que sempre cria
-- TUTOR), este script cria UMA conta de veterinário de
-- demonstração direto no banco, só para testar os endpoints
-- restritos a VETERINARIO durante a avaliação/gravação.
--
-- Nenhuma senha ou hash fica fixo neste arquivo: o hash BCrypt é
-- calculado dentro do próprio PostgreSQL (extensão pgcrypto),
-- a partir da variável psql "vet_password" — que é passada pelo
-- wrapper, nunca commitada.
--
-- Rode uma única vez, depois do primeiro deploy:
--   VET_SEED_PASSWORD='EscolhaUmaSenhaForte123!' ./azure/04-database-access.sh azure/seed-veterinario.sql
-- (ou deixe VET_SEED_PASSWORD vazio e o script pede a senha por prompt seguro)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO usuarios (nome, email, senha_hash, role, tutor_id, criado_em)
VALUES (
    'Dra. Camila Souza (DevOps Demo)',
    'veterinario.devops@petfamily.com',
    crypt(:'vet_password', gen_salt('bf', 10)),
    'VETERINARIO',
    NULL,
    NOW()
)
ON CONFLICT (email) DO UPDATE SET senha_hash = EXCLUDED.senha_hash;

SELECT id, nome, email, role FROM usuarios WHERE email = 'veterinario.devops@petfamily.com';
