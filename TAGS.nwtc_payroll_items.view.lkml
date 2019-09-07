view: nwtc_payroll_items {
  sql_table_name: Uploads.LOTS.NWTC_PAYROLL_ITEMS ;;

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
    hidden: yes
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
    hidden: yes
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    hidden: yes
  }

  dimension: answer {
    type: string
    sql: ${TABLE}."ANSWER" ;;
    group_label: "NWTC Payroll"
  }

  dimension: bloom_s_level {
    type: string
    sql: ${TABLE}."BLOOM_S_LEVEL" ;;
    group_label: "NWTC Payroll"
  }

  dimension: cgi {
    type: string
    sql: ${TABLE}."CGI" ;;
    group_label: "NWTC Payroll"
  }

  dimension: chapter {
    type: string
    sql: ${TABLE}."CHAPTER" ;;
    group_label: "NWTC Payroll"
  }

  dimension: difficulty_ranking {
    type: string
    sql: ${TABLE}."DIFFICULTY_RANKING" ;;
    group_label: "NWTC Payroll"
  }

  dimension: generic_taxonomy {
    type: string
    sql: ${TABLE}."GENERIC_TAXONOMY" ;;
    group_label: "NWTC Payroll"
  }

  dimension: item_handler {
    type: string
    sql: ${TABLE}."ITEM_HANDLER" ;;
    group_label: "NWTC Payroll"
  }

  dimension: item_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."ITEM_IDENTIFIER" ;;
    group_label: "NWTC Payroll"
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}."ITEM_NAME" ;;
    group_label: "NWTC Payroll"
  }

  dimension: learning_objectives {
    type: string
    sql: ${TABLE}."LEARNING_OBJECTIVES" ;;
    group_label: "NWTC Payroll"
    hidden: yes
  }

  dimension: learning_outcome_tag_set_1_primary {
    label: "Learning Outcomes"
    type: string
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_1_PRIMARY" ;;
    group_label: "NWTC Payroll"
  }

  dimension: multiple_los_set_1_ {
    type: string
    sql: ${TABLE}."MULTIPLE_LOS_SET_1_" ;;
    group_label: "NWTC Payroll"
  }

  dimension: problem_types {
    type: string
    sql: ${TABLE}."PROBLEM_TYPES" ;;
    group_label: "NWTC Payroll"
  }

  dimension: question {
    type: string
    sql: ${TABLE}."QUESTION" ;;
    group_label: "NWTC Payroll"
  }

  measure: count {
    type: count
    drill_fields: [item_name]
    group_label: "NWTC Payroll"
  }
}
