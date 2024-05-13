/* NIVELL 1

Exercici 1

A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. Mostra les característiques principals de l'esquema
creat i explica les diferents taules i variables que existeixen. Assegura't d'incloure un diagrama que il·lustri la relació entre les 
diferents taules i variables.*/

/* Mirant el diagrama veiem que les dues taules es relacionen entre sí a partir dels camps id (1), de la taula company,
amb el camp: company_id (N), de la taula transactions.
*/

SELECT *
FROM company;

/* La taula COMPANY és una taula amb dades de diferents empreses. Consta del camp ID que és la CLAU PRIMÀRIA d'aquesta taula,
i els següents camps contenen la resta de dades:

	- COMPANY_NAME són els diferents noms de les empreses que apareixen a la taula.
	- PHONE conté els teléfons
	- EMAIL conté les direccions de cooreu electrònic
	- COUNTRY indica el país
	- WEBSITE el domini web
*/

SELECT * 
FROM transaction;

/* La taula TRANSACTION conté totes les dades d'unes transaccions fetes, relacionades a través del camp COMPANY_ID amb la taula anterior.
A més consta dels seguents camps:

	- ID és la clau primaria de la taula
	- CREDIT_CARD_ID conté els identificadors de les targetes de crèdit que s'han fet servir per realitzar la transacció
	- USER_ID usuari que ha realitzat la transacció
	- LAT indica la latitud de la ubicació d'és d'on s'ha realitzat la transacció
	- LONGITUDE indica la longitud de la ubicació d'és d'on s'ha realitzat la transacció
    - TIMESTAMP la data i la hora a la que es va realitzar
    - AMOUNT la quantitat per la qual es va fer
    - DECLINED si la transacció va ser acceptada o no
*/


/* 1. Exercici 2

Utilitzant JOIN realitzaràs les següents consultes:

 1.2.1 Llistat dels països que estan fent compres.*/

SELECT distinct country
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
ORDER BY country;

# 1.2.2 Des de quants països es realitzen les compres.

SELECT COUNT(distinct country) AS països
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
ORDER BY country;

# 1.2.3 Identifica la companyia amb la mitjana més gran de vendes.

SELECT company_name, ROUND(AVG(amount),2) AS mitja
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY company_name
ORDER BY mitja DESC
LIMIT 1;

/*# aquí comprovant que funciona si fem la mitja manualment
SELECT company_id, SUM(amount) AS Total, COUNT(amount) AS transactions, SUM(amount) / COUNT(amount) AS media, declined
FROM transaction
WHERE declined = 0
GROUP BY company_id
ORDER BY media DESC;

#i aquí una proba sense el JOIN
SELECT company_id, AVG(amount) AS average, declined
FROM transaction
WHERE declined = 0
GROUP BY company_id
ORDER BY average DESC;
*/


/* 1. Exercici 3
Utilitzant només subconsultes (sense utilitzar JOIN):

1.3.1 Mostra totes les transaccions realitzades per empreses d'Alemanya.*/

SELECT *
FROM transaction
WHERE company_id IN
(
	SELECT id
	FROM company
	WHERE country = "Germany"
);


# 1.3.2 Llista les empreses que han realitzat transaccions per un amount superior a la mitja de totes les transaccions.

SELECT company_name
FROM company
WHERE id IN
(
	SELECT company_id
	FROM transaction
	WHERE amount >
	(
		SELECT AVG(amount)
		FROM transaction
	)
);

/*
#Trobant la mitja
SELECT AVG(amount)
FROM transaction;

#Comprovant que la mitja és correcta (càlcul "manual")
SELECT SUM(amount) AS Total, COUNT(amount) AS transactions, SUM(amount) / COUNT(amount) AS media
FROM transaction;

#Filtrant les transaccions per les superiors a la mitja total
SELECT company_id, amount
FROM transaction
WHERE amount > 256
ORDER BY amount;

#Provant WHERE per trobar "manualment" el nom de les empreses
SELECT id, company_name
FROM company
WHERE id IN ('b-2226', 'b-2230');
*/

# 1.3.3 Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT id, company_name
FROM company
HAVING id NOT IN
(
	SELECT company_id
	FROM transaction
	GROUP BY company_id
);
#No hi ha cap empresa sense transaccions :)

/*
#587 transactions en total
SELECT id, company_id
FROM transaction;

#100 empreses en total. Totes amb transaccions:
SELECT company_id, count(id)
FROM transaction
GROUP BY company_id;

#Subquery amb tots el company_id
SELECT company_id
FROM transaction
GROUP BY company_id;

#Totes les empreses
SELECT id, company_name
FROM company;
*/





/* NIVELL 2

2. Exercici 1

Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
Mostra la data de cada transacció juntament amb el total de les vendes.
*/

SELECT DATE(timestamp) AS data, SUM(amount) AS total
FROM transaction
WHERE declined = 0
GROUP BY data
ORDER BY total DESC
LIMIT 5;


/* 2. Exercici 2

Quina és la mitja de vendes per país? Presenta els resultats ordenats de major a menor mitja.*/

SELECT country, ROUND(AVG(amount),2) AS mitja
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY country
ORDER BY mitja desc;

/*#comprovació manual amb mitja calculada
SELECT country, sum(amount) AS total, count(amount) AS quantitat, sum(amount)/count(amount) AS mitja_calculada
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY country
ORDER BY mitja_calculada desc;
*/


/* 2. Exercici 3

A la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia
"Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el
mateix país que aquesta companyia.*/

#2.3.1 Mostra el llistat aplicant JOIN i subconsultes.

SELECT transaction.*
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE country =
(
	SELECT country
	FROM company
	WHERE company_name = 'Non Institute'
);

/*# País de l'empresa Non Institute: UK
SELECT country
FROM company
WHERE company_name = 'Non Institute';*/

#2.3.2 Mostra el llistat aplicant solament subconsultes.

SELECT * 
FROM transaction
HAVING company_id IN 
(
	SELECT id
	FROM company
	WHERE country =
	(
		SELECT country
		FROM company
		WHERE company_name = 'Non Institute'
	)
);

/*#Tots els ids de les empreses de UK
SELECT id
FROM company
WHERE country =
(
	SELECT country
	FROM company
	WHERE company_name = 'Non Institute'
);*/




# NIVELL 3

/* 3. Exercici 1

Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.*/

SELECT company_name, phone, DATE(timestamp) AS data, amount
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE amount BETWEEN 100 AND 200 AND DATE(timestamp) IN ('2021-04-29', '2021-07-20','2022-03-13')
ORDER BY amount DESC;

/* 3. Exercici 2

Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació
sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses
on especifiquis si tenen més de 4 transaccions o menys.*/


SELECT
	company_name AS Empresa,
    COUNT(transaction.id) AS NumTransaccions,
	IF(COUNT(transaction.id) > 4, 'Més de 4', 'Menor o igual a 4') AS transacciones_status
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
GROUP BY company_name
ORDER BY NumTransaccions DESC;
