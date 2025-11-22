terraform {
  required_providers {
    # Use the official Snowflake provider package for Terraform 0.13+
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 1.0.0"
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
resource "snowflake_execute" "run_init_sql" {
  # Execute the SQL file contents inside Snowflake at apply time.
  execute = file("${path.module}/SQLs/createTable_employee.sql")

  # Revert action when the resource is destroyed (drops table and schema).
  revert = <<-SQL
    DROP TABLE IF EXISTS DEMO_DB.DEMO.employee;
    DROP SCHEMA IF EXISTS DEMO_DB.DEMO;
  SQL

  # Ensure the database exists before running the SQL
  depends_on = [snowflake_database.demo_db]
}
