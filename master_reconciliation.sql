-- A3 Master Reconciliation — lender_positions vs agent_positions
-- Composite key: loan_id + lender. Expected: 8 break rows.
-- Built independently; run and verified by Matt in DB Browser (6/16/2026) — 8 rows, exact match to BREAKS_AnswerKey.
-- All six checks normalized to the same 5 columns so UNION ALL aligns: break_type, loan_id, lender, deal_name, detail.

SELECT 'Amount mismatch' AS break_type, l.loan_id, l.lender, l.deal_name,
       'lender ' || l.par_amount || ' vs agent ' || a.par_amount AS detail
FROM lender_positions l
JOIN agent_positions a ON l.loan_id = a.loan_id AND l.lender = a.lender
WHERE CAST(l.par_amount AS INTEGER) <> CAST(a.par_amount AS INTEGER)

UNION ALL

SELECT 'Stale date', l.loan_id, l.lender, l.deal_name,
       'lender ' || l.as_of_date || ' vs agent ' || a.as_of_date
FROM lender_positions l
JOIN agent_positions a ON l.loan_id = a.loan_id AND l.lender = a.lender
WHERE l.as_of_date <> a.as_of_date

UNION ALL

SELECT 'Currency mismatch', l.loan_id, l.lender, l.deal_name,
       'lender ' || l.currency || ' vs agent ' || a.currency
FROM lender_positions l
JOIN agent_positions a ON l.loan_id = a.loan_id AND l.lender = a.lender
WHERE l.currency <> a.currency

UNION ALL

SELECT 'Missing in agent', l.loan_id, l.lender, l.deal_name,
       'lender ' || l.par_amount || ' / agent (none)'
FROM lender_positions l
LEFT JOIN agent_positions a ON l.loan_id = a.loan_id AND l.lender = a.lender
WHERE a.loan_id IS NULL

UNION ALL

SELECT 'Missing in lender', a.loan_id, a.lender, a.deal_name,
       'agent ' || a.par_amount || ' / lender (none)'
FROM agent_positions a
LEFT JOIN lender_positions l ON a.loan_id = l.loan_id AND a.lender = l.lender
WHERE l.loan_id IS NULL

UNION ALL

SELECT 'Duplicate', loan_id, lender, deal_name,
       'appears ' || COUNT(*) || ' times in agent book'
FROM agent_positions
GROUP BY loan_id, lender, deal_name
HAVING COUNT(*) > 1

ORDER BY break_type, loan_id;
