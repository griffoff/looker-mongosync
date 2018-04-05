view: curated_activity {
  derived_table: {
    explore_source: take_node_activity {
      column: activity_final_grade_score_avg { field: take_node.activity_final_grade_score_avg }
      column: activity_final_grade_score_max { field: take_node.activity_final_grade_score_max }
      column: activity_final_grade_score_min { field: take_node.activity_final_grade_score_min }
      column: activity_final_grade_score_sd { field: take_node.activity_final_grade_score_sd }
      column: activity_final_grade_timespent_avg { field: take_node.activity_final_grade_timespent_avg }
      column: activity_final_grade_timespent_max { field: take_node.activity_final_grade_timespent_max }
      column: activity_final_grade_timespent_min { field: take_node.activity_final_grade_timespent_min }
      column: activity_final_grade_scored { field: take_node.activity_final_grade_scored }
      column: activity_handler { field: product_activity_metadata.handler }
      column: activity_type { field: product_activity_metadata.activity_type }
      column: activity_engine { field: product_activity_metadata.activity_engine }
      column: activity_source_system { field: product_activity_metadata.source_system }
      column: activity_core_isbn { field: product_activity_metadata.core_isbn }
      column: activity_product { field: product_activity_metadata.product }
      column: activity_product_code { field: product_activity_metadata.product_code }
      column: activity_link { field: product_activity_metadata.link }
      column: activity_name { field: product_activity_metadata.name }
      column: activity_uri { field: take_node.activity_uri }
      column: activity_type_uri { field: take_node.activity_type_uri }
      column: course_count { field: take_node.course_count }
      column: take_count { field: take_node.take_count }
    }
    datagroup_trigger: realtime_default_datagroup
  }

  dimension: activity_final_grade_score_avg {
    group_label: "Activity metrics"
    label: "Score (avg)"
    value_format_name: percent_1
    type: number
  }
  dimension: activity_final_grade_score_avg_buckets {
    group_label: "Activity metrics"
    label: "Score (avg) buckets"
    type: tier
    tiers: [0.1, 0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    style: relational
    sql: ${activity_final_grade_score_avg} ;;
    value_format_name: percent_0
  }
  dimension: activity_final_grade_score_max {
    group_label: "Activity metrics"
    label: "Score (max)"
    value_format_name: percent_1
    type: number
  }
  dimension: activity_final_grade_score_min {
    group_label: "Activity metrics"
    label: "Score (min)"
    value_format_name: percent_1
    type: number
  }
  dimension: activity_final_grade_score_sd {
    group_label: "Activity metrics"
    label: "Score (sd)"
    value_format_name: percent_1
    type: number
  }
  dimension: activity_final_grade_timespent_avg {
    group_label: "Activity metrics"
    label: "Time spent (avg)"
    value_format_name: duration_hms
    type: number
  }
  dimension: activity_final_grade_scored {
    type: yesno
    label: "Scored?"
  }
  dimension: activity_final_grade_timespent_min {
    group_label: "Activity metrics"
    label: "Time spent (min)"
    value_format_name: duration_hms
    type: number
  }

  dimension: activity_final_grade_timespent_max {
    group_label: "Activity metrics"
    label: "Time spent (max)"
    value_format_name: duration_hms
    type: number
  }

  dimension: activity_uri {primary_key: yes}
  dimension: activity_type_uri {}
  dimension: activity_handler {}
  dimension: activity_type {}
  dimension: activity_engine {}
  dimension: activity_source_system {}
  dimension: activity_core_isbn {}
  dimension: activity_product {}
  dimension: activity_product_code {}
  dimension: activity_link {}
  dimension: activity_name {}

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
    label: "# Activities"
    type: count
  }
}
