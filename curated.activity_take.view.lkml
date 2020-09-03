view: final_grade {
  extension: required

  dimension: final_grade_scored {
    group_label: "Score"
    label: "Scored?"
    type: yesno
  }
  dimension: final_grade_scored_value {
    group_label: "Score"
    label: "Scored/Not Scored"
    type: string
    case: {when: {sql: ${final_grade_scored};; label: "Scored"}
      else:"Not Scored"
    }
  }
  dimension: final_grade_score {
    group_label: "Score"
    label: "Final Score"
    value_format_name: percent_1
    type: number
  }
  dimension: final_grade_score_tiers {
    group_label: "Score"
    label: "Final Score Bucket"
    value_format_name: percent_1
    type: tier
    tiers: [0.4, 0.6, 0.7, 0.8, 0.9]
    style: relational
    sql: ${final_grade_score} ;;
  }
  dimension: final_grade_timespent {
    label: "Time spent"
    value_format: "[m]:ss \m\i\n\s"
    type: number
  }

  measure: final_grade_timespent_average {
    group_label: "Time spent"
    label: "Time spent (Avg)"
    type: average
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_sum {
    group_label: "Time spent"
    label: "Time spent (Sum)"
    type: average
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_min {
    group_label: "Time spent"
    label: "Time spent (Min)"
    type: min
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_p10 {
    group_label: "Time spent"
    label: "Time spent (10th Percentile)"
    type: percentile
    percentile: 10
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_q1 {
    group_label: "Time spent"
    label: "Time spent (25th Percentile)"
    type: percentile
    percentile: 25
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_median {
    group_label: "Time spent"
    label: "Time spent (Median)"
    type: median
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_q3 {
    group_label: "Time spent"
    label: "Time spent (75th Percentile)"
    type: percentile
    percentile: 75
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_p90 {
    group_label: "Time spent"
    label: "Time spent (90th Percentile)"
    type: percentile
    percentile: 90
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
  measure: final_grade_timespent_max {
    group_label: "Time spent"
    label: "Time spent (Max)"
    type: max
    sql: ${final_grade_timespent} ;;
    value_format: "[m]:ss \m\i\n\s"
  }
}

view: curated_activity_take {
  extends: [final_grade]
  derived_table: {
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
            ,COUNT(CASE WHEN final_grade_score = 1 AND attempts > 0 THEN 1 END) / NULLIF(COUNT(CASE WHEN attempts > 0 THEN 1 END), 0) as percent_questions_correct
            ,COUNT(CASE WHEN final_grade_score = 1 AND attempts = 1 THEN 1 END) / NULLIF(COUNT(CASE WHEN attempts > 0  THEN 1 END), 0) as percent_questions_correct_attempt_1
            ,COUNT(CASE WHEN final_grade_score = 1 AND attempts <= 2 THEN 1 END) / NULLIF(COUNT(CASE WHEN attempts > 0  THEN 1 END), 0) as percent_questions_correct_attempt_2
        FROM looker_scratch.item_take_items
        GROUP BY 1
      )
      SELECT
        a.user_identifier,
        a.submission_date,
        a.course_uri,
        a.external_take_uri,
        a.external_properties,
        a.activity_uri as activity_uri,
        a.activity_type_uri as activity_type_uri,
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
        1 as take_count
      FROM looker_scratch.item_take_activities a
      LEFT JOIN q ON a.external_take_uri = q.external_take_uri
      ORDER BY user_identifier
      --course_uri, activity_uri, user_identifier
      ;;

      sql_step: ALTER TABLE looker_scratch.curated_activity_take cluster by (user_identifier)
      ;;

      sql_step: create or replace table ${SQL_TABLE_NAME} CLONE looker_scratch.curated_activity_take
      ;;
    }
    datagroup_trigger: realtime_default_datagroup
  }
  dimension: user_identifier {label: "user guid" hidden: yes}
  dimension_group: submission_date {
    label: "Submission"
    type: time
    timeframes: [raw, time, date, day_of_week, week, month, year]
  }
  dimension: activity_source {
    group_label: "Source"
    type: string
    sql: SPLIT_PART(${activity_uri}, ':', 1) ;;
  }
  dimension: activity_take_source {
    group_label: "Source"
    type: string
    sql: SPLIT_PART(${external_take_uri}, ':', 1) ;;
  }
  dimension: course_uri {hidden:yes}
  dimension: external_take_uri{
    type: string
    link: {
      url: "https://cengage.looker.com/explore/realtime/all_take_nodes?f[take_node.external_take_uri]={{value | url_encode }}"
      label: "View all take nodes"
    }
  }
  dimension: activity_uri {hidden: yes}
  dimension: activity_type_uri {hidden: yes}
  dimension: final_grade_taken {
    group_label: "Taken"
    label: "Taken?"
    type: yesno
  }
  dimension: final_grade_taken_value {
    group_label: "Taken"
    label: "Taken/Not Taken"
    type: string
    case: {when: {sql: ${final_grade_taken};; label: "Taken"}
      else:"Not Taken"
    }
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
    label: "Average attempts per question"
    type: number
  }
  measure: latest_submission_date {
    label: "Latest submission date"
    type: max
    sql: ${submission_date_raw} ;;
  }
  measure: avg_attempts_per_question {
    group_label: "Questions"
    label: "Attempts per Question (Avg)"
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
  dimension: percent_questions_attempted_tier {
    type: tier
    tiers: [0.3, 0.5, 0.7, 0.8, 0.9]
    group_label: "Questions"
    label: "% Questions attempted (buckets)"
    style: relational
    sql: ${percent_questions_attempted} ;;
    value_format_name: percent_0
  }
  dimension: percent_questions_attempted {
    type: number
    tiers: [0.3, 0.5, 0.7, 0.8, 0.9]
    group_label: "Questions"
    label: "% Questions attempted"
    sql: ${questions_attempted} / ${total_questions} ;;
    value_format_name: percent_0
  }
  dimension: percent_scored_questions_attempted {
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
  dimension: percent_questions_correct_tier {
    group_label: "Questions"
    label: "% Questions correct (buckets)"
    sql: ${percent_questions_correct} ;;
    type: tier
    style: relational
    tiers: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    value_format_name: percent_0
  }
  dimension: percent_questions_correct_attempt_1 {
    type: number
    group_label: "Questions"
    label: "% Questions correct 1st attempt"
    value_format_name: percent_0
  }
  dimension: percent_questions_correct_attempt_1_tier {
    group_label: "Questions"
    label: "% Questions correct 1st attempt (buckets)"
    sql: ${percent_questions_correct_attempt_1} ;;
    type: tier
    style: relational
    tiers: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    value_format_name: percent_0
  }
  dimension: percent_questions_correct_attempt_2 {
    type: number
    group_label: "Questions"
    label: "% Questions correct in 2 attempts or less"
    value_format_name: percent_0
  }
  dimension: percent_questions_correct_attempt_2_tier {
    group_label: "Questions"
    label: "% Questions correct in 2 attempts or less (buckets)"
    sql: ${percent_questions_correct_attempt_2} ;;
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
    sql: ${TABLE}.external_properties ;;
  }

  measure: count {
    label: "# Takes"
    type: count
  }
  measure: users {
    label: "# Users"
    type: count_distinct
    sql: ${user_identifier} ;;
  }
  measure: final_grade_score_average {
    group_label: "Score"
    label: "Final Score (Avg)"
    type: average
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_min {
    label: "Final Score (Min)"
    group_label: "Score"
    type: min
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_sd {
    group_label: "Score"
    label: "Final Score (Std. Dev.)"
    value_format_name: percent_1
    sql: STDDEV(${final_grade_score}) ;;
    type: number
  }
  measure: final_grade_score_p10 {
    group_label: "Score"
    label: "Final Score (10th Percentile)"
    type: percentile
    percentile: 10
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_q1 {
    group_label: "Score"
    label: "Final Score (25th Percentile)"
    type: percentile
    percentile: 25
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_median {
    group_label: "Score"
    label: "Final Score (Median)"
    type: median
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_q3 {
    group_label: "Score"
    label: "Final Score (75th Percentile)"
    type: percentile
    percentile: 75
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_p90 {
    group_label: "Score"
    label: "Final Score (90th Percentile)"
    type: percentile
    percentile: 90
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }
  measure: final_grade_score_max {
    group_label: "Score"
    label: "Final Score (Max)"
    type: max
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }



  parameter: attempts_filter{
    type: unquoted
    label: "Correct in how many attempts?"
    description: "Use with the Questions > % Questions Correct measure"
    default_value: "percent_questions_correct"
    allowed_value: {label:"Any number of attempts" value: "percent_questions_correct"}
    allowed_value: {label:"1st attempt" value: "percent_questions_correct_attempt_1"}
    allowed_value: {label:"1st or 2nd attempt" value: "percent_questions_correct_attempt_2"}
  }

  measure: percent_questions_correct_min {
    group_label: "Questions"
    label: "% Questions Correct (Min)"
    type: min
    sql: ${TABLE}.{% parameter attempts_filter %} ;;
    value_format_name: percent_1
  }
  measure: percent_questions_correct_p10 {
    group_label: "Questions"
    label: "% Questions Correct (10th Percentile)"
    type: percentile
    percentile: 10
    sql:  ${TABLE}.{% parameter attempts_filter %} ;;
    value_format_name: percent_1
  }
  measure: percent_questions_correct_q1 {
    group_label: "Questions"
    label: "% Questions Correct (25th Percentile)"
    type: percentile
    percentile: 25
    sql:  ${TABLE}.{% parameter attempts_filter %} ;;
    value_format_name: percent_1
  }
  measure: percent_questions_correct_median {
    label: "% Questions Correct (Median)"
    group_label: "Questions"
    type: median
    sql:  ${TABLE}.{% parameter attempts_filter %} ;;
    value_format_name: percent_1
  }
  measure: percent_questions_correct_q3 {
    group_label: "Questions"
    label: "% Questions Correct (75th Percentile)"
    type: percentile
    percentile: 75
    sql:  ${TABLE}.{% parameter attempts_filter %} ;;
    value_format_name: percent_1
  }
  measure: percent_questions_correct_p90 {
    group_label: "Questions"
    label: "% Questions Correct (90th Percentile)"
    type: percentile
    percentile: 90
    sql:  ${TABLE}.{% parameter attempts_filter %} ;;
    value_format_name: percent_1
  }
  measure: percent_questions_correct_max {
    group_label: "Questions"
    label: "% Questions Correct (Max)"
    type: max
    sql:  ${TABLE}.{% parameter attempts_filter %} ;;
    value_format_name: percent_1
  }

  parameter: stats_metric{
    type: unquoted
    label: "Select a metric to use in boxplots"
    description: "Use with the Dynamic Measure measures"
    default_value: "Score"
    allowed_value: {label:"Score" value: "final_grade_score"}
    allowed_value: {label:"Time Spent (minutes)" value: "final_grade_timespent * 24 * 60"}
    allowed_value: {label:"% Questions Correct" value: "percent_questions_correct"}
  }

  measure: stats_min {
    group_label: "Dynamic measure"
    label: "Min"
    type: min
    sql: ${TABLE}.{% parameter stats_metric %} ;;
    value_format_name: decimal_1
  }
  measure: stats_p10 {
    group_label: "Dynamic measure"
    label: "10th Percentile"
    type: percentile
    percentile: 10
    sql: ${TABLE}.{% parameter stats_metric %} ;;
    value_format_name: decimal_1
  }
  measure: stats_p25 {
    group_label: "Dynamic measure"
    label: "25th Percentile"
    type: percentile
    percentile: 25
    sql: ${TABLE}.{% parameter stats_metric %} ;;
    value_format_name: decimal_1
  }
  measure: stats_p50 {
    group_label: "Dynamic measure"
    label: "Median"
    type: percentile
    percentile: 50
    sql: ${TABLE}.{% parameter stats_metric %} ;;
    value_format_name: decimal_1
  }
  measure: stats_p75 {
    group_label: "Dynamic measure"
    label: "75th Percentile"
    type: percentile
    percentile: 75
    sql: ${TABLE}.{% parameter stats_metric %} ;;
    value_format_name: decimal_1
  }
  measure: stats_p90 {
    group_label: "Dynamic measure"
    label: "90th Percentile"
    type: percentile
    percentile: 90
    sql: ${TABLE}.{% parameter stats_metric %} ;;
    value_format_name: decimal_1
  }
  measure: stats_max {
    group_label: "Dynamic measure"
    label: "Max"
    type: max
    sql: ${TABLE}.{% parameter stats_metric %} ;;
    value_format_name: decimal_1
  }

  dimension: activity_counter {
    hidden: yes
    sql:
      {% if course_activity._in_query %}
        HASH(${activity_uri}, ${user_identifier})
      {% else %}
        ${activity_uri}
      {% endif %}
      ;;
  }

  dimension: activity_completion_status {
    type: string
    case: {
      when: {sql:${percent_questions_attempted} = 0;; label:"Not Started"}
      when: {sql:${percent_questions_attempted} < 1;; label:"Partially Complete"}
      else: "Complete"
    }

  }

  measure: activities_launched {
    group_label: "MTP"
    label: "# Activities launched"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${percent_questions_attempted} > 0 THEN ${activity_counter} END);;
    value_format_name: decimal_0
  }

  measure: activities_completed_partial {
    group_label: "MTP"
    label: "# Activities partially complete"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${percent_questions_attempted} < 1 AND ${percent_questions_attempted} > 0 THEN ${activity_counter} END);;
    value_format_name: decimal_0
  }

  measure: activities_completed {
    group_label: "MTP"
    label: "# Activities complete"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${percent_questions_attempted} = 1THEN ${activity_counter} END);;
    value_format_name: decimal_0
  }


}
