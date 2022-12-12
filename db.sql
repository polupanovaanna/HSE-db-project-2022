create schema delivery;

--task 3

CREATE TABLE delivery.subscription_type(
    subscription_type_id INTEGER NOT NULL,
    subscription_type_name VARCHAR(50),
    price NUMERIC CHECK ( price > 0.0 ),
    duration_unit VARCHAR(20) CHECK ( duration_unit='week' OR
                                      duration_unit='month' OR
                                      duration_unit='year' ),
    valid_from TIMESTAMP DEFAULT now(),
    valid_to TIMESTAMP,

    CONSTRAINT subscr_type_ver PRIMARY KEY (subscription_type_id, valid_from)
);

CREATE TABLE delivery.dish(
    dish_id INTEGER PRIMARY KEY,
    dish_name VARCHAR(50),
    dish_price NUMERIC CHECK (dish_price >= 0),
    dish_amount INTEGER CHECK ( dish_amount >= 0 )

);

CREATE TABLE delivery.subscription_type_X_dish(
    dish_id INTEGER NOT NULL,
    subscription_type_id INTEGER NOT NULL,
    valid_from TIMESTAMP NOT NULL,

    CONSTRAINT std_id PRIMARY KEY (dish_id, subscription_type_id, valid_from),
    FOREIGN KEY (dish_id) REFERENCES delivery.dish (dish_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_type_id, valid_from) REFERENCES delivery.subscription_type (subscription_type_id, valid_from) ON DELETE CASCADE
);

CREATE TABLE delivery.city_office(
    office_id INTEGER PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL
);

CREATE TABLE delivery.city_office_X_subscription_type(
    office_id INTEGER NOT NULL,
    subscription_type_id INTEGER NOT NULL,
    valid_from TIMESTAMP NOT NULL,

    CONSTRAINT sost_id PRIMARY KEY (office_id, subscription_type_id, valid_from),
    FOREIGN KEY (office_id) REFERENCES delivery.city_office (office_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_type_id, valid_from) REFERENCES delivery.subscription_type (subscription_type_id, valid_from) ON DELETE CASCADE
);

CREATE TABLE delivery.user(
    user_id INTEGER PRIMARY KEY,
    office_id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number TEXT CHECK (regexp_match(phone_number, '^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$') NOTNULL),
    email TEXT,

    FOREIGN KEY (office_id) REFERENCES delivery.city_office (office_id) ON DELETE CASCADE
);

CREATE TABLE delivery.subscription(
    subscription_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    subscription_type_id INTEGER NOT NULL,
    valid_from TIMESTAMP NOT NULL,
    start_date TIMESTAMP DEFAULT now(),
    end_date TIMESTAMP CHECK ( end_date > subscription.start_date ),
    pay_type VARCHAR(20) CHECK ( pay_type='promocode' OR
                                 pay_type='card'),

    FOREIGN KEY (user_id) REFERENCES delivery.user (user_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_type_id, valid_from) REFERENCES delivery.subscription_type (subscription_type_id, valid_from) ON DELETE CASCADE
);

CREATE TABLE delivery.event(
    event_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    subscription_id INTEGER NOT NULL,
    datetime TIMESTAMP NOT NULL DEFAULT now(),
    event_type VARCHAR(15) CHECK ( event_type='subscription' OR  event_type='unsubscription' ),

    FOREIGN KEY (user_id) REFERENCES delivery.user (user_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES delivery.subscription (subscription_id) ON DELETE CASCADE
);

--task 4

set datestyle = 'DMY';

INSERT INTO delivery.city_office(office_id, city_name)
VALUES (1, 'Москва'),
       (2, 'Санкт-Петербург'),
       (3, 'Казань'),
       (4, 'Екатеринбург'),
       (5, 'Самара');

INSERT INTO delivery.user(user_id, office_id, first_name, last_name, phone_number, email)
VALUES (1, 1, 'Анна', 'Полупанова', '+7(921)979-65-94', 'ania@mail.ru'),
       (2, 1, 'Иван', 'Иванов', '+79219999999', 'ivan@mail.ru'),
       (3, 2, 'Сергей', 'Дымашевский', '+79236669922', 'sergey@mail.ru'),
       (4, 2, 'Максим', 'Максимов', '+79345535244', 'maxim@yandex.ru'),
       (5, 1, 'Павел', 'Батон', '8(911)1111111', 'pasha@mail.ru'),
       (6, 5, 'Илья', 'Петров', '8(911)1221351', 'ilya@mail.ru'),
       (7, 3, 'Александр', 'Сергеев', '89114556554', 'alex@gmail.com');


INSERT INTO delivery.subscription_type(subscription_type_id, subscription_type_name, price, duration_unit, valid_from, valid_to)
VALUES (1, 'базовая 1200', 4000, 'month', '11.12.2022', '11.12.2024'),
       (2, 'базовая 2000', 6000, 'month', '11.12.2022', '11.12.2024'),
       (2, 'базовая 2000', 5000, 'month', '11.12.2020', '10.12.2022'),
       (3, 'базовая 2500', 8000, 'month', '11.12.2022', '11.12.2024'),
       (4, 'вегетарианская', 5000, 'month', '11.12.2022', '11.12.2024'),
       (5, 'без глютена', 4500, 'month', '11.12.2022', '11.12.2024'),
       (6, 'на неделю', 1000, 'week', '11.12.2022', '11.12.2024'),
       (6, 'на неделю', 999, 'week', '11.12.2020', '10.12.2022');


INSERT INTO delivery.subscription(subscription_id, user_id, subscription_type_id, valid_from, start_date, end_date, pay_type)
VALUES (1, 1, 2, '11.12.2020', '11.12.2021', '29.07.2022', 'card'),
       (2, 7, 1, '11.12.2022', '12.12.2022', '29.05.2023', 'card'),
       (3, 2, 3, '11.12.2022', '13.12.2022', '29.04.2023', 'card'),
       (4, 3, 4, '11.12.2022', '14.12.2022', '24.12.2023', 'promocode'),
       (5, 3, 5, '11.12.2022', '15.12.2022', '11.02.2024', 'card'),
       (6, 5, 6, '11.12.2022', '16.12.2022', '31.12.2022', 'card'),
       (7, 6, 1, '11.12.2022', '17.12.2022', '24.02.2024', 'card'),
       (8, 2, 2, '11.12.2020', '18.12.2020', '01.09.2022', 'card');

INSERT INTO delivery.event(event_id, user_id, subscription_id, datetime, event_type)
VALUES (1, 1, 1, '11.12.2021', 'subscription'),
       (2, 7, 2, '12.12.2022', 'subscription'),
       (3, 2, 3, '13.12.2022', 'subscription'),
       (4, 3, 4, '14.12.2022', 'subscription'),
       (5, 3, 5, '15.12.2022', 'subscription'),
       (6, 5, 6, '16.12.2022', 'subscription'),
       (7, 6, 7, '17.12.2022', 'subscription'),
       (8, 1, 8, '18.12.2020', 'subscription');

INSERT INTO delivery.city_office_X_subscription_type(office_id, subscription_type_id, valid_from)
VALUES (1, 1, '11.12.2022'), (1, 2, '11.12.2022'), (1,3, '11.12.2022'), (1,4, '11.12.2022'), (1,5, '11.12.2022'), (1,6, '11.12.2022'),
       (2, 1, '11.12.2022'), (2, 2, '11.12.2022'), (2,3, '11.12.2022'), (2,4, '11.12.2022'), (2,5, '11.12.2022'), (2,6, '11.12.2022'),
       (3, 1, '11.12.2022'), (3, 2, '11.12.2022'), (3,3, '11.12.2022'),
       (4, 1, '11.12.2022'), (4, 2, '11.12.2022'), (4,3, '11.12.2022'),
       (5, 1, '11.12.2022'), (5, 2, '11.12.2022'), (5,3, '11.12.2022'), (5, 4, '11.12.2022'),
       (1, 2, '11.12.2020'), (1, 6, '11.12.2020');

INSERT INTO delivery.dish(dish_id, dish_name, dish_price, dish_amount)
VALUES (1, 'плов', 200, 10),
       (2, 'куриный суп', 210, 20),
       (3, 'овощной суп', 100, 10),
       (4, 'стейк из говядины', 500, 52),
       (5, 'овощи гриль', 150, 140),
       (6, 'вок с морепродуктами', 400, 13),
       (7, 'салат цезарь', 300, 40),
       (8, 'шоколадный торт', 230, 23);

INSERT INTO delivery.subscription_type_X_dish(dish_id, subscription_type_id, valid_from)
VALUES (1, 2, '11.12.2022'), (1, 3, '11.12.2022'), (1, 6, '11.12.2022'),
       (2, 1, '11.12.2022'), (2, 2, '11.12.2022'), (2, 6, '11.12.2022'),
       (3, 1, '11.12.2022'), (3, 2, '11.12.2022'), (3, 4, '11.12.2022'), (3, 5, '11.12.2022'),
       (4, 3, '11.12.2022'), (4, 6, '11.12.2022'),
       (5, 1, '11.12.2022'), (5, 2, '11.12.2022'), (5, 3, '11.12.2022'), (5, 4, '11.12.2022'), (5, 5, '11.12.2022'),
       (6, 1, '11.12.2022'), (6, 2, '11.12.2022'), (6, 6, '11.12.2022'),
       (7, 1, '11.12.2022'), (7, 2, '11.12.2022'), (7, 3, '11.12.2022'), (7, 5, '11.12.2022'), (7, 6, '11.12.2022'),
       (8, 3, '11.12.2022'), (8, 6, '11.12.2022'),
       (1, 2, '11.12.2020'), (2, 2, '11.12.2020'),
       (1, 6, '11.12.2020'), (2, 6, '11.12.2020'), (3, 6, '11.12.2020'), (4, 6, '11.12.2020'), (6, 6, '11.12.2020'),
       (7, 6, '11.12.2020'), (8, 6, '11.12.2020');


--task 5

INSERT INTO delivery.dish(dish_id, dish_name, dish_price, dish_amount)
VALUES (9, 'морс', 50, 1);

INSERT INTO delivery.dish(dish_id, dish_name, dish_price, dish_amount)
VALUES (10, 'тофу', 230, 5);

INSERT INTO delivery.subscription_type_X_dish(dish_id, subscription_type_id, valid_from)
VALUES (9, 1, '11.12.2022'), (9, 2, '11.12.2022'), (9, 3, '11.12.2022'), (9, 4, '11.12.2022'), (9, 5, '11.12.2022'), (9, 6, '11.12.2022'),
       (10, 4, '11.12.2022');

SELECT dish_name, dish_price FROM delivery.dish;

UPDATE delivery.dish
SET dish_price = 60
WHERE dish_name = 'морс';

-- здесь мы видимо поняли, что доставка морса это ошибка
DELETE FROM delivery.dish WHERE dish_id = 9;
DELETE FROM delivery.subscription_type_X_dish WHERE dish_id = 9;

-- человек, у которого не было подписки раньше, совершил новую

INSERT INTO delivery.subscription(subscription_id, user_id, subscription_type_id, valid_from, end_date, pay_type)
VALUES (9, 5, 5, '11.12.2022', now() + interval '1 year', 'card');

INSERT INTO delivery.event(event_id, user_id, subscription_id, datetime, event_type)
VALUES (9, 5, 9, (SELECT start_date FROM delivery.subscription WHERE subscription_id = 9), 'subscription');

-- а человек, который имел какую-то текущую подписку решил ее отменить

UPDATE delivery.subscription
SET end_date = '17.12.2022'
WHERE subscription_id = 3;

INSERT INTO delivery.event(event_id, user_id, subscription_id, datetime, event_type)
VALUES (10, 2, 3, (SELECT end_date FROM delivery.subscription WHERE subscription_id = 3), 'unsubscription');

--task 6

-- в результате запроса выводится список городов в алфавитном порядке, на складе которых лежит тофу (доступен в подписках для этого города)
-- ожидаем Москву, Самару, Санкт-Петербург

SELECT DISTINCT city_name FROM
    delivery.city_office co
        INNER JOIN delivery.city_office_X_subscription_type co_X_st ON co.office_id = co_X_st.office_id
        INNER JOIN delivery.subscription_type st ON
            co_X_st.subscription_type_id =  st.subscription_type_id AND co_X_st.valid_from = st.valid_from
        INNER JOIN delivery.subscription_type_X_dish st_X_d ON
            st_X_d.subscription_type_id = st.subscription_type_id AND st.valid_from = st_X_d.valid_from
        INNER JOIN delivery.dish d ON st_X_d.dish_id = d.dish_id
    WHERE dish_name = 'тофу';

-- В результате запроса выводится список id и имен пользователей в алфавитном порядке из СПб
-- или Москвы и общая сумма, которую они платят в месяц по действующей подписке, если они в месяц платят больше 5000 рублей
-- ожидаем Сергей Дымашевский - 9500 (сложили обе подписки), Иван Иванов - 8000 (учли только текущую подписку)

SELECT u.user_id, u.last_name || ' ' || u.first_name AS full_name,
       SUM(CASE WHEN duration_unit='week' THEN price*4 ELSE price END) AS total_price
FROM delivery.user u
    INNER JOIN delivery.subscription s ON u.user_id = s.user_id
    INNER JOIN delivery.subscription_type st ON
        s.subscription_type_id = st.subscription_type_id AND s.valid_from = st.valid_from
    INNER JOIN delivery.city_office co ON u.office_id = co.office_id
WHERE (co.city_name = 'Москва' OR co.city_name = 'Санкт-Петербург')
    AND end_date > now()
GROUP BY u.user_id, u.first_name, u.last_name
HAVING SUM(CASE WHEN duration_unit='week' THEN price*4 ELSE price END) > 5000
ORDER BY full_name;


-- Вывести имена пользователей, которые приобретали хотя бы одну подписку, их текущие подписки,
-- и среднюю стоимость подписки у пользователя
-- ожидается: см файл с ожидаемыми результатами

SELECT u.last_name || ' ' || u.first_name AS full_name, subscription_type_name,
        price, AVG(price) over (partition by last_name) as avg_price
FROM delivery.user u
    INNER JOIN delivery.subscription s ON u.user_id = s.user_id
    INNER JOIN delivery.subscription_type st ON
        s.subscription_type_id = st.subscription_type_id AND s.valid_from = st.valid_from
WHERE s.end_date > now();

-- Вывести полные имена пользователей, их текущие подписки, а также предыдущие для текущей подписки
-- предыдущая подписка - такая, что у нее дата начала раньше
-- итого в выводе id пользователя, имя пользователя, название текущей подписки, дата ее начала,
-- название предыдущей подписки, дата ее начала
-- ожидается: см файл с ожидаемыми результатами
-- идейно: все подписки, которые еще не закончились (7 штук)

SELECT user_id, full_name, subscription_type_name, start_date, end_date, previous_subscr, previous_start_date
FROM (SELECT u.user_id, u.last_name || ' ' || u.first_name AS full_name, subscription_type_name, start_date, end_date,
             LAG(subscription_type_name) OVER (PARTITION BY last_name ORDER BY start_date) AS previous_subscr,
             LAG(start_date) OVER (PARTITION BY last_name ORDER BY start_date) AS previous_start_date
    FROM delivery.user u
    INNER JOIN delivery.subscription s ON u.user_id = s.user_id
    INNER JOIN delivery.subscription_type st ON
        s.subscription_type_id = st.subscription_type_id AND s.valid_from = st.valid_from) as tt
WHERE tt.end_date > now();

-- Вывести id + полное имя пользователей, таких, что у них сумма оплаты за все время (число полных месяцев от начала подписки * стоимость подписки)
-- превышает 50000 рублей, и потраченную ими сумму в порядке возрастания суммы
-- месяц = 4 недели подписки, то есть 28 дней
-- ожидается Иванов Иван - 110000, который платил ~2 года за устаревшую подписку и Полупанова Анна - 40000,
-- которая примерно 8 месяцев платила за подписку старой версии

SELECT u.user_id, u.last_name || ' ' || u.first_name AS full_name,
       SUM(CASE WHEN duration_unit='week' THEN st.price * floor(DATE_PART('day',
           CASE WHEN now() > s.end_date THEN s.end_date ELSE now() END - s.start_date) / 7)
                ELSE st.price * floor(DATE_PART('day',
                    CASE WHEN now() > s.end_date THEN s.end_date ELSE now() END - s.start_date)/28) END) AS total_sum
FROM delivery.user u
    INNER JOIN delivery.subscription s ON u.user_id = s.user_id
    INNER JOIN delivery.subscription_type st ON
        s.subscription_type_id = st.subscription_type_id AND s.valid_from = st.valid_from
    CROSS JOIN now() as tmp
GROUP BY u.user_id, full_name
HAVING SUM(CASE WHEN duration_unit='week' THEN st.price * floor(DATE_PART('day',
                    CASE WHEN now() > s.end_date THEN s.end_date ELSE now() END - s.start_date) / 7)
                ELSE st.price * floor(DATE_PART('day',
                    CASE WHEN now() > s.end_date THEN s.end_date ELSE now() END - s.start_date)/28) END) > 10000
ORDER BY total_sum DESC;
