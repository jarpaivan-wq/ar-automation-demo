SELECT
  a.id AS account_id,
  a.customer_name,
  a.email,
  a.status,
  COALESCE(SUM(CASE WHEN i.invoice_status != 'paid' THEN i.amount_due ELSE 0 END), 0) AS total_outstanding,
  COALESCE(SUM(CASE WHEN i.invoice_status = 'paid' THEN i.amount_due ELSE 0 END), 0) AS total_paid,
  COALESCE(MAX(i.days_overdue), 0) AS max_days_overdue,
  COALESCE(COUNT(CASE WHEN i.invoice_status = 'overdue' THEN 1 END), 0) AS overdue_invoice_count,
  COALESCE(c.total_contacts, 0) AS total_contacts,
  c.last_contact_date,
  COALESCE(c.promises_made, 0) AS promises_made,
  CASE
    WHEN COALESCE(MAX(i.days_overdue), 0) > 60 THEN 'high'
    WHEN COALESCE(MAX(i.days_overdue), 0) > 30 THEN 'medium'
    ELSE 'low'
  END AS risk_level
FROM accounts_clean a
LEFT JOIN invoices_clean i ON a.id = i.account_id
LEFT JOIN contact_summary_clean c ON a.id = c.account_id
GROUP BY a.id, a.customer_name, a.email, a.status, c.total_contacts, c.last_contact_date, c.promises_made
ORDER BY total_outstanding DESC;