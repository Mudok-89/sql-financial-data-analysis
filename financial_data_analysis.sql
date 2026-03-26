SELECT * FROM account;

SELECT *
FROM loan;
SELECT * FROM disp ;

SELECT * FROM client;

SELECT * FROM district;

SELECT * FROM order ;

SELECT * FROM trans;

SELECT * FROM card;



-- 1. primární a cizí klíče:
-- Loan – pk: loan_id, ck: account_id
-- Order  - pk: order_id, ck: account_id
-- Trans – pk: trans_id, ck: account_id
-- Card – pk:  card_id, ck: disp_id
-- Disp – pk: disp_id, ck: client_id, account_id
-- Account – pk: account_id, ck: district_id
-- Client – pk: client_id, ck: district_id
-- District – pk: district_id,

-- Vztahy ve  financial databázi:
-- 1.	client – district (1:N): Jeden okres (district) může mít více klientů (client), ale každý klient patří pouze do jednoho okresu.
-- 2.	account – client – disp (N:M skrze disponenty): Jeden klient může mít více účtů, ale účet může mít více disponentů. Vztah se realizuje skrze tabulku disp.
-- 3.	account – loan (1:N): Jeden účet může mít více půjček (loan), ale každá půjčka patří k jednomu účtu.
-- 4.	account – trans (1:N): Každý účet může mít mnoho transakcí (trans), ale každá transakce patří k jednomu účtu.
-- 5.	disp – card (1:N): Každý disponent (disp) může mít více karet (card), ale každá karta patří jen jednomu disponentovi.
-- 6.	account – order (1:N): Jeden účet může mít mnoho platebních příkazů (order), ale každý platební příkaz patří jen k jednomu účtu.


-- 2.HISTORIE POSKYTNUTÝCH ÚVĚRŮ

SELECT *
FROM loan;

-- year, quarter, month,

SELECT
    year(date) as loan_year,
    quarter(date) as loan_quarter,
    month(date) as loan_month,

    sum(amount) as total_amount_of_loans,
    avg(amount) as average_loan_amount,
    count(loan_id) as total_number_of_given_loans
FROM loan
GROUP BY loan_year, loan_quarter, loan_month
ORDER BY loan_year, loan_quarter, loan_month;

-- year, quarter
SELECT
    year(date) as loan_year,
    quarter(date) as loan_quarter,
    sum(amount) as total_amount_of_loans,
    avg(amount) as average_loan_amount,
    count(loan_id) as total_number_of_given_loans
FROM loan
GROUP BY loan_year, loan_quarter WITH ROLLUP
ORDER BY loan_year DESC, loan_quarter DESC;

-- year,

SELECT
    year(date) as loan_year,
    sum(amount) as total_amount_of_loans,
    avg(amount) as average_loan_amount,
    count(loan_id) as total_number_of_given_loans
FROM loan
GROUP BY loan_year WITH ROLLUP
ORDER BY loan_year DESC;


-- total
SELECT
    sum(amount) as total_amount_of_loans,
    avg(amount) as average_loan_amount,
    count(loan_id) as total_number_of_given_loans
FROM loan;


-- 3. STAV PŮJČKY

-- stavy půjček: splacené a nesplacené

-- Dle informací je 606 splacených a 76 nesplacených
SELECT
    status,
    count(status) as loan_count
FROM loan
group by status
order by status;

-- Zjistili jsme že řádky A a C odpovídají splaceným půjčkám a B a D nesplaceným půjčkám.



-- 4.ANALÝZA ÚČTŮ

-- ověření nulových hodnot u amount
SELECT COUNT(*) - COUNT(amount) AS null_amounts FROM loan;
-- dilema zda použít count loan_id nebo jen count(amount) viz výše jsem zjišťovala zda má amount nulové hodnoty
-- potom dilema jakou funkcí seřadit, tak jsem použila Dense_rank jako první
-- potom jsem ze zadání nepochopila, že si mám tvořit CTE, tak jsem Dense_Rank aplikovala v prvním selectu....
-- následně jsem to rozdělila a pak jsem se snažila pochopit proč použít Row_number místo Dense_rank

WITH ranked_accounts_pa_5 AS (
    SELECT
        account_id,
        COUNT(amount) AS count_loans,
        SUM(amount) AS loans_amount,
        AVG(amount) AS avg_loan_amount
    FROM loan
    WHERE status IN ('A', 'C')  -- Pouze plně splacené půjčky
    GROUP BY account_id
)
SELECT *,
        -- Pořadí podle počtu půjček (sestupně)
        DENSE_RANK() OVER (ORDER BY count_loans DESC) AS row_num_by_total_loans,
        -- Pořadí podle celkové částky půjček (sestupně)
        DENSE_RANK() OVER (ORDER BY loans_amount DESC) AS row_num_by_total_amount
FROM ranked_accounts_pa_5;


WITH ranked_accounts_pa_6 AS (
    SELECT
        account_id,
        COUNT(amount) AS count_loans,
        SUM(amount) AS loans_amount,
        AVG(amount) AS avg_loan_amount
    FROM loan
    WHERE status IN ('A', 'C')  -- Pouze plně splacené půjčky
    GROUP BY account_id
)
SELECT *,
        -- Pořadí podle počtu půjček (sestupně)
        ROW_NUMBER() OVER (ORDER BY count_loans DESC) AS row_num_by_total_loans,
        -- Pořadí podle celkové částky půjček (sestupně)
        ROW_NUMBER() OVER (ORDER BY loans_amount DESC) AS row_num_by_total_amount
FROM ranked_accounts_pa_6;


-- 5. PLNĚ SPLACENÉ PŮJČKY (FULLY PAID LOANS)

-- a)  Zjistěte zůstatek splacených úvěrů rozdělený podle pohlaví klienta.
-- b)  Kromě toho použijte metodu podle svého výběru ke kontrole správnosti dotazu.


-- potřebuji spojit tabulky loan a client   - musíme napojit loan -> account ->  disp ->  client
-- rozdělit podle pohlaví klienta
-- zůstatek splacených úvěrů   the balance of repaid loans

SELECT
    SUM(amount) as zustatek_splacenych_pujcek,
    gender
FROM loan l
join account a on a.account_id = l.account_id
join disp d on d.account_id = a.account_id
join client c on c.client_id = d.client_id
WHERE status IN ('A', 'C')
  AND d.type = 'OWNER'  -- Pouze vlastníci účtů
group by gender;

-- b) ověření dotazu
-- 1.Zkontroluji, zda jsou zahrnuty jen splacené půjčky:
SELECT status, COUNT(*) FROM loan GROUP BY status;
-- 2.Zkontroluji, že loan.account_id správně odpovídá client.gender:
SELECT client.gender, COUNT(*)
FROM loan
JOIN account ON loan.account_id = account.account_id
JOIN disp ON account.account_id = disp.account_id
JOIN client ON disp.client_id = client.client_id
GROUP BY client.gender;



-- 6. ANALÝZA KLIENTA - 1.ČÁST

-- a) Kdo má více splácených půjček – ženy nebo muži?
-- cvičný dotaz než ho dáme do cte
SELECT
       c.gender,
       SUM(l.amount) AS zustatek_splacenych_pujcek
FROM loan l
JOIN account a ON a.account_id = l.account_id
JOIN disp d ON d.account_id = a.account_id -- Správné spojení účtu s disponenty
JOIN client c ON c.client_id = d.client_id -- Správné spojení klienta s disponentem
WHERE TRUE
    AND l.status IN ('A', 'C') -- Pouze splacené půjčky
    AND d.type = 'OWNER'  -- Pouze vlastníci účtů
GROUP BY c.gender;

-- Muži mají splaceno 43.256.388 Kč
-- Ženy mají splaceno 44.425.200 Kč

-- Rozdíl zjistíme takto:
DROP TABLE IF EXISTS total_repaid_gender_pa;
With total_repaid_gender_pa as (
SELECT
       c.gender,
       SUM(l.amount) AS zustatek_splacenych_pujcek
FROM loan l
JOIN account a ON a.account_id = l.account_id
JOIN disp d ON d.account_id = a.account_id -- Správné spojení účtu s disponenty
JOIN client c ON c.client_id = d.client_id -- Správné spojení klienta s disponentem
WHERE TRUE
    AND l.status IN ('A', 'C') -- Pouze splacené půjčky
    AND d.type = 'OWNER'  -- Pouze vlastníci účtů
GROUP BY c.gender
)

SELECT
    MAX(CASE WHEN gender = 'F' THEN zustatek_splacenych_pujcek END) -
    MAX(CASE WHEN gender = 'M' THEN zustatek_splacenych_pujcek END) AS rozdil_mezi_pohlavimi
FROM total_repaid_gender_pa;

-- Ženy mají splaceno více než muži o 1.168.812 Kč

-- Průměrný věk dlužníka podle pohlaví

DROP TABLE IF EXISTS total_repaid_gender_pa_1;
With total_repaid_gender_pa_1 as (SELECT c.gender,
                                         2024 - extract(year from birth_date) as age,

                                         SUM(l.amount)                        AS zustatek_splacenych_pujcek
                                  FROM loan l
                                           JOIN account a ON a.account_id = l.account_id
                                           JOIN disp d
                                                ON d.account_id = a.account_id -- Správné spojení účtu s disponenty
                                           JOIN client c ON c.client_id = d.client_id -- Správné spojení klienta s disponentem
                                  WHERE l.status IN ('A', 'C') -- Pouze splacené půjčky
                                    AND d.type = 'OWNER'       -- Pouze vlastníci účtů
                                  GROUP BY c.gender, age)

SELECT
    gender,
    AVG(age) AS prumerny_vek_dluznika
FROM total_repaid_gender_pa_1
GROUP BY gender;

-- Průměrný věk dlužníků činí 66.5 let
-- Průměrný věk dlužnic je 64.5 let


-- Analýza klienta - 2 část

-- A) Která oblast(město) má nejvíce klientů?
SELECT * FROM client;
SELECT * FROM district;
SELECT * FROM disp;

SELECT
    d.district_id,
    d.A2 as město,
    count(distinct c.client_id) as pocet_klientu
FROM district d
join client c on c.district_id = d.district_id
join disp on c.client_id = disp.client_id
group by d.district_id, město
order by pocet_klientu DESC;

-- Nejvíce klientů 547 je v hlavním městě Praha.
-- Nicméně zapomněla jsem na ty vlastníky účtu...
-- vyřešíme dole v souhrnné CTE...

-- B) Ve které oblasti bylo vyplaceno nejvíce úvěrů?

SELECT
    d.district_id,
    d.A2 as město,
    count(l.loan_id) počet_úvěrů
FROM loan l
join account a on l.account_id = a.account_id
join disp disp on a.account_id = disp.account_id
join client c on disp.client_id = c.client_id
join district d on c.district_id = d.district_id
WHERE disp.type = 'OWNER'
group by d.district_id, město
order by počet_úvěrů DESC;

-- Nejvíce vyplacených úvěrů bylo vyplaceno v Praze - celkem 84.--- níže  zjistíme že jich je jen 73

-- C) ve které oblasti byla vyplacena nejvyšší částka úvěrů

SELECT
    d.district_id,
    d.A2 as město,
    SUM(amount) celkový_počet_úvěrů,
    count(l.loan_id) počet_úvěrů
FROM loan l
join account a on l.account_id = a.account_id
join disp disp on a.account_id = disp.account_id
join client c on disp.client_id = c.client_id
join district d on c.district_id = d.district_id
WHERE True
    AND l.status IN ('A', 'C')
    AND disp.type = 'OWNER'
group by d.district_id, město
order by celkový_počet_úvěrů DESC;

-- Nejvyšší částka úvěrů 10.502.628 Kč byla vyplacena v Praze


--- Zde je potřeba vše spojit do CTE pokládat potom dotazy
DROP TABLE IF EXISTS tmp_district_analytics_pa_1;
CREATE TEMPORARY TABLE tmp_district_analytics_pa_1 AS (
    SELECT
        d.district_id,
        d.A2 as město,

        count(distinct c.client_id) as pocet_klientu,
        SUM(amount) celkový_počet_úvěrů,
        count(l.loan_id) počet_úvěrů
    FROM loan l
        join account a on l.account_id = a.account_id
        join disp disp on a.account_id = disp.account_id
        join client c on disp.client_id = c.client_id
        join district d on c.district_id = d.district_id
    WHERE True
        AND l.status IN ('A', 'C')
        AND disp.type = 'OWNER'
    group by d.district_id, město
    );
                -- A) Která oblast(město) má nejvíce klientů? - Praha
SELECT * FROM tmp_district_analytics_pa_1
ORDER BY pocet_klientu DESC
LIMIT 1;
                -- B) Nejvyšší částka úvěrů 10.502.628 Kč a byla vyplacena v Praze
SELECT * FROM tmp_district_analytics_pa_1
ORDER BY celkový_počet_úvěrů DESC
LIMIT 1;

             -- C)Nejvíce vyplacených úvěrů bylo vyplaceno v Praze - celkem 73.
SELECT * FROM tmp_district_analytics_pa_1
ORDER BY počet_úvěrů DESC
LIMIT 1;


-- ANALÝZA KLIENTŮ 3.ČÁST
DROP TABLE IF EXISTS cte_district_loans_summary_pa;

WITH cte_district_loans_summary_pa as(SELECT
        d.district_id,
        d.A2 as město,

        count(distinct c.client_id) as pocet_klientu,
        SUM(amount) celkový_počet_úvěrů,
        count(l.loan_id) počet_úvěrů
    FROM loan l
        join account a on l.account_id = a.account_id
        join disp disp on a.account_id = disp.account_id
        join client c on disp.client_id = c.client_id
        join district d on c.district_id = d.district_id
    WHERE True
        AND l.status IN ('A', 'C')
        AND disp.type = 'OWNER'
    group by d.district_id, město
)

SELECT *,
       celkový_počet_úvěrů/ SUM(celkový_počet_úvěrů) OVER () AS procentualni_podil
FROM cte_district_loans_summary_pa
order by procentualni_podil DESC;


-- Výběr  - 1 část
-- Zobrazit klienty, kteří mají account ballance(loan amount-payments) vyšší než 1000, mají více než 5 půjček, narodili se po roce 1990
SELECT
    c.client_id,
    SUM(amount - payments) as zustatek_uctu,
    COUNT(loan_id) AS pocet_pujcek
FROM loan l
        join account a on l.account_id = a.account_id
        join disp disp on a.account_id = disp.account_id
        join client c on disp.client_id = c.client_id
WHERE True
        AND l.status IN ('A', 'C')
        AND disp.type = 'OWNER'
        AND EXTRACT(YEAR FROM c.birth_date) > 1990
GROUP BY c.client_id
HAVING
    SUM(amount - payments) > 1000
    AND COUNT(loan_id) > 5;

-- VÝSLEDEK JE PRÁZDNÝ

-- VÝBĚR - 2 ČÁST - ANALÝZA PODMÍNKY, KTERÁ ZPŮSOBILA PRÁZDNÉ VÝSLEDKY

-- 1- ODSTRANÍME PODMÍNKY V HAVING - COŽ UKAZUJE,TAK ČI TAK PRÁDZNÁ DATA. PO ODSTRANĚNÍ VÍCE NEŽ 5 PŮJČEK, SE ZOBRAZÍ STEJNĚ PRÁZDNÉ HODNOTY
-- MUSELA TO ZPŮSOBIT PODMÍNKA VE WHERE - FILTROVÁNÍ PODLE DATA NAROZENÍ
    --  V databázi nejspíš nejsou žádní klienti narození po roce 1990.
    --
SELECT
    c.client_id,
    SUM(amount - payments) as zustatek_uctu,
    COUNT(loan_id) AS pocet_pujcek
FROM loan l
        join account a on l.account_id = a.account_id
        join disp disp on a.account_id = disp.account_id
        join client c on disp.client_id = c.client_id
WHERE True
        AND l.status IN ('A', 'C')
        AND disp.type = 'OWNER'
        AND EXTRACT(YEAR FROM c.birth_date) > 1990
GROUP BY c.client_id
HAVING
    SUM(amount - payments) > 1000;


SELECT
    c.client_id, c.birth_date
FROM client c
WHERE EXTRACT(YEAR FROM c.birth_date) > 1990;


-- KONČÍCÍ KARTY

-- Napsat proceduru pro obnovení vytvořené tabulky ( nazvat JI např. cards_at_expiration)
DELIMITER $$

CREATE PROCEDURE UpdateExpiringCards_pa()
BEGIN
    -- 1. Smazání existující tabulky, pokud existuje
    DROP TABLE IF EXISTS cards_at_expiration_pa;

    -- 2. Vytvoření nové tabulky
    CREATE TABLE cards_at_expiration_pa (
        client_id INT,
        card_id INT,
        expiration_date DATE,
        client_address VARCHAR(255) -- Sloupec A3 z district
    );

    -- 3. Naplnění tabulky daty o kartách, které expirují tento týden
    INSERT INTO cards_at_expiration_pa (client_id, card_id, expiration_date, client_address)
    SELECT
        c.client_id,
        cr.card_id,
        DATE_ADD(cr.issued, INTERVAL 3 YEAR) as expiration_date,
        d.A3 as client_address
    FROM card cr
    join disp disp on cr.disp_id = disp.disp_id
    join client c on disp.client_id = c.client_id
    join district d on c.district_id = d.district_id
    WHERE DATE_ADD(cr.issued, INTERVAL 3 YEAR) - INTERVAL 7 DAY <= CURDATE()
          AND DATE_ADD(cr.issued, INTERVAL 3 YEAR) >= CURDATE();
END $$
DELIMITER ;

CALL UpdateExpiringCards_pa();

SELECT * FROM cards_at_expiration_pa;

