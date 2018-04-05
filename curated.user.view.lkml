view: curated_user {
  derived_table: {
    explore_source: take_node_filtered {
      column: activity_final_grade_score_avg { field: take_node.activity_final_grade_score_avg }
      column: activity_final_grade_score_max { field: take_node.activity_final_grade_score_max }
      column: activity_final_grade_score_min { field: take_node.activity_final_grade_score_min }
      column: activity_final_grade_score_sd { field: take_node.activity_final_grade_score_sd }
      column: activity_final_grade_timespent_avg { field: take_node.activity_final_grade_timespent_avg }
      column: activity_final_grade_timespent_sum { field: take_node.activity_final_grade_timespent_sum }
      column: item_final_score_correct_percent { field: take_node.item_final_score_correct_percent }
      column: item_final_score_timespent_avg { field: take_node.item_final_score_timespent_avg }
      column: latest_submission_date { field: take_node.latest_submission_date }
      column: user_identifier { field: take_node.user_identifier }
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
  dimension: activity_final_grade_timespent_sum {
    group_label: "Activity metrics"
    label: "Time spent (total)"
    value_format_name: duration_hms
    type: number
  }
  dimension: item_final_score_correct_percent {
    group_label: "Item metrics"
    label: "Correct (%)"
    value_format_name: percent_1
    type: number
  }
  dimension: item_final_score_timespent_avg {
    group_label: "Item metrics"
    label: "Time spent (avg)"
    value_format_name: duration_hms
    type: number
  }
  dimension: latest_submission_date {
    type: date_time
  }
  dimension: user_identifier {primary_key: yes}
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
  dimension: take_count {
    label: "# Takes"
    type: number
  }
  measure: count {
    label: "# Users"
    type: count
  }
}
