DROP VIEW IF EXISTS contact_summary_clean;
DROP VIEW IF EXISTS accounts_clean;
DROP VIEW IF EXISTS invoices_clean;

DROP TABLE IF EXISTS contact_log;
DROP TABLE IF EXISTS invoices_raw;
DROP TABLE IF EXISTS accounts_raw;

CREATE TABLE accounts_raw (
  id SERIAL PRIMARY KEY,
  customer_name VARCHAR(150),
  email VARCHAR(150),
  phone VARCHAR(50),
  status VARCHAR(50),
  created_at VARCHAR(50)
);

CREATE TABLE invoices_raw (
  id SERIAL PRIMARY KEY,
  account_id INTEGER REFERENCES accounts_raw(id),
  amount_due VARCHAR(50),
  due_date DATE,
  invoice_status VARCHAR(30)
);

CREATE TABLE contact_log (
  id SERIAL PRIMARY KEY,
  account_id INTEGER REFERENCES accounts_raw(id),
  contact_date DATE,
  channel VARCHAR(20),
  outcome VARCHAR(50)
);