/* Tasca S4.01. Creació de Base de Dades

Descripció
Partint d'alguns arxius CSV dissenyaràs i crearàs la teva base de dades.


# Nivell 1
Descarrega els arxius CSV, estudia’ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals
puguis realitzar les següents consultes: */

-- Creació de la BBDD
CREATE DATABASE Transactions4;

-- Creació de la taula companies
CREATE TABLE IF NOT EXISTS companies
(
	company_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(100),
	phone VARCHAR(20),
	email VARCHAR(50),
	country VARCHAR(50),
	website VARCHAR(255)
); 

-- a continuació importo el seu csv clickant (botó dret) sobre la BD → Table Data Import Wizard

-- primer creo la taula users per després poder crear la FK de credit_cards
CREATE TABLE IF NOT EXISTS users
(
	id INT PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(255),
	phone VARCHAR(20),
	email VARCHAR(50),
	birth_date VARCHAR(50),
	country VARCHAR(100),
	city VARCHAR(100),
	postal_code VARCHAR(30),
	address VARCHAR(255)
);

-- Creació de la taula credit_cards
CREATE TABLE IF NOT EXISTS credit_cards
(
	id VARCHAR(10) PRIMARY KEY,
	user_id INT,
	iban VARCHAR(50),
	pan VARCHAR(30),
	pin VARCHAR(4),
	cvv INT,
	track1 VARCHAR(255),
	track2 VARCHAR(255),
	expiring_date DATE,
    FOREIGN KEY(user_id) REFERENCES users(id)  
);

-- Creació de la taula products
CREATE TABLE IF NOT EXISTS products
(
	id INT PRIMARY KEY,
	product_name VARCHAR(50),
	price FLOAT,
	colour VARCHAR(50),
	weight FLOAT,
	warehouse_id VARCHAR(10)
);

-- Creació de la taula transacctions
CREATE TABLE IF NOT EXISTS transactions
(
	id VARCHAR(100) PRIMARY KEY,
	card_id VARCHAR(10),
	business_id VARCHAR(10),
	timestamp TIMESTAMP,
	amount FLOAT,
	declined BOOLEAN,
	product_ids VARCHAR(50),
	user_id INT,
	lat VARCHAR(50),
	longitude VARCHAR(50),
	FOREIGN KEY(card_id) REFERENCES credit_cards(id),
    FOREIGN KEY(business_id) REFERENCES companies(company_id),
    FOREIGN KEY(user_id) REFERENCES users(id)
);

-- Per últim creo la taula nexe: products_transactions
CREATE TABLE IF NOT EXISTS products_transactions
(
	id VARCHAR(100),
    product_ids INT,
    FOREIGN KEY(id) REFERENCES transactions(id),
    FOREIGN KEY(product_ids) REFERENCES products(id)
);

-- Intento esborrar el contingut de la taula companies per procedir a la importació de dades "manual"
DELETE FROM companies;

-- No em deixa pq estic en mode segur. Desactivo. 
SET SQL_SAFE_UPDATES = 0;

-- Rebo un altre error per les Foreing Keys:
SET FOREIGN_KEY_CHECKS = 0;

-- Esborro i torno a activar:
DELETE FROM companies;
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

-- Intento importar els arxius de companies "manualment"
LOAD DATA INFILE 'G:/Mi unidad/ESTUDIS/TECH/IT ACADEMY/DATA ANALISIS/2. SQL/S4.01. Creació de Base de Dades/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- per ignorar els títols de les columnes

-- Em dona error --secure-file-priv i haig de buscar la carpeta segura al meu PC
SHOW VARIABLES LIKE 'secure_file_priv';

-- Intento importar els arxius de companies "manualment" desde la carpeta segura
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- per ignorar els títols de les columnes




/* 1.1. Exercici 1
Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules. */

SELECT name, surname, city, country
FROM users
WHERE id IN
(
	SELECT user_id
	FROM transactions
	GROUP BY user_id
	HAVING COUNT(id) > 30
);

/* -- Query per trobar els ids dels usuaris amb més de 30 transaccions:

SELECT COUNT(id) AS NumTransaccions, user_id
FROM transactions
GROUP BY user_id
HAVING NumTransaccions > 30
ORDER BY NumTransaccions DESC;

-- Query per aïllar només els ids dels usuaris amb més de 30 transaccions:
SELECT user_id
FROM transactions
GROUP BY user_id
HAVING COUNT(id) > 30
ORDER BY COUNT(id) DESC;
*/

/* 1.2. Exercici 2
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules. */

SELECT c.company_name, cc.iban, ROUND(AVG(t.amount),2) AS Mitja
FROM transactions t
JOIN companies c
ON t.business_id = c.company_id
JOIN credit_cards cc
ON t.card_id = cc.id
WHERE c.company_name = 'Donec Ltd'
GROUP BY t.business_id, t.card_id;

/* -- Trobant l'amount de l'empresa Donec Ltd
SELECT c.company_name, ROUND(AVG(t.amount),2) AS Mitja
FROM transactions t
JOIN companies c
ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd' AND declined = 0
GROUP BY t.business_id;

-- Trobant el company_id de targeta de la empresa Donec Ltd: b-2242
SELECT company_id
FROM companies
WHERE company_name = 'Donec Ltd';

-- Comprobant que Donec Ltd només té una targeta de crèdit: CcU-2973
SELECT card_id, business_id
FROM transactions
WHERE business_id =
(
	SELECT company_id
	FROM companies
	WHERE company_name = 'Donec Ltd'
); */


-- ---------------------------------------------------------------------------------------------------------------------------------------

/* Nivell 2

Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades
i genera la següent consulta: */

-- hi ha 275 targetes 
SELECT distinct id
FROM credit_cards;

-- també aquí 275
SELECT distinct card_id
FROM transactions;

-- veiem que només 9 targetes tenen més de 3 transaccions. La resta 2 o menys
SELECT card_id, COUNT(declined)
FROM transactions
GROUP BY card_id
ORDER BY COUNT(declined) DESC;

-- Aquestes són les 9 targetes suceptibles d'estar inactives
SELECT card_id, COUNT(declined)
FROM transactions
GROUP BY card_id
HAVING COUNT(declined) > 2
ORDER BY COUNT(declined) DESC;

-- Cap targeta amb 3, o més, transaccions té 3 transaccions rebutjades. Ja no cal mirar les 3 últimes
SELECT card_id, SUM(declined)
FROM transactions
GROUP BY card_id
HAVING COUNT(declined) > 2
ORDER BY SUM(declined) DESC;


/* -- Les targetes amb només una transacció no tenen cap moviment cancel·lat
SELECT card_id, declined
FROM transactions
WHERE card_id IN
(
	SELECT card_id
	FROM transactions
	GROUP BY card_id
	HAVING COUNT(declined) = 1
);

-- Les targetes amb 2 transaccions ...
SELECT card_id, SUM(declined)
FROM transactions
WHERE card_id IN
(
	SELECT card_id
	FROM transactions
	GROUP BY card_id
	HAVING COUNT(declined) = 2
)
GROUP BY card_id
ORDER BY card_id DESC; */

-- Canvio la columna declined de BOOLEAN a INT per poder sumar (tot i que crec que pot ser no calia) 
ALTER TABLE transactions MODIFY COLUMN declined INT;

-- Creant la taula que es demana a l'enunciat
CREATE TABLE IF NOT EXISTS card_status
(
	id VARCHAR(10) PRIMARY KEY,
	status BOOLEAN,
    FOREIGN KEY(id) REFERENCES credit_cards(id)  
);

-- I afegeixo una FK amb la taula transaccions
SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE transactions ADD CONSTRAINT transactions_ibfk4 FOREIGN KEY (card_id) REFERENCES card_status(id);
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------------------------------------------------------------------------

/* Nivell 3

Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de
transaction tens product_ids. Genera la següent consulta:

3.1. Exercici 1
Necessitem conèixer el nombre de vegades que s'ha venut cada producte. */

SELECT COUNT(pt.id) AS Vendes, p.product_name AS Producte
FROM products_transactions pt
LEFT JOIN products p
ON pt.product_ids = p.id
WHERE pt.id IN
(
	SELECT t.id
	FROM transactions t
	WHERE t.declined = 0
)
GROUP BY pt.product_ids
ORDER BY Vendes DESC;

/* -- Transaccions efectuades correctament (sense declinar)
SELECT id
FROM transactions
WHERE declined = 0; */

