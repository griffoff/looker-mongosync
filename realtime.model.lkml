connection: "snowflake_dev"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

datagroup: realtime_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "24 hours"
}

persist_with: realtime_default_datagroup
