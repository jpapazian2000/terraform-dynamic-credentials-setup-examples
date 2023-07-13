# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.46.0"
    }
  }
}
provider "tfe" {
  
  hostname = var.tfc_hostname
}

#get project_id
data "tfe_project" "gitlab" {
  name = var.tfc_project_name
  organization = var.tfc_organization_name
}

# Runs in this workspace will be automatically authenticated
# to Vault with the permissions set in the Vault policy.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization_name
  project_id = data.tfe_project.gitlab.id
}
#Creation of the variable set
resource "tfe_variable_set" "dynamic_creds" {
  name          = "Dynamic Creds Variable set"
  description   = "Vault Backed Dynamic creds for tfcb run"
  organization  = var.tfc_organization_name
}
# Add variable sets to project
resource "tfe_project_variable_set" "proj_var_set" {
  variable_set_id = tfe_variable_set.dynamic_creds.id
  project_id      = data.tfe_project.gitlab.id
}
# The following variables must be set to allow runs
# to authenticate to GCP.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_vault_provider_auth" {
  key      = "TFC_VAULT_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for Vault."
  variable_set_id = tfe_variable_set.dynamic_creds.id
}

resource "tfe_variable" "tfc_vault_addr" {
  key       = "TFC_VAULT_ADDR"
  value     = var.vault_url
  category  = "env"
  sensitive = true

  description = "The address of the Vault instance runs will access."
  variable_set_id = tfe_variable_set.dynamic_creds.id
}

resource "tfe_variable" "tfc_vault_role" {
  key      = "TFC_VAULT_RUN_ROLE"
  value    = vault_jwt_auth_backend_role.tfc_role.role_name
  category = "env"

  description = "The Vault role runs will use to authenticate."
  variable_set_id = tfe_variable_set.dynamic_creds.id
}

resource "tfe_variable" "tfc_vault_namespace" {
  key      = "TFC_VAULT_NAMESPACE"
  value    = var.vault_namespace
  category = "env"

  description = "Namespace that contains the GCP Secrets Engine."
  variable_set_id = tfe_variable_set.dynamic_creds.id
}

resource "tfe_variable" "enable_gcp_provider_auth" {
  key      = "TFC_VAULT_BACKED_GCP_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Vault Secrets Engine integration for GCP."
  variable_set_id = tfe_variable_set.dynamic_creds.id
}

resource "tfe_variable" "tfc_gcp_mount_path" {
  key      = "TFC_VAULT_BACKED_GCP_MOUNT_PATH"
  value    = "gcp"
  category = "env"

  description = "Path to where the GCP Secrets Engine is mounted in Vault."
  variable_set_id = tfe_variable_set.dynamic_creds.id
}

resource "tfe_variable" "tfc_gcp_auth_type" {
  key      = "TFC_VAULT_BACKED_GCP_AUTH_TYPE"
  value    = "roleset/${vault_gcp_secret_roleset.gcp_secret_roleset.secret_type}"
  category = "env"

  description = "Type of credential to acquire via the GCP Secrets Engine in Vault."
  variable_set_id = tfe_variable_set.dynamic_creds.id
}

resource "tfe_variable" "tfc_gcp_run_vault_roleset" {
  key      = "TFC_VAULT_BACKED_GCP_RUN_VAULT_ROLESET"
  value    = vault_gcp_secret_roleset.gcp_secret_roleset.roleset
  category = "env"

  description = "Id of the GCP roleset the run will assume."
  variable_set_id = tfe_variable_set.dynamic_creds.id
}

# The following variables are optional; uncomment the ones you need!

 resource "tfe_variable" "tfc_vault_auth_path" {
#   workspace_id = tfe_workspace.my_workspace.id

   key      = "TFC_VAULT_AUTH_PATH"
   value    = var.jwt_backend_path
   category = "env"

   description = "The path where the jwt auth backend is mounted, if not using the default"
   variable_set_id = tfe_variable_set.dynamic_creds.id
 }

# resource "tfe_variable" "tfc_vault_audience" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_VAULT_WORKLOAD_IDENTITY_AUDIENCE"
#   value    = var.tfc_vault_audience
#   category = "env"

#   description = "The value to use as the audience claim in run identity tokens"
# }