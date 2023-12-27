-- Таблица актёров
CREATE TABLE IF NOT EXISTS actors (
    actor_id SERIAL PRIMARY KEY,
    actor_name VARCHAR(100) NOT NULL,
    birthdate DATE,
    nationality VARCHAR(50)
);
-- Вставка данных в таблицу актёров
INSERT INTO actors (actor_name, birthdate, nationality) VALUES
    ('Джонни Депп', '1963-06-09', 'American'),
    ('Мэрил Стрипп', '1949-06-22', 'American'),
    ('Леонардо Ди-Каприо', '1974-11-11', 'American'),
	('Крис Хемсворт', '1983-08-11', 'Australian'),
	('Дэниел Рэдклифф', '1989-07-23', 'Britain'),
	('Сэмюэл Л. Джексон', '1948-12-21', 'American'),
	('Эмма Уотсон', '1990-04-15', 'Britain'),
	('Том Круз', '1962-07-03', 'Britain'),
	('Вин Дизель', '1967-07-18', 'American'),
	('Роберт Дауни-Младший', '1965-04-04', 'American'),
	('Скарлетт Йоханссон', '1984-11-22', 'American');
	

-- Таблица студий
CREATE TABLE IF NOT EXISTS studios (
    studio_id SERIAL PRIMARY KEY,
    studio_name VARCHAR(100) NOT NULL
);
-- Вставка данных в таблицу студий
INSERT INTO studios (studio_name) VALUES
    ('Warner Bros.'),
    ('Universal Pictures'),
    ('Paramount Pictures'),
	('Sony Pictures'),
	('20th Fox'),
	('Columbia Pictures'),
	('Miramax Films');
	
	

-- Таблица стран производства фильмов
CREATE TABLE IF NOT EXISTS countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(50) NOT NULL
);
-- Вставка данных в таблицу стран
INSERT INTO countries (country_name) VALUES
    ('USA'),
    ('UK'),
    ('France'),
	('Australia'),
	('Poland');
	
	
	
-- Таблица режиссёров
CREATE TABLE IF NOT EXISTS directors (
    director_id SERIAL PRIMARY KEY,
    director_name VARCHAR(100) NOT NULL,
    birthdate DATE,
    nationality VARCHAR(50)
);
-- Вставка данных в таблицу режиссёров
INSERT INTO directors (director_name, birthdate, nationality) VALUES
    ('Стивен Спилберг', '1946-12-18', 'American'),
    ('Кристофер Нолан', '1970-07-30', 'British'),
    ('Квентин Тарантино', '1963-03-27', 'American'),
	('Роман Полански', '1933-08-18', 'Poland'),
	('Вуди Аллен', '1935-11-30', 'American');
	
	
	

-- Таблица рейтингов фильмов
CREATE TABLE IF NOT EXISTS ratings (
    rating_id SERIAL PRIMARY KEY,
    rating_value DECIMAL(3, 1) NOT NULL
);
-- Вставка данных в таблицу рейтингов
INSERT INTO ratings (rating_value) VALUES
    (8.5),
    (7.9),
    (8.8),
	(4.3),
	(9.5);
	


-- Таблица фильмов
CREATE TABLE IF NOT EXISTS movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_date DATE,
    director_id INT REFERENCES directors(director_id),
    studio_id INT REFERENCES studios(studio_id),
    country_id INT REFERENCES countries(country_id),
    rating_id INT REFERENCES ratings(rating_id)
);
-- Вставка данных в таблицу фильмов
INSERT INTO movies (title, release_date, director_id, studio_id, country_id, rating_id) VALUES
    ('Pirates of the Caribbean', '2003-07-09', 1, 1, 1, 1),
    ('Inception', '2010-07-22', 2, 2, 2, 2),
    ('Pulp Fiction', '1994-10-14', 3, 3, 1, 3),
	('Остров', '2005-07-09', 5, 4, 2, 4),
    ('Шерлок Холмс', '2009-12-22', 4, 5, 4, 5);



-- Таблица жанров фильмов
CREATE TABLE IF NOT EXISTS genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL
);
-- Вставка данных в таблицу жанров
INSERT INTO genres (genre_name) VALUES
    ('Action'),
    ('Drama'),
    ('Comedy'),
	('Triller'),
	('Detective');


-- Таблица персонажей в фильмах
CREATE TABLE IF NOT EXISTS characters (
    character_id SERIAL PRIMARY KEY,
    character_name VARCHAR(100) NOT NULL
);
-- Вставка данных в таблицу персонажей
INSERT INTO characters (character_name) VALUES
    ('Captain Jack Sparrow'),
    ('Dom Cobb'),
    ('Vincent Vega'),
	('Sara Gordan'),
	('Sherlock');
	
	
-- Таблица ролей актёров в фильмах
CREATE TABLE IF NOT EXISTS roles (
  role_id SERIAL PRIMARY KEY,
    actor_id INT REFERENCES actors(actor_id),
    movie_id INT REFERENCES movies(movie_id),
    character_id INT REFERENCES characters(character_id)
);
-- Вставка данных в таблицу ролей
INSERT INTO roles (actor_id, movie_id, character_id) VALUES
    (1, 1, 1),
    (3, 2, 2),
    (2, 3, 3),
	(11, 4, 4),
    (10, 5, 5);



-- Таблица связи между фильмами и их жанрами
CREATE TABLE IF NOT EXISTS movie_genres (
    movie_id INT REFERENCES movies(movie_id),
    genre_id INT REFERENCES genres(genre_id),
    PRIMARY KEY (movie_id, genre_id)
);
-- Вставка данных в таблицу связи между фильмами и жанрами
INSERT INTO movie_genres (movie_id, genre_id) VALUES
    (1, 1),  -- Pirates of the Caribbean - Action
    (2, 2),  -- Inception - Drama
    (3, 2),  -- Pulp Fiction - Drama
    (3, 3),  -- Pulp Fiction - Comedy
	(4, 4),  -- Остров - Триллер
    (5, 5);  -- Шерлок Холмс - Детектив
	

-- Триггерная функция для автоматического установления release_date на текущую дату
CREATE OR REPLACE FUNCTION set_default_release_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.release_date := COALESCE(NEW.release_date, CURRENT_DATE);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание представления для отображения информации о фильмах с дополнительной информацией
CREATE OR REPLACE VIEW movie_info AS
SELECT
  m.movie_id,
  m.title,
  m.release_date,
  d.director_name,
  s.studio_name,
  c.country_name,
  array_agg(g.genre_name) AS genres
FROM
  movies m
  JOIN directors d ON m.director_id = d.director_id
  JOIN studios s ON m.studio_id = s.studio_id
  JOIN countries c ON m.country_id = c.country_id
  JOIN movie_genres mg ON m.movie_id = mg.movie_id
  JOIN genres g ON mg.genre_id = g.genre_id
GROUP BY
  m.movie_id, m.title, m.release_date, d.director_name, s.studio_name, c.country_name;


-- Триггер для таблицы фильмов для установки значения release_date по умолчанию
CREATE TRIGGER set_default_release_date_trigger
BEFORE INSERT ON movies
FOR EACH ROW
EXECUTE PROCEDURE set_default_release_date();

-- Триггерная функция для автоматического установления рейтинга, если не указан
CREATE OR REPLACE FUNCTION set_default_rating()
RETURNS TRIGGER AS $$
BEGIN
  NEW.rating_id := COALESCE(NEW.rating_id, 1); -- Предположим, что рейтинг 0 соответствует отсутствию рейтинга
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для таблицы фильмов для установки значения рейтинга по умолчанию
CREATE TRIGGER set_default_rating_trigger
BEFORE INSERT ON movies
FOR EACH ROW
EXECUTE PROCEDURE set_default_rating();


-- Хранимая процедура для получения списка фильмов по стране
CREATE OR REPLACE FUNCTION get_movies_by_country(country_name VARCHAR)
RETURNS TABLE (
  title VARCHAR,
  release_date DATE,
  director_name VARCHAR,
  rating_value DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.title,
    m.release_date,
    d.director_name,
    r.rating_value
  FROM
    movies m
    JOIN ratings r ON m.rating_id = r.rating_id
    JOIN directors d ON m.director_id = d.director_id
    JOIN countries c ON m.country_id = c.country_id
  WHERE
    c.country_name = get_movies_by_country.country_name;
END;
$$;


-- Триггерная функция для автоматического установления рейтинга на 0, если не указан
CREATE OR REPLACE FUNCTION increase_movie_rating(movie_id INT, increase_value DECIMAL)
RETURNS VOID AS $$
BEGIN
  UPDATE movies
  SET rating_id = rating_id + increase_value
  WHERE movies.movie_id = increase_movie_rating.movie_id;
END;
$$ LANGUAGE plpgsql;



-- Общее табличное выражение (CTE) для получения рейтинга фильма и среднего рейтинга по режиссёру
WITH MovieRatings AS (
  SELECT
    m.title,
    r.rating_value,
    d.director_name,
    AVG(r.rating_value) OVER (PARTITION BY m.director_id) AS avg_director_rating
  FROM
    movies m
    JOIN ratings r ON m.rating_id = r.rating_id
    JOIN directors d ON m.director_id = d.director_id
)
SELECT * FROM MovieRatings;

-- Оконная функция для получения рейтинга фильма и среднего рейтинга по режиссёру (тоже что и в примере с CTE)
SELECT
  m.title,
  r.rating_value,
  d.director_name,
  AVG(r.rating_value) OVER (PARTITION BY m.director_id) AS avg_director_rating
FROM
  movies m
  JOIN ratings r ON m.rating_id = r.rating_id
  JOIN directors d ON m.director_id = d.director_id;


-- Оконная функция для получения накопленной суммы рейтингов по жанрам
SELECT
  m.title,
  g.genre_name,
  r.rating_value,
  SUM(r.rating_value) OVER (PARTITION BY g.genre_id ORDER BY m.release_date) AS cumulative_rating_sum
FROM
  movies m
  JOIN ratings r ON m.rating_id = r.rating_id
  JOIN movie_genres mg ON m.movie_id = mg.movie_id
  JOIN genres g ON mg.genre_id = g.genre_id;
