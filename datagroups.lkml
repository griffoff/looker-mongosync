datagroup: realtime_default_datagroup {
  #sql_trigger: SELECT current_date();;
  sql_trigger: select floor(datediff(hour, '2018-01-22 06:00:00', current_timestamp())) / 24 ;;
  #max_cache_age: "24 hours"
}

datagroup: mindtap_snapshot {
  sql_trigger: Select * from mindtap.prod_nb.org  ;;
}
