/**
 * Copyright 2021 Google LLC
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

resource "google_service_account" "microservice_sa" {
  project      = var.project_id
  account_id   = "fetchrules"
  display_name = "RAM fetchrule"
  description  = "Solution: Real-time Asset Monitor, microservice: fetchrules"
}

resource "google_project_iam_member" "project_profiler_agent" {
  project = var.project_id
  role    = "roles/cloudprofiler.agent"
  member  = "serviceAccount:${google_service_account.microservice_sa.email}"
}

resource "google_pubsub_topic" "asset_rule" {
  project = var.project_id
  name    = var.asset_rule_topic_name
  message_storage_policy {
    allowed_persistence_regions = var.pubsub_allowed_regions
  }
}

resource "google_pubsub_topic_iam_member" "asset_rule_publisher" {
  project = google_pubsub_topic.asset_rule.project
  topic   = google_pubsub_topic.asset_rule.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.microservice_sa.email}"
}

resource "google_pubsub_topic_iam_member" "asset_rule_viewer" {
  project = google_pubsub_topic.asset_rule.project
  topic   = google_pubsub_topic.asset_rule.name
  role    = "roles/pubsub.viewer"
  member  = "serviceAccount:${google_service_account.microservice_sa.email}"
}
