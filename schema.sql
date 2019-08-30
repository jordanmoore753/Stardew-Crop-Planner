CREATE TABLE seasons (
id serial PRIMARY KEY,
name text NOT NULL UNIQUE
);

CREATE TABLE crops (
id serial PRIMARY KEY,
name text NOT NULL UNIQUE,
season integer REFERENCES seasons (id) ON DELETE CASCADE,
until_harvest integer NOT NULL,
regrow integer,
produces integer NOT NULL
);

CREATE TABLE crop_prices (
id serial PRIMARY KEY,
crop_id integer REFERENCES crops (id) ON DELETE CASCADE,
sell_price integer NOT NULL,
seed_price integer NOT NULL
);

CREATE TABLE planted_crops (
id serial PRIMARY KEY,
crop_id integer REFERENCES crops (id) ON DELETE CASCADE,
season_id integer NOT NULL,
planted_on integer,
first_harvest integer,
sub_harvests integer[],
amount_planted integer NOT NULL
);

INSERT INTO seasons (name)
VALUES ('Spring'), ('Summer'), ('Fall'), ('Winter');

INSERT INTO crops(name, season, until_harvest, regrow, produces)
VALUES ('Blue Jazz', 1, 7, NULL, 1),
('Cauliflower', 1, 12, NULL, 1),
('Coffee Bean', 1, 10, 2, 4),
('Garlic', 1, 4, NULL, 4),
('Green Bean', 1, 10, 3, 1),
('Kale', 1, 6, NULL, 1),
('Parsnip', 1, 4, NULL, 1),
('Potato', 1, 6, NULL, 1),
('Rhubarb', 1, 13, NULL, 1),
('Strawberry', 1, 8, 4, 1),
('Tulip', 1, 6, NULL, 1);

INSERT INTO crops(name, season, until_harvest, regrow, produces)
VALUES ('Blueberry', 2, 13, 4, 3),
('Corn', 2, 14, 4, 1),
('Hops', 2, 11, 1, 1),
('Hot Pepper', 2, 5, 3, 1),
('Melon', 2, 12, NULL, 1),
('Poppy', 2, 7, NULL, 1),
('Radish', 2, 6, NULL, 1),
('Red Cabbage', 2, 9, NULL, 1),
('Starfruit', 2, 13, NULL, 1),
('Summer Spangle', 2, 8, NULL, 1),
('Sunflower', 2, 8, NULL, 1),
('Tomato', 2, 11, 4, 1),
('Wheat', 2, 4, NULL, 1);

INSERT INTO crops(name, season, until_harvest, regrow, produces)
VALUES ('Amaranth', 3, 7, NULL, 1),
('Artichoke', 3, 8, NULL, 1),
('Beet', 3, 6, NULL, 1),
('Bok Choy', 3, 4, NULL, 1),
('Cranberries', 3, 7, 5, 2),
('Eggplant', 3, 5, 5, 1),
('Fairy Rose', 3, 12, NULL, 1),
('Grape', 3, 10, 3, 1),
('Pumpkin', 3, 13, NULL, 1),
('Yam', 3, 10, NULL, 1);

INSERT INTO crop_prices (crop_id, sell_price, seed_price)
VALUES (1, 50, 30),
(2, 175, 80),
(3, 15, 2500),
(4, 60, 40),
(5, 40, 60),
(6, 110, 70),
(7, 35, 20),
(8, 80, 50),
(9, 220, 100),
(10, 120, 100),
(11, 30, 20);

INSERT INTO crop_prices (crop_id, sell_price, seed_price)
VALUES (12, 50, 80),
(13, 50, 150),
(14, 25, 60),
(15, 40, 40),
(16, 250, 80),
(17, 140, 100),
(18, 90, 40),
(19, 260, 100),
(20, 750, 450),
(21, 90, 50),
(22, 80, 200),
(23, 60, 50),
(24, 25, 10);

INSERT INTO crop_prices (crop_id, sell_price, seed_price)
VALUES (25, 150, 70),
(26, 160, 30),
(27, 100, 20),
(28, 80, 50),
(29, 75, 240),
(30, 60, 20),
(31, 290, 200),
(32, 80, 60),
(33, 320, 100),
(34, 160, 60);