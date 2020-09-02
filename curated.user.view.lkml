view: curated_user {
  derived_table: {
    create_process: {
      sql_step:
        CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME}
        AS
        SELECT
          activity_take.user_identifier AS user_identifier,
          AVG(activity_take.final_grade_score) AS activity_final_grade_score_avg,
          MAX(activity_take.final_grade_score ) AS activity_final_grade_score_max,
          MIN(activity_take.final_grade_score ) AS activity_final_grade_score_min,
          STDDEV(activity_take.final_grade_score)  AS activity_final_grade_score_sd,
          AVG(activity_take.final_grade_timespent) AS activity_final_grade_timespent_avg,
          SUM(activity_take.final_grade_timespent) AS activity_final_grade_timespent_sum,
          COUNT(CASE WHEN item_take.final_grade_score = 1 THEN 1 END) / (NULLIF(COUNT(CASE WHEN item_take.attempts > 0 THEN 1 END), 0)) AS item_final_score_correct_percent,
          AVG(item_take.final_grade_timespent ) AS item_final_score_timespent_avg,
          MAX(activity_take.submission_date ) AS latest_submission_date,
          COUNT(DISTINCT course.primary_key) AS course_count,
          COUNT(DISTINCT activity_take.hash) AS take_count
        FROM LOOKER_SCRATCH.LR$JJM721599041600589_realtime_course AS course
        LEFT JOIN LOOKER_SCRATCH.LR$JJ4GW1599043047265_course_activity AS course_activity ON course.COURSE_URI = course_activity.COURSE_URI
        LEFT JOIN LOOKER_SCRATCH.LR$JJS951599042011659_course_enrollment AS course_enrollment ON course.COURSE_URI = course_enrollment.COURSE_URI
        LEFT JOIN LOOKER_SCRATCH.LR$JJJ5S1599083900374_curated_activity_take AS activity_take ON course_activity.COURSE_URI = activity_take.course_uri
                  and course_activity.ACTIVITY_URI = activity_take.activity_uri
                  and course_enrollment.user_identifier = activity_take.user_identifier
        LEFT JOIN looker_scratch.item_take_items  AS item_take ON (activity_take.external_take_uri) = (item_take.external_take_uri)

        GROUP BY 1
        ORDER BY user_identifier
        ;;

      sql_step:
        ALTER TABLE ${SQL_TABLE_NAME} CLUSTER BY (user_identifier);;

    }
    datagroup_trigger: realtime_default_datagroup
  }

  dimension: activity_final_grade_score_avg {
    group_label: "Activity metrics"
    label: "Score (avg)"
    value_format_name: percent_1
    type: number
  }
  dimension: activity_final_grade_score_avg_bucket {
    group_label: "Activity metrics"
    label: "Score buckets (avg)"
    value_format_name: percent_1
    type: tier
    tiers: [0.4, 0.6, 0.7, 0.8, 0.9]
    style: relational
    sql: ${activity_final_grade_score_avg} ;;
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
  dimension: item_final_score_correct_percent_bucket {
    group_label: "Item metrics"
    label: "Correct buckets (%)"
    value_format_name: percent_1
    type: tier
    tiers: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    style: relational
    sql: ${item_final_score_correct_percent} ;;
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
