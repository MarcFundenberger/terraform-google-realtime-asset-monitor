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
  description = "RAM GCP project id for a given environment, like dev or production"
}

variable "cai_feed_topic_name" {
  description = "google cloud asset inventory feed messages"
  default     = "caiFeed"
}

variable "asset_feed_topic_name" {
  description = "the data on which to assess compliance"
  default     = "assetFeed"
}

variable "pubsub_allowed_regions" {
  type    = list(string)
  default = ["europe-west1", "europe-west3", "europe-west4", "europe-north1", "europe-central2"]
}

variable "crun_region" {
  description = "cloud run region"
  default     = "europe-west1"
}

variable "crun_cpu" {
  description = "Number of cpu in k8s quantity 1000m means 1000 millicpu aka 1"
  default     = "1000m"
}
variable "crun_concurrency" {
  description = "Number of requests a container could received at the same time"
  default     = 80
}

variable "crun_max_instances" {
  description = "Max number of instances"
  default     = 1000
}

variable "crun_memory" {
  description = "Memory allocation in k8s quantity "
  default     = "128Mi"
}


variable "crun_timeout_seconds" {
  description = "Max duration for an instance for responding to a request"
  default     = 180
}

variable "ram_container_images_registry" {
  description = "artifact registry path"
  default     = "europe-docker.pkg.dev/brunore-ram-dev-100/realtime-asset-monitor"
}
variable "ram_microservice_image_tag" {
  description = "The container image tag for this microservice"
  default     = "latest"
}
variable "asset_collection_id" {
  description = "firestore assets collection id"
  default     = "assets"
}
variable "cache_max_age_minutes" {
  description = "Duration in minutes after which the asset cache should be reloaded"
  default     = "60"
}
variable "log_only_severity_levels" {
  description = "Which type of log entry should be logged"
  default     = "INFO WARNING NOTICE CRITICAL"
}
variable "owner_label_Key_name" {
  description = "violation owner label tag name"
  default     = "owner"
}
variable "start_profiler" {
  description = "Continuous CPU and heap profiling in Cloud Profiler"
  default     = "false"
}
variable "violation_resolver_label_key_name" {
  description = "violation resolver label tag name"
  default     = "resolver"
}
