view: curated_activity_take {
  derived_table: {
    explore_source: take_node_activity {
      column: user_identifier {field:take_node.user_identifier}
      column: submission_date {field: take_node.submission_raw}
      column: course_uri {field:take_node.course_uri}
      column: external_take_uri {field:take_node.external_take_uri}
      column: activity_uri {field:take_node.activity_uri}
      column: activity_type_uri {field:activity_type_map.activity_type_uri}
      column: final_grade_scored {field: take_node.final_grade_scored}
      column: final_grade_taken {field: take_node.final_grade_taken}
      column: final_grade_score {field: take_node.final_grade_score}
      column: final_grade_timespent {field: take_node.final_grade_timespent}
      column: take_count {field:take_node.count}
      column: hash {field: take_node.hash}
      sort: {field: take_node.activity_uri}
      sort: {field: take_node.user_identifier}
    }
    datagroup_trigger: realtime_default_datagroup
  }
  dimension: user_identifier {}
  dimension_group: submission_date {
    label: "Submission"
    type: time
    timeframes: [time, date, day_of_week, month, year]
  }
  dimension: course_uri {}
  dimension: external_take_uri {}
  dimension: activity_uri {}
  dimension: activity_type_uri {}
  dimension: final_grade_score_tiers {
    label: "Score Bucket"
    value_format_name: percent_1
    type: tier
    tiers: [0.4, 0.6, 0.7, 0.8, 0.9]
    style: relational
    sql: ${final_grade_score} ;;
  }
  dimension: final_grade_scored {
    label: "Scored?"
    type: yesno
  }
  dimension: final_grade_taken {
    label: "Taken?"
    type: yesno
  }
  dimension: final_grade_score {
    label: "Score"
    value_format_name: percent_1
    type: number
  }
  dimension: final_grade_timespent {
    label: "Time spent"
    value_format_name: duration_hms
    type: number
  }
  dimension: take_count {
    #from source - can be used to validate the granularity/uniqueness of this data
    label: "# Takes"
    type: number
    hidden: yes
  }
  dimension: hash {
      primary_key:yes
      hidden:yes
  }
  measure: count {
    type: count
  }
}
