view: curated_item {
  derived_table: {
    explore_source: take_node_item {
      column: item_final_score_correct_percent { field: take_node.item_final_score_correct_percent }
      column: item_final_score_timespent_avg { field: take_node.item_final_score_timespent_avg }
      column: activity_node_uri { field: take_node.activity_node_uri }
      column: activity_type_uri { field: take_node.activity_type_uri}
      column: product_code { field: take_node.activity_node_product_code }
      column: item_id { field: take_node.activity_node_item_id }
      column: course_count { field: take_node.course_count }
      column: take_count { field: take_node.take_count }
      column: item_type { field: product_item_metadata.handler }
      column: item_source_system { field: product_item_metadata.source_system }
      column: item_name { field: product_item_metadata.name }
      column: product_discipline { field: product_toc_metadata.discipline }
      column: product { field: product_toc_metadata.product }
      column: product_name { field: product_toc_metadata.name }
      column: product_source_system { field: product_toc_metadata.source_system }
      column: product_abbr { field: product_toc_metadata.abbr }
      column: product_link { field: product_toc_metadata.link }
    }
    datagroup_trigger: realtime_default_datagroup
  }

  dimension: item_final_score_correct_percent {
    group_label: "Item metrics"
    label: "Correct (%)"
    value_format_name: percent_1
    type: number
  }
  dimension: item_final_score_correct_percent_buckets {
    group_label: "Item metrics"
    label: "Correct (%) buckets"
    type: tier
    tiers: [0.1, 0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    style: relational
    sql: ${item_final_score_correct_percent} ;;
    value_format_name: percent_0
  }
  dimension: item_final_score_timespent_avg {
    group_label: "Item metrics"
    label: "Time spent (avg)"
    value_format_name: duration_hms
    type: number
    hidden: yes
  }
  measure: item_final_score_timespent_avg_avg {
    group_label: "Item metrics"
    label: "Time spent (avg of avg)"
    type: average
    sql: ${item_final_score_timespent_avg} ;;
    value_format_name: duration_hms
  }
  dimension: latest_submission_date {
    type: date_time
  }

  dimension: activity_node_uri {primary_key: yes}
  dimension: activity_type_uri {}
  dimension: product_code {}
  dimension: item_id {}

  dimension: item_type {}
  dimension: item_source_system {}
  dimension: item_name {}
  dimension: product_discipline {}
  dimension: product {}
  dimension: product_name {}
  dimension: product_source_system {}
  dimension: product_abbr {}
  dimension: product_link {}

  dimension: course_count {
    label: "# Courses"
    type: number
  }
  dimension: course_count_bucket {
    label: "# Courses (buckets)"
    type: tier
    tiers: [2, 5, 10, 20, 50]
    style: integer
    sql: ${course_count} ;;
  }
  dimension: take_count {hidden:yes}
  measure: take_count_sum {
    label: "# Takes"
    type: sum
    sql: ${take_count} ;;
  }
  measure: take_count_avg {
    label: "# Takes (avg)"
    type: average
    sql: ${take_count} ;;
  }
  measure: count {
    label: "# Items"
    type: count
  }
}
