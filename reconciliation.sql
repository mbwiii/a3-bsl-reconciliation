-- A3 — Syndicated Loan Position Reconciliation
-- AI-DRAFTED reconciliation queries. Matt GOVERNS these (reads, validates, signs off).
-- Two tables: lender_positions (alias "lend") vs agent_positions (alias "agt").
-- A position matches when loan_id + lender match. All queries are READ-ONLY SELECTs.

-- 1) AMOUNT BREAK — same position in both books, par_amount disagrees (e.g., a late-settled trade)
SELECT lend.loan_id, lend.deal_name, lend.lender,
       lend.par_amount AS lender_amt, agt.par_amount AS agent_amt,
       (CAST(lend.par_amount AS INT) - CAST(agt.par_amount AS INT)) AS difference
FROM lender_positions lend
JOIN agent_positions agt ON lend.loan_id = agt.loan_id AND lend.lender = agt.lender
WHERE CAST(lend.par_amount AS INT) <> CAST(agt.par_amount AS INT);

-- 2) MISSING IN AGENT — in the lender's book, absent from the agent's
SELECT lend.loan_id, lend.deal_name, lend.lender, lend.par_amount
FROM lender_positions lend
LEFT JOIN agent_positions agt ON lend.loan_id = agt.loan_id AND lend.lender = agt.lender
WHERE agt.loan_id IS NULL;

-- 3) MISSING IN LENDER — in the agent's book, absent from the lender's
SELECT agt.loan_id, agt.deal_name, agt.lender, agt.par_amount
FROM agent_positions agt
LEFT JOIN lender_positions lend ON agt.loan_id = lend.loan_id AND agt.lender = lend.lender
WHERE lend.loan_id IS NULL;

-- 4) DUPLICATE — same position recorded more than once in the agent's book
SELECT loan_id, deal_name, lender, COUNT(*) AS times_recorded
FROM agent_positions
GROUP BY loan_id, lender
HAVING COUNT(*) > 1;

-- 5) STALE DATE — same position, as_of_date disagrees (a sync-timing break)
SELECT lend.loan_id, lend.deal_name, lend.lender,
       lend.as_of_date AS lender_date, agt.as_of_date AS agent_date
FROM lender_positions lend
JOIN agent_positions agt ON lend.loan_id = agt.loan_id AND lend.lender = agt.lender
WHERE lend.as_of_date <> agt.as_of_date;

-- 6) CURRENCY MISMATCH — same position, booked in different currencies (masks a true difference)
SELECT lend.loan_id, lend.deal_name, lend.lender,
       lend.currency AS lender_ccy, agt.currency AS agent_ccy, lend.par_amount
FROM lender_positions lend
JOIN agent_positions agt ON lend.loan_id = agt.loan_id AND lend.lender = agt.lender
WHERE lend.currency <> agt.currency;
