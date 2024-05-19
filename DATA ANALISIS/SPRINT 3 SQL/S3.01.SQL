# NIVELL 1 

/* 1.1. Exercici 1
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules
("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.*/


 -- Creem la taula credit_card
   CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(15) PRIMARY KEY,
        iban VARCHAR(50),
        pan VARCHAR(50),
        pin INT,
        cvv INT,
        expiring_date DATE
    );

-- Genero aquesta foreing key sense voler
ALTER TABLE transaction ADD CONSTRAINT fk_credit_card_id FOREIGN KEY (company_id) REFERENCES company(id);

-- L'esborro
ALTER TABLE transaction DROP FOREIGN KEY fk_credit_card_id;

-- Ara genero la Foreing Key correcta per conectar la nova taula credit_card amb la taula transaction
ALTER TABLE transaction ADD CONSTRAINT fk_CreditCardID FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);


/* 1.2. Exercici 2
El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. La informació que ha de mostrar-se
per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.*/

-- busquem les dades
SELECT *
FROM credit_card
WHERE id = 'CcU-2938';

-- canviem l'IBAN
UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';


/* 1.3. Exercici 3
En la taula "transaction" ingressa un nou usuari amb la següent informació: */

SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO transaction VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, NULL, 111.11, 0);
SET FOREIGN_KEY_CHECKS = 1;

-- Comprovem que les dades s'han inserit correctament:
SELECT *
FROM transaction;


/* 1.4. Exercici 4
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat. */

-- Eliminem la columna pan
ALTER TABLE credit_card DROP COLUMN pan;

-- Comprovem que ja no hi és:
SELECT *
FROM credit_card;



# NIVELL 2

/* 2.1. Exercici 1
Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades. */

DELETE FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- comprovació:
SELECT * 
FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';


/* 2.2. Exercici 2
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les 
companyies i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. 
País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra. */

CREATE VIEW `VistaMarketing` AS
SELECT c.company_name, c.phone, c.country, ROUND(AVG(t.amount),2) AS mitja
FROM transaction t
LEFT JOIN company c
ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.id
ORDER BY mitja DESC;

-- Comprovem que funciona
SELECT *
FROM VistaMarketing;

-- Implemento canvis als títols
ALTER VIEW vistamarketing AS
SELECT c.company_name AS Nom, c.phone AS Telefon, c.country AS País, ROUND(AVG(t.amount),2) AS Mitja
FROM transaction t
LEFT JOIN company c
ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.id
ORDER BY mitja DESC;


/* 2.3. Exercici 3
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany". */

SELECT *
FROM VistaMarketing
WHERE País = 'Germany';


# Nivell 3

/* 3.1. Exercici 1
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions a la base de dades, però no recorda com les va realitzar. 
Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama: */

  -- Creamos la tabla user
CREATE INDEX idx_user_id ON transaction(user_id);
 
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
        FOREIGN KEY(id) REFERENCES transaction(user_id)        
    );

-- Veig que la Foreign Key s'ha creat al revés. L'esborrem:
ALTER TABLE user DROP FOREIGN KEY user_ibfk_1;

-- Ara generem la Foreing Key correcta:
SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE transaction ADD CONSTRAINT user_ibfk FOREIGN KEY (user_id) REFERENCES user(id);
SET FOREIGN_KEY_CHECKS = 1;

-- Provo el canvi a credit_card.id de tipus de dades
ALTER TABLE credit_card MODIFY COLUMN id VARCHAR(20);

-- Provo el canvi de INT a VARCHAR(4) a credit_card.pin
ALTER TABLE credit_card MODIFY COLUMN pin VARCHAR(4);

-- Generem una PK composta per crear relacions fortes entre les taules credit_card, transaction i user:
ALTER TABLE transaction DROP PRIMARY KEY, ADD PRIMARY KEY(id, credit_card_id, user_id);



/* 3.2. Exercici 2
L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:

ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari. */

CREATE VIEW `InformeTecnicoinformetecnico` AS
SELECT t.id AS ID_transacció, u.name AS Nom_Usuari, u.surname AS Cognom_usuari, cc.iban AS IBAN, c.company_name AS Nom_empresa
FROM transaction t
LEFT JOIN user u
ON t.user_id = u.id
LEFT JOIN credit_card cc
ON t.credit_card_id = cc.id
LEFT JOIN company c
ON t.company_id = c.id; 

/* Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction. */
SELECT *
FROM transactions.informetecnico
ORDER BY ID_transacció;
