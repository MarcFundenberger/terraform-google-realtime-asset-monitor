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

locals {
  service_name = "monitor"
}

resource "google_service_account" "microservice_sa" {
  project      = var.project_id
  account_id   = local.service_name
  display_name = "RAM monitor"
  description  = "Solution: Real-time Asset Monitor, microservice: monitor"
}

resource "google_project_iam_member" "project_profiler_agent" {
  project = var.project_id
  role    = "roles/cloudprofiler.agent"
  member  = "serviceAccount:${google_service_account.microservice_sa.email}"
}

resource "google_pubsub_topic" "compliance_status" {
  project = var.project_id
  name    = var.compliance_status_topic_name
  message_storage_policy {
    allowed_persistence_regions = var.pubsub_allowed_regions
  }
}

resource "google_pubsub_topic_iam_member" "compliance_status_publisher" {
  project = google_pubsub_topic.compliance_status.project
  topic   = google_pubsub_topic.compliance_status.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.microservice_sa.email}"
}

resource "google_pubsub_topic_iam_member" "compliance_status_viewer" {
  project = google_pubsub_topic.compliance_status.project
  topic   = google_pubsub_topic.compliance_status.name
  role    = "roles/pubsub.viewer"
  member  = "serviceAccount:${google_service_account.microservice_sa.email}"
}

resource "google_pubsub_topic" "violation" {
  project = var.project_id
  name    = var.violation_topic_name
  message_storage_policy {
    allowed_persistence_regions = var.pubsub_allowed_regions
  }
}

resource "google_pubsub_topic_iam_member" "violation_publisher" {
  project = google_pubsub_topic.violation.project
  topic   = google_pubsub_topic.violation.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.microservice_sa.email}"
}

resource "google_pubsub_topic_iam_member" "violation_viewer" {
  project = google_pubsub_topic.compliance_status.project
  topic   = google_pubsub_topic.violation.name
  role    = "roles/pubsub.viewer"
  member  = "serviceAccount:${google_service_account.microservice_sa.email}"
}

resource "google_cloud_run_service" "crun_svc" {
  project  = var.project_id
  name     = local.service_name
  location = var.crun_region

  template {
    spec {
      containers {
        image = "${var.ram_container_images_registry}/${local.service_name}:${var.ram_microservice_image_tag}"
        resources {
          limits = {
            cpu    = "${var.crun_cpu}"
            memory = "${var.crun_memory}"
          }
        }
        env {
          name  = "MONITOR_COMPLIANCE_STATUS_TOPIC_ID"
          value = google_pubsub_topic.compliance_status.name
        }
        env {
          name  = "MONITOR_ENVIRONMENT"
          value = terraform.workspace
        }
        env {
          name  = "MONITOR_LOG_ONLY_SEVERITY_LEVELS"
          value = var.log_only_severity_levels
        }
        env {
          name  = "MONITOR_PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "MONITOR_START_PROFILER"
          value = var.start_profiler
        }
        env {
          name  = "MONITOR_VIOLATION_TOPIC_ID"
          value = google_pubsub_topic.violation.name
        }
      }
      container_concurrency = var.crun_concurrency
      timeout_seconds       = var.crun_timeout_seconds
      service_account_name  = google_service_account.microservice_sa.email
    }
    metadata {
      annotations = {
        "run.googleapis.com/client-name"   = "terraform"
        "autoscaling.knative.dev/maxScale" = "${var.crun_max_instances}"
      }
    }
  }
  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal"
    }
  }
  autogenerate_revision_name = true
  traffic {
    percent         = 100
    latest_revision = true
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "google_service_account" "eva_trigger_sa" {
  project      = var.project_id
  account_id   = "${local.service_name}-trigger"
  display_name = "RAM monitor trigger"
  description  = "Solution: Real-time Asset Monitor, microservice tigger: monitor"
}
data "google_iam_policy" "binding" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_service_account.eva_trigger_sa.email}",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "trigger_invoker" {
  location = google_cloud_run_service.crun_svc.location
  project  = google_cloud_run_service.crun_svc.project
  service  = google_cloud_run_service.crun_svc.name

  policy_data = data.google_iam_policy.binding.policy_data
}

resource "google_eventarc_trigger" "eva_trigger" {
  name            = local.service_name
  location        = google_cloud_run_service.crun_svc.location
  project         = google_cloud_run_service.crun_svc.project
  service_account = google_service_account.eva_trigger_sa.email
  transport {
    pubsub {
      topic = var.eva_transport_topic_id
    }
  }
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_service.crun_svc.name
      region  = google_cloud_run_service.crun_svc.location
    }
  }
}
