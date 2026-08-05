-- DataBase Name
-- 3POL_DB_MASTER

INSERT INTO 3POL_DB_MASTER.roles(name)
SELECT * FROM (
    SELECT 'ROLE_USER' AS name
    UNION SELECT 'ROLE_ADMIN'
) AS temp
WHERE NOT EXISTS (
    SELECT 1 FROM 3POL_DB_MASTER.roles WHERE name IN ('ROLE_USER', 'ROLE_ADMIN')
);


INSERT INTO 3POL_DB_MASTER.users(address, city, country, email, password, phone, username)
SELECT * FROM (
    SELECT 'Town, Islamabad' AS address,
           'Islamabad' AS city,
           'Pakistan' AS country,
           'admin@email.com' AS email,
           '$2a$10$OArNS0oAsKANWY4syqpmwO0D3OuSw3XhszqMRnLh.KsSYE99g3faK' AS password,
           '3322604002' AS phone,
           'admin' AS username
) AS temp
WHERE NOT EXISTS (
    SELECT 1 FROM 3POL_DB_MASTER.users 
    WHERE email = 'admin@email.com' AND username = 'admin'
);



INSERT INTO 3POL_DB_MASTER.user_roles(user_id, role_id)
SELECT * FROM (
    SELECT 1 AS user_id, 2 AS role_id
) AS temp
WHERE NOT EXISTS (
    SELECT 1 FROM 3POL_DB_MASTER.user_roles WHERE user_id = 1 AND role_id = 2
);

ALTER TABLE 3POL_DB_MASTER.inverter_table MODIFY user_id BIGINT NULL;
