resource google_service_account fluentd {
  account_id = "fluentd"
  description = "fluentd bigquery log insertion (managed by terraform)"
}

resource google_bigquery_dataset_iam_binding fluentd {
  dataset_id = google_bigquery_dataset.logging.dataset_id
  members = ["serviceAccount:${google_service_account.fluentd.email}"]
  role = "roles/bigquery.dataEditor"
}
