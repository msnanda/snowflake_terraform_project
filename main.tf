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
resource "null_resource" "create_employee_table" {
  triggers = {
    sql_md5 = filemd5("${path.module}/SQLs/createTable_employee.sql")
    db      = var.snowflake_database
  }

  provisioner "local-exec" {
    # Use bash on Linux runners (ubuntu-latest) so GitHub Actions can run snowsql.
    interpreter = ["bash", "-c"]

    command = "snowsql -a \"${var.snowflake_account}\" -u \"${var.snowflake_user}\" -p \"${var.snowflake_password}\" -w \"${var.snowflake_warehouse}\" -d \"${var.snowflake_database}\" -s \"${var.snowflake_schema}\" -f \"${path.module}/SQLs/createTable_employee.sql\" -o exit_on_error=true"
  }
}
