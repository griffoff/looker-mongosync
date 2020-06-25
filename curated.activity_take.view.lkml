view: curated_takes {
  derived_table: {
    sql:
    SELECT
        take_node.USER_IDENTIFIER  AS user_identifier,
        take_node.SUBMISSION_DATE  AS submission_date,
        take_node.COURSE_URI  AS course_uri,
        take_node.EXTERNAL_TAKE_URI  AS external_take_uri,
        take_node.EXTERNAL_PROPERTIES  AS external_properties_raw,
        LOWER(take_node.ACTIVITY_URI)  AS activity_uri,
        take_node.activity_node_uri as activity_node_uri
        activity_type_map.activity_type_uri AS activity_type_uri,
        take_node.FINAL_GRADE:scored::boolean  AS final_grade_scored,
        take_node.FINAL_GRADE:taken::boolean  AS final_grade_taken,
        take_node.FINAL_GRADE:normalScore::float  AS final_grade_score,
        try_cast(nullif(take_node.FINAL_GRADE:timeSpent::string, '') AS decimal(18, 6)) / 60 / 60 / 24 AS final_grade_timespent,
        take_node.HASH  AS hash,
        take_node.ACTIVITY
      FROM ${take_node.SQL_TABLE_NAME} AS take_node
      LEFT JOIN ${activity_type_map.SQL_TABLE_NAME} AS activity_type_map ON (LOWER(take_node.ACTIVITY_TYPE_URI)) = activity_type_map.activity_type_uri_source

      WHERE
        (
        UPPER(activity_type_map.activity_type_uri) <> UPPER('als-pete')
        OR activity_type_map.activity_type_uri IS NULL
        )
      AND NOT is_survey
      AND NOT mastery_item
      --GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
      );;
  }
}

view: curated_activity_take {
  derived_table: {
#     explore_source: take_node_activity {
#       column: user_identifier {field:take_node.user_identifier}
#       column: submission_date {field: take_node.submission_raw}
#       column: course_uri {field:take_node.course_uri}
#       column: external_take_uri {field:take_node.external_take_uri}
#       column: external_properties_raw {field:take_node.external_properties_raw}
#       column: activity_uri {field:take_node.activity_uri}
#       column: activity_type_uri {field:activity_type_map.activity_type_uri}
#       column: final_grade_scored {field: take_node.final_grade_scored}
#       column: final_grade_taken {field: take_node.final_grade_taken}
#       column: final_grade_score {field: take_node.final_grade_score}
#       column: final_grade_timespent {field: take_node.final_grade_timespent}
#       column: take_count {field:take_node.count}
#       column: hash {field: take_node.hash}
#       #sort: {field: take_node.activity_uri}
#       #sort: {field: take_node.user_identifier}
#       filters: [take_node.activity: "yes"]
#     }
    create_process: {
      sql_step:
      CREATE OR REPLACE TABLE LOOKER_SCRATCH.curated_activity_take AS (
      SELECT
        user_identifier,
        submission_date,
        course_uri,
        external_take_uri,
        external_properties_raw,
        activity_uri,
        activity_type_uri,
        final_grade_scored,
        final_grade_taken,
        final_grade_score,
        final_grade_timespent,
        hash,
        COUNT(*) as take_count
      FROM ${curated_takes.SQL_TABLE_NAME}
      WHERE activity
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
      ORDER BY submission_date
      ;;

      sql_step: ALTER TABLE looker_scratch.curated_activity_take cluster by (submission_date::date)
      ;;

      sql_step: create or replace table ${SQL_TABLE_NAME} CLONE looker_scratch.curated_activity_take
      ;;
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
    value_format: "[m]:ss \m\i\n\s"
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
  dimension: external_properties_raw {
    group_label: "External Properties"
    type: string
  }
  dimension: difficulty {
    group_label: "External Properties"
    type: number
    sql:  ${external_properties_raw}:"cengage:book:item:difficulty"::FLOAT;;
  }
  dimension: problem_type {
    group_label: "External Properties"
    type: string
    sql:  ${external_properties_raw}:"cengage:book:item:problem-type"::STRING;;
  }
  dimension: item_name {
    group_label: "External Properties"
    type: string
    sql:  ${external_properties_raw}:"cengage:book:item:name"::STRING;;
  }

  measure: count {
    label: "# Takes"
    type: count
  }
  measure: final_grade_score_average {
    group_label: "Score"
    type: average
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_min {
    group_label: "Score"
    type: min
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_q1 {
    group_label: "Score"
    type: percentile
    percentile: 25
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_median {
    group_label: "Score"
    type: median
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_q3 {
    group_label: "Score"
    type: percentile
    percentile: 75
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_max {
    group_label: "Score"
    type: max
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }

  measure: final_grade_timespent_average {
    type: average
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_min {
    group_label: "Time spent"
    type: min
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_q1 {
    group_label: "Time spent"
    type: percentile
    percentile: 25
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_median {
    group_label: "Time spent"
    type: median
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_q3 {
    group_label: "Time spent"
    type: percentile
    percentile: 75
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_max {
    group_label: "Time spent"
    type: max
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

}
