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
