DROP TABLE IF EXISTS observations, medications, conditions, encounters, patients CASCADE;

CREATE TABLE patients (
  id TEXT PRIMARY KEY,
  birthdate DATE,
  deathdate DATE,
  ssn TEXT,
  drivers TEXT,
  passport TEXT,
  prefix TEXT,
  first TEXT,
  last TEXT,
  suffix TEXT,
  maiden TEXT,
  marital TEXT,
  race TEXT,
  ethnicity TEXT,
  gender TEXT,
  birthplace TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  county TEXT,
  zip TEXT,
  lat FLOAT,
  lon FLOAT,
  healthcare_expenses FLOAT,
  healthcare_coverage FLOAT
);

CREATE TABLE conditions (
  id TEXT PRIMARY KEY,
  start DATE,
  stop DATE,
  patient TEXT,
  encounter TEXT,
  code TEXT,
  description TEXT
);

CREATE TABLE medications (
  id TEXT PRIMARY KEY,
  start DATE,
  stop DATE,
  patient TEXT,
  encounter TEXT,
  code TEXT,
  description TEXT,
  base_cost FLOAT,
  payer TEXT
);

CREATE TABLE encounters (
  id TEXT PRIMARY KEY,
  start DATE,
  stop DATE,
  patient TEXT,
  organization TEXT,
  provider TEXT,
  payer TEXT,
  encounterclass TEXT,
  code TEXT,
  description TEXT,
  cost FLOAT,
  reasoncode TEXT,
  reasondescription TEXT
);

CREATE TABLE observations (
  id TEXT PRIMARY KEY,
  date DATE,
  patient TEXT,
  encounter TEXT,
  code TEXT,
  description TEXT,
  value TEXT,
  units TEXT,
  type TEXT
);
