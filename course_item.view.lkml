view: course_item {
  derived_table: {
    explore_source: take_node_item {
      column: activity_node_uri { field: take_node.activity_node_uri }
      column: course_uri { field: take_node.course_uri }
      column: take_count { field: take_node.take_count }
      column: users_taken { field: take_node.users_taken }
      column: times_taken { field: take_node.times_taken }
      column: item_final_score_correct_percent { field: take_node.item_final_score_correct_percent }
      column: item_final_score_timespent_avg { field: take_node.item_final_score_timespent_avg }
      column: final_grade_scored { field: take_node.final_grade_scored }
    }
  }
  dimension: activity_node_uri {}
  dimension: course_uri {}
  dimension: take_count {
    label: "# Takes"
    type: number
  }
  dimension: users_taken {
    label: "# Users taken"
    type: number
  }
  dimension: times_taken {
    label: "# Times taken"
    type: number
  }
  dimension: item_final_score_correct_percent {
    label: "Correct (%)"
    value_format_name: percent_1"
    type: number
  }
  dimension: item_final_score_timespent_avg {
    label: "Time spent (avg)"
    value_format_name: duration_hms
    type: number
  }
  dimension: final_grade_scored {
    label: "Scored? (Yes / No)"
    type: yesno
  }
}
