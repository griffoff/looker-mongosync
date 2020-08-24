include:"curated.activity_take.view"
view: curated_item_take {
  extends: [curated_activity_take]

  sql_table_name: looker_scratch.item_take_items ;;

  dimension: activity_item_uri {}

  dimension: attempts {
    type: number
  }

  measure: sum_questions_attempted {
    type: number
    hidden: yes
    sql: NULLIF(COUNT(CASE WHEN ${attempts} > 0 THEN 1 END), 0) ;;
  }

  measure: final_grade_percent_correct {
    group_label: "Score"
    type: number
    sql: COUNT(CASE WHEN ${final_grade_score} = 1 THEN 1 END) / ${sum_questions_attempted};;
    value_format_name: percent_1
  }

  measure: final_grade_percent_correct_attempt_1 {
    group_label: "Score"
    type: number
    sql: COUNT(CASE WHEN ${final_grade_score} = 1 AND ${attempts} = 1 THEN 1 END) / ${sum_questions_attempted};;
    value_format_name: percent_1
  }

  measure: final_grade_percent_correct_attempt_2 {
    group_label: "Score"
    type: number
    sql: COUNT(CASE WHEN ${final_grade_score} = 1 AND ${attempts} <= 2 THEN 1 END) / ${sum_questions_attempted};;
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
  measure: final_grade_score_p90 {
    hidden: yes
  }
  measure: final_grade_score_max {
    hidden: yes
  }
  dimension: total_questions {
    hidden: yes
  }
  dimension: total_scored_questions {
    hidden: yes
  }
  dimension: total_question_attempts {
    hidden: yes
  }
  dimension: avg_question_attempts {
    hidden: yes
  }
  dimension: questions_attempted {
    hidden: yes
  }
  dimension: scored_questions_attempted {
    hidden: yes
  }
  dimension: pecent_questions_attempted {
    hidden: yes
  }
  dimension: pecent_scored_questions_attempted {
    hidden: yes
  }
  dimension: percent_questions_correct {
    hidden: yes
  }
  dimension: percent_questions_correct_attempt_1 {
    hidden: yes
  }
  dimension: percent_questions_correct_attempt_2 {
    hidden: yes
  }

}
