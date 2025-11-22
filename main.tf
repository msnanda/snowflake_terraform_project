terraform {
  required_providers {
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
resource "snowflake_sql" "run_init_sql" {
  name = "init_sql"
  sql  = file("${path.module}/SQLs/createTable_employee.sql")

  # Ensure the database is created before running the SQL
  depends_on = [snowflake_database.demo_db]
}
