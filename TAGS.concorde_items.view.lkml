view: concorde_items {
  label: "LOTS - Concorde"
  sql_table_name: Uploads.LOTS.CONCORDE_ITEMS ;;

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
    hidden:  yes
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
    hidden:  yes
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    hidden:  yes
  }

  dimension: cgi {
    type: string
    group_label: "Concorde"
    sql: ${TABLE}."CGI" ;;
  }

  dimension: chapter_name {
    type: string
    group_label: "Concorde"
    sql: ${TABLE}."CHAPTER_NAME" ;;
  }

  dimension: item_handler {
    type: string
    group_label: "Concorde"
    sql: ${TABLE}."ITEM_HANDLER" ;;
  }

  dimension: item_identifier {
    type: number
    group_label: "Concorde"
    value_format_name: id
    sql: ${TABLE}."ITEM_IDENTIFIER" ;;
  }

  dimension: item_name {
    type: string
    group_label: "Concorde"
    sql: ${TABLE}."ITEM_NAME" ;;
  }

  dimension: justification_if_no_learning_outcome_maps_to_question {
    type: string
    sql: ${TABLE}."JUSTIFICATION_IF_NO_LEARNING_OUTCOME_MAPS_TO_QUESTION" ;;
    hidden:  yes
  }

  dimension: learning_outcome_tag_set_1_primary {
    label: "Learning Outcomes - Course Objectives"
    type: string
    group_label: "Concorde"
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_1_PRIMARY" ;;
  }

  dimension: learning_outcome_tag_set_2_primary {
    label: "Learning Outcomes - CAAHEP Cognitive Competencies"
    type: string
    group_label: "Concorde"
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_2_PRIMARY" ;;
  }

  dimension: multiple_los_set_1_ {
    type: string
    group_label: "Concorde"
    sql: ${TABLE}."MULTIPLE_LOS_SET_1_" ;;
    hidden:  yes
  }

  dimension: multiple_los_set_2_ {
    type: string
    sql: ${TABLE}."MULTIPLE_LOS_SET_2_" ;;
    hidden:  yes
  }

  dimension: question {
    type: string
    sql: ${TABLE}."QUESTION" ;;
    hidden:  yes
  }

  measure: count {
    type: count
    hidden: yes
    drill_fields: [chapter_name, item_name]
  }
}
