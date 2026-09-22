DROP TABLE IF EXISTS parameters;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS positions;
DROP TABLE IF EXISTS packs;
DROP TABLE IF EXISTS equipment_types;

--типы оборудования
CREATE TABLE equipment_types(
    equipment_type_id INT,
    equipment_type_name VARCHAR(30),
    PRIMARY KEY (equipment_type_id)
);
COMMENT ON TABLE equipment_types IS 'типы оборудования(например ветровое ружье)';
COMMENT ON COLUMN equipment_types.equipment_type_id IS 'уникальный айди оборудования';
COMMENT ON COLUMN equipment_types.equipment_type_name IS 'название оборудование';

--должности
CREATE TABLE positions(
    position_id INT,
    position_name VARCHAR(30),
    PRIMARY KEY (position_id)
);
COMMENT ON TABLE positions IS 'должности пользователей';
COMMENT ON COLUMN positions.position_id IS 'уникальный айди должности';
COMMENT ON COLUMN positions.position_name IS 'название должности';

--пачки. группирует пользователей и их замеры в пачки
CREATE TABLE packs(
    pack_id INT,
    pack_number VARCHAR(30),
    created_date TIMESTAMP,
    PRIMARY KEY (pack_id)
);
COMMENT ON TABLE packs IS 'пачки, чтобы группировать измерения';
COMMENT ON COLUMN packs.pack_id IS 'уникальный айди пачки';
COMMENT ON COLUMN packs.pack_number IS 'номер пачки';
COMMENT ON COLUMN packs.created_date IS 'дата создания пачки';

-- пользователи.
CREATE TABLE users(
    user_id INT,
    user_name VARCHAR(50),
    position_id INT,
    pack_id INT,
    PRIMARY KEY(user_id),
    FOREIGN KEY(position_id) REFERENCES positions(position_id),
    FOREIGN KEY(pack_id) REFERENCES packs(pack_id)
);
COMMENT ON TABLE users IS 'пользователи системы';
COMMENT ON COLUMN users.user_id IS 'уникальный айди пользователя';
COMMENT ON COLUMN users.user_name IS 'фамилия и имя пользователя';
COMMENT ON COLUMN users.position_id IS 'Ссылка на должность';
COMMENT ON COLUMN users.pack_id IS 'Ссылка на пачку';

--параметры
CREATE TABLE parameters(
    parameter_id INT,
    parameter_name VARCHAR(50),
    parameter_value VARCHAR(50),
    user_id INT,
    equipment_type_id INT,
    PRIMARY KEY(parameter_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(equipment_type_id) REFERENCES equipment_types(equipment_type_id)
);
COMMENT ON TABLE parameters IS 'параметры измерений';
COMMENT ON COLUMN parameters.parameter_id IS 'уникальный айди параметра';
COMMENT ON COLUMN parameters.parameter_name IS 'название параметра';
COMMENT ON COLUMN parameters.parameter_value IS 'значение параметра';
COMMENT ON COLUMN parameters.user_id IS 'ссылка на пользователя';
COMMENT ON COLUMN parameters.equipment_type_id IS 'ссылка на тип оборудования';

INSERT INTO equipment_types (equipment_type_id, equipment_type_name) VALUES (1, 'ДМК');
INSERT INTO equipment_types (equipment_type_id, equipment_type_name) VALUES (2, 'ВР');

INSERT INTO positions (position_id, position_name) VALUES (1, 'Оператор');
INSERT INTO positions (position_id, position_name) VALUES (2, 'Старший оператор');

INSERT INTO packs (pack_id, pack_number, created_date) VALUES (1, 'PACK-01AA', '2026-05-11 10:00:00');
INSERT INTO packs (pack_id, pack_number, created_date) VALUES (2, 'PACK-02AB', '2026-05-11 11:30:00');

INSERT INTO users (user_id, user_name, position_id, pack_id) VALUES (1, 'Иван Иванов', 1, 1);
INSERT INTO users (user_id, user_name, position_id, pack_id) VALUES (2, 'Иван Петров', 2, 2);

INSERT INTO parameters (parameter_id, parameter_name, parameter_value, user_id, equipment_type_id) 
VALUES (1, 'Высота метеопоста', '100', 1, 1);

INSERT INTO parameters (parameter_id, parameter_name, parameter_value, user_id, equipment_type_id) 
VALUES (2, 'Температура', '15', 1, 1);

INSERT INTO parameters (parameter_id, parameter_name, parameter_value, user_id, equipment_type_id) 
VALUES (3, 'Давление', '750', 1, 1);

INSERT INTO parameters (parameter_id, parameter_name, parameter_value, user_id, equipment_type_id) 
VALUES (4, 'Направление ветра', '00', 1, 1);

INSERT INTO parameters (parameter_id, parameter_name, parameter_value, user_id, equipment_type_id) 
VALUES (5, 'Скорость ветра', '0', 1, 1);

INSERT INTO parameters (parameter_id, parameter_name, parameter_value, user_id, equipment_type_id) 
VALUES (6, 'Дальность сноса пуль', '0', 2, 2);

SELECT 
    u.user_id,
    u.user_name,
    pos.position_name,
    pk.pack_number,
    pk.created_date,
    eq.equipment_type_name,
    pr.parameter_name,
    pr.parameter_value
FROM users u
JOIN positions pos ON u.position_id = pos.position_id
JOIN packs pk ON u.pack_id = pk.pack_id
JOIN parameters pr ON u.user_id = pr.user_id
JOIN equipment_types eq ON pr.equipment_type_id = eq.equipment_type_id;