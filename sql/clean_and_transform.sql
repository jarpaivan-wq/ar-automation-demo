DROP VIEW IF EXISTS accounts_clean;
DROP VIEW IF EXISTS invoices_clean;
DROP VIEW IF EXISTS contact_summary_clean;

CREATE VIEW invoices_clean AS
SELECT
  id,
  account_id,
  CAST(REGEXP_REPLACE(amount_due, '[^0-9.]', '', 'g') AS NUMERIC) AS amount_due,
  due_date,
  LOWER(TRIM(invoice_status)) AS invoice_status,
  CASE
    WHEN due_date < CURRENT_DATE AND LOWER(TRIM(invoice_status)) != 'paid'
    THEN CURRENT_DATE - due_date
    ELSE 0
  END AS days_overdue
FROM invoices_raw;

CREATE VIEW accounts_clean AS
SELECT
  a.id,
  INITCAP(TRIM(a.customer_name)) AS customer_name,
  COALESCE(a.email, 'no-email-on-file@unknown.com') AS email,
  a.phone,
  LOWER(TRIM(a.status)) AS status,
  CASE
    WHEN a.created_at ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN TO_DATE(a.created_at, 'MM/DD/YYYY')
    WHEN a.created_at ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(a.created_at, 'YYYY-MM-DD')
    WHEN a.created_at ~ '^\d{1,2}-\d{1,2}-\d{4}$' THEN TO_DATE(a.created_at, 'DD-MM-YYYY')
    ELSE NULL
  END AS created_at,
  CASE
    WHEN COALESCE(MAX(i.days_overdue), 0) > 60 THEN 'high'
    WHEN COALESCE(MAX(i.days_overdue), 0) > 30 THEN 'medium'
    ELSE 'low'
  END AS risk_level
FROM accounts_raw a
LEFT JOIN invoices_clean i ON a.id = i.account_id
GROUP BY a.id, a.customer_name, a.email, a.phone, a.status, a.created_at;

CREATE VIEW contact_summary_clean AS
SELECT
  account_id,
  COUNT(*) AS total_contacts,
  MAX(contact_date) AS last_contact_date,
  COUNT(CASE WHEN outcome = 'payment promised' THEN 1 END) AS promises_made,
  COUNT(CASE WHEN outcome = 'spoke with customer' THEN 1 END) AS successful_contacts
FROM contact_log
GROUP BY account_id;