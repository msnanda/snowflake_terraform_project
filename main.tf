terraform {
  required_providers {
    # Use the official Snowflake provider package for Terraform 0.13+
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.25.17"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }

  backend "remote" {
    organization = "Maninder"

    workspaces {
      name = "gh-actions-demo"
    }
  }
}

provider "snowflake" {
}

resource "snowflake_database" "demo_db" {
  name    = "DEMO_DB"
  comment = "Database for Snowflake Terraform demo"
}
// Snowflake variables are expected to be provided externally
// (for example: a `variables.tf` file, environment `TF_VAR_*`, or
// in Terraform Cloud/Enterprise workspace variables). Do not duplicate here.

// -------------------------
// Run the create table SQL via snowsql on terraform apply
// This uses a local-exec provisioner. In CI you must ensure `snowsql` is installed
// and credentials are provided (via these variables or environment/CI secrets).
// Running the DDL is triggered whenever the SQL file content changes (filemd5).
// -------------------------
// The employee table and schema are created by the CI step that runs
// `SQLs/createTable_employee.sql` against Snowflake after Terraform applies.
// The SQL execution is performed in the GitHub Actions workflow using the
// Snowflake Python connector.

// Execute the SQL file using the provider's SQL resource (runs DDL inside Snowflake)
resource "snowflake_schema" "demo_schema" {
  name     = "DEMO"
  database = snowflake_database.demo_db.name
  comment  = "Schema for demo objects"

  depends_on = [snowflake_database.demo_db]
}

resource "snowflake_table" "employee" {
  database = snowflake_database.demo_db.name
  schema   = snowflake_schema.demo_schema.name
  name     = "employee1"
  comment  = "Employee table managed by Terraform"

  column {
    name    = "employee_id"
    type    = "NUMBER(38,0)"
    comment = "Primary key"
  }

  column {
    name = "first_name"
    type = "VARCHAR(100)"
  }

  column {
    name = "last_name"
    type = "VARCHAR(100)"
  }

  column {
    name = "email"
    type = "VARCHAR(255)"
  }

  column {
    name = "phone"
    type = "VARCHAR(50)"
  }

  column {
    name = "hire_date"
    type = "DATE"
  }

  column {
    name = "job_id"
    type = "VARCHAR(50)"
  }

  column {
    name = "salary"
    type = "NUMBER(10,2)"
  }

  column {
    name = "department_id"
    type = "NUMBER(38,0)"
  }

  column {
    name = "created_at"
    type = "TIMESTAMP_LTZ"
  }

  column {
    name = "updated_at"
    type = "TIMESTAMP_LTZ"
  }

  # Ensure the schema exists before creating the table
  depends_on = [snowflake_schema.demo_schema]
}
