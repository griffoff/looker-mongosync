include:"curated.activity_take.view"
view: curated_item_take {
  extends: [curated_activity_take]
  derived_table: {
#     explore_source: take_node_item {
#       column: activity_item_uri {field: take_node.activity_node_uri}
#       filters: [take_node.activity: "no"]
#     }
    create_process: {
    sql_step:
      CREATE OR REPLACE TABLE LOOKER_SCRATCH.curated_item_take
      AS
      SELECT
        user_identifier,
        submission_date,
        course_uri,
        external_take_uri,
        external_properties_raw,
        activity_uri,
        activity_node_uri,
        activity_type_uri,
        final_grade_scored,
        final_grade_taken,
        final_grade_score,
        final_grade_timespent,
        hash,
        COUNT(*) as take_count
      FROM ${curated_takes.SQL_TABLE_NAME}
      WHERE NOT activity
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
      ORDER BY submission_date
      ;;

      sql_step: ALTER TABLE looker_scratch.curated_item_take cluster by (submission_date::date)
        ;;

      sql_step: create or replace table ${SQL_TABLE_NAME} CLONE looker_scratch.curated_item_take
        ;;
    }
  }
  dimension: activity_item_uri {}

  measure: final_grade_percent_correct {
    group_label: "Score"
    type: number
    sql: COUNT(CASE WHEN ${final_grade_scored} AND ${final_grade_score} != 0 THEN 1 END) / NULLIF(COUNT(CASE WHEN ${final_grade_scored} THEN 1 END), 0);;
    value_format_name: percent_1
  }

  dimension: difficulty {
    hidden: no
  }
  dimension: problem_type {
    hidden: no
  }
  dimension: item_name {
    hidden: no
  }
  measure: final_grade_score_average {
    hidden: yes
  }
  measure: final_grade_score_min {
    hidden: yes
  }
  measure: final_grade_score_q1 {
    hidden: yes
  }
  measure: final_grade_score_median {
    hidden: yes
  }
  measure: final_grade_score_q3 {
    hidden: yes
  }
  measure: final_grade_score_max {
    hidden: yes
  }

}
