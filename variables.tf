/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


variable "project_id" {
  description = "GCP project id where to deploy RAM for a given environment, like test or production"
}

variable "ram_microservice_image_tag" {
  description = "The container image tag for this microservice"
  default     = "latest"
}

variable "log_only_severity_levels" {
  description = "Which type of log entry should be logged"
  default     = "INFO WARNING NOTICE CRITICAL"
}

variable "pubsub_allowed_regions" {
  type    = list(string)
  default = ["europe-west1", "europe-west3", "europe-west4", "europe-north1", "europe-central2"]
}

variable "gcs_location" {
  description = "Cloud Storage location"
  default     = "europe-west1"
}

variable "crun_region" {
  description = "cloud run region"
  default     = "europe-west1"
}

variable "dataset_location" {
  description = "Bigquery dataset location"
  default     = "EU"
}

variable "views_interval_days" {
  description = "The sliding windows in days the view uses to get data. Should not be less than the batch cadence to export assets"
  default     = 28
}

variable "scheduler_region" {
  description = "Cloud Scheduler region"
  default     = "europe-west1"
}

variable "export_org_ids" {
  description = "list of organization id where to grant Cloud Asset Inventory roles to allow export feature"
  type        = list(string)
}

variable "export_folder_ids" {
  description = "list of folder id where to grant Cloud Asset Inventory roles to allow export feature"
  type        = list(string)
}

variable "feed_iam_policy_orgs" {
  description = "For feed type IAM_POLICY, the map of monitored organizations and the targeted list assets for each. Can be empty"
  type        = map(list(string))
  default     = {}
}

variable "feed_resource_orgs" {
  description = "For feed type RESOURCE, the map of monitored organizations and the targeted list assets for each. Can be empty"
  type        = map(list(string))
  default     = {}
}

variable "feed_iam_policy_folders" {
  description = "For feed type IAM_POLICY, the map of monitored folders and the targeted list assets for each. Can be empty"
  type        = map(list(string))
  default     = {}
}

variable "feed_resource_folders" {
  description = "For feed type RESOURCE, the map of monitored folders and the targeted list assets for each. Can be empty"
  type        = map(list(string))
  default     = {}
}

variable "asset_feed_topic_name" {
  description = "the data on which to assess compliance"
  default     = "assetFeed"
}

variable "asset_rule_topic_name" {
  description = "each message combines the data of one asset and the code of one complicance rule's"
  default     = "assetRule"
}

variable "compliance_status_topic_name" {
  description = "compliance status may be true for compliant or false for not compliant for a given asset version and configuration rule version"
  default     = "ram-complianceStatus"
}

variable "violation_topic_name" {
  description = "violations detail why an asset is not compliant to a configuration rule"
  default     = "ram-violation"
}
