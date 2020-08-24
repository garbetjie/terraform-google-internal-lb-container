resource google_bigquery_dataset logging {
  dataset_id = "logging"
  location = "EU"
}

resource google_bigquery_table logs {
  dataset_id = google_bigquery_dataset.logging.dataset_id
  table_id = "logs"
  clustering = ["channel", "correlation_id"]

  time_partitioning {
    type = "DAY"
    require_partition_filter = true
    field = "ts"
  }

  schema = jsonencode([
    { name = "ts", type = "TIMESTAMP" },
    { name = "correlation_id", type = "STRING" },
    { name = "level", type = "INTEGER" },
    { name = "level_name", type = "STRING" },
    { name = "channel", type = "STRING" },
    { name = "message", type = "STRING" },
    { name = "context", type = "STRING" },
    { name = "extra", type = "STRING" },
    { name = "labels", type = "RECORD", mode = "REPEATED", fields = [
      { name = "key", type = "STRING" },
      { name = "value", type = "STRING" }
    ] },
  ])
}
