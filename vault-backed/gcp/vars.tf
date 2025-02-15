# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Variables for TFE/TFC
variable "google_project" {
  type = string
  description = "google project id"
}

variable "google_region" {
  type = string
  default = "europe-west3"
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with Vault"
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  default     = "dynamic_creds"
  description = "The project under which a workspace will be created"
}

variable "tfc_workspace_name" {
  type        = string
  default     = "vault-backed-gcp-auth"
  description = "The name of the workspace that you'd like to create and connect to GCP"
}

# Variables for Vault

variable "vault_namespace" {
  type = string
  description = "vault namespace where auth and secrets are created"
}

variable "vault_url" {
  type        = string
  description = "The URL of the Vault instance you'd like to use with Terraform Cloud"
}

variable "jwt_backend_path" {
  type        = string
  default     = "gitlab_jwt"
  description = "The path at which you'd like to mount the jwt auth backend in Vault"
}

variable "tfc_vault_audience" {
  type        = string
  default     = "vault.workload.identity"
  description = "The audience value to use in run identity tokens"
}