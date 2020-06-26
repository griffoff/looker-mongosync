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
        take_node.activity_node_uri as activity_node_uri,
        activity_type_map.activity_type_uri AS activity_type_uri,
        take_node.FINAL_GRADE:scored::boolean  AS final_grade_scored,
        take_node.FINAL_GRADE:taken::boolean  AS final_grade_taken,
        take_node.FINAL_GRADE:normalScore::float  AS final_grade_score,
        take_node.FINAL_GRADE:possibleScore::float  AS final_grade_possiblescore,
        take_node.FINAL_GRADE:scaledScore::float  AS final_grade_scaledscore,
        take_node.INTERACTION_GRADE:attempts::int  AS attempts,
        --cap time spent at 2 hrs
        least(7200, try_cast(nullif(take_node.FINAL_GRADE:timeSpent::string, '') AS decimal(18, 6))) / 60 / 60 / 24 AS final_grade_timespent,
        take_node.HASH  AS hash,
        take_node.ACTIVITY
      FROM ${take_node.SQL_TABLE_NAME} AS take_node
      LEFT JOIN ${activity_type_map.SQL_TABLE_NAME} AS activity_type_map ON (LOWER(take_node.ACTIVITY_TYPE_URI)) = activity_type_map.activity_type_uri_source

      WHERE
        (
        UPPER(activity_type_map.activity_type_uri) <> UPPER('als-pete')
        OR activity_type_map.activity_type_uri IS NULL
        )
      AND NOT mastery_item
      --GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
      ;;
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
      CREATE OR REPLACE TABLE LOOKER_SCRATCH.curated_activity_take
      AS
      WITH q AS (
        SELECT
            external_take_uri
            ,COUNT(*) as total_questions
            ,COUNT(CASE WHEN final_grade_scored THEN 1 END) as total_scored_questions
            ,SUM(attempts) as total_question_attempts
            ,AVG(attempts) as avg_question_attempts
            ,COUNT(NULLIF(attempts, 0)) as questions_attempted
            ,COUNT(CASE WHEN final_grade_scored THEN NULLIF(attempts, 0) END) as scored_questions_attempted
            ,COUNT(CASE WHEN final_grade_scored AND final_grade_score = 1 THEN 1 END) / NULLIF(COUNT(CASE WHEN final_grade_scored THEN 1 END), 0) as percent_questions_correct
            ,COUNT(CASE WHEN final_grade_scored AND final_grade_score = 1 AND attempts = 1 THEN 1 END) / NULLIF(COUNT(CASE WHEN final_grade_scored THEN 1 END), 0) as percent_questions_correct_attempt_1
            ,COUNT(CASE WHEN final_grade_scored AND final_grade_score = 1 AND attempts <= 2 THEN 1 END) / NULLIF(COUNT(CASE WHEN final_grade_scored THEN 1 END), 0) as percent_questions_correct_attempt_2
        FROM ${curated_takes.SQL_TABLE_NAME}
        WHERE NOT activity
        GROUP BY 1
      )
      SELECT
        a.user_identifier,
        a.submission_date,
        a.course_uri,
        a.external_take_uri,
        a.external_properties_raw,
        a.activity_uri,
        a.activity_type_uri,
        a.final_grade_scored,
        a.final_grade_taken,
        a.final_grade_score,
        a.final_grade_timespent,
        a.hash,
        q.total_questions,
        q.total_scored_questions,
        q.total_question_attempts,
        q.scored_questions_attempted,
        q.avg_question_attempts,
        q.questions_attempted,
        q.percent_questions_correct,
        q.percent_questions_correct_attempt_1,
        q.percent_questions_correct_attempt_2,
        COUNT(*) as take_count
      FROM ${curated_takes.SQL_TABLE_NAME} a
      LEFT JOIN q ON a.external_take_uri = q.external_take_uri
      WHERE activity
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21
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
  dimension: total_questions {
    group_label: "Questions"
    label: "# Questions"
    type: number
  }
  dimension: total_scored_questions {
    group_label: "Questions"
    label: "# Scored questions"
    type: number
  }
  dimension: total_question_attempts {
    group_label: "Questions"
    label: "Total attempts for all questions"
    type: number
  }
  dimension: avg_question_attempts {
    group_label: "Questions"
    label: "Avgerage attempts per question"
    type: number
  }
  measure: avg_attempts_per_question {
    group_label: "Questions"
    type: number
    sql: SUM(${total_question_attempts}) / SUM(${questions_attempted}) ;;
    value_format_name: decimal_1
  }
  dimension: questions_attempted {
    group_label: "Questions"
    label: "# Questions attempted"
    type: number
  }
  dimension: scored_questions_attempted {
    group_label: "Questions"
    label: "# Scored questions attempted"
    type: number
  }
  dimension: percent_questions_attempted {
    group_label: "Questions"
    label: "% Questions attempted"
    type: number
    sql: ${questions_attempted} / ${total_questions} ;;
    value_format_name: percent_0
  }
  dimension: pecent_scored_questions_attempted {
    group_label: "Questions"
    label: "% Scored questions attempted"
    type: number
    sql: ${scored_questions_attempted} / ${total_scored_questions} ;;
    value_format_name: percent_0
  }
  dimension: percent_questions_correct {
    group_label: "Questions"
    label: "% Questions correct"
    type: number
    value_format_name: percent_0
  }
  dimension: percent_questions_correct_attempt_1 {
    group_label: "Questions"
    label: "% Questions correct (1st attempt)"
    type: tier
    style: relational
    tiers: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    value_format_name: percent_0
  }
  dimension: percent_questions_correct_attempt_2 {
    group_label: "Questions"
    label: "% Questions correct (2 attempts or less)"
    type: tier
    style: relational
    tiers: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    value_format_name: percent_0
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
    hidden: yes
    group_label: "External Properties"
    type: number
    sql:  ${external_properties_raw}:"cengage:book:item:difficulty"::FLOAT;;
  }
  dimension: problem_type {
    group_label: "External Properties"
    hidden: yes
    type: string
    sql:  ${external_properties_raw}:"cengage:book:item:problem-type"::STRING;;
  }
  dimension: item_name {
    group_label: "External Properties"
    hidden: yes
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
  measure: final_grade_score_p90 {
    group_label: "Score"
    type: percentile
    percentile: 90
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
    group_label: "Time spent"
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
  measure: final_grade_timespent_p90 {
    group_label: "Time spent"
    type: percentile
    percentile: 90
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
