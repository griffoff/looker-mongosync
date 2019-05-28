view: nwtc_items {
  label: "LOTS - NWTC"
  sql_table_name: uploads.LOTS.NWTC_ITEMS ;;

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
  }

  dimension: cgi {
    type: string
    sql: ${TABLE}."CGI" ;;
  }

  dimension: chapter {
    type: string
    sql: ${TABLE}."CHAPTER" ;;
  }

  dimension: item_handler {
    type: string
    sql: ${TABLE}."ITEM_HANDLER" ;;
  }

  dimension: item_identifier {
    type: string
    sql: ${TABLE}."ITEM_IDENTIFIER" ;;
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}."ITEM_NAME" ;;
  }

  dimension: learning_outcome_id_set_1_ {
    type: string
    sql: ${TABLE}."LEARNING_OUTCOME_ID_SET_1_" ;;
  }

  dimension: learning_outcome_id_set_2_ {
    type: string
    sql: ${TABLE}."LEARNING_OUTCOME_ID_SET_2_" ;;
  }

  dimension: learning_outcome_tag_set_1_ {
    type: string
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_1_" ;;
  }

  dimension: learning_outcome_tag_set_2_ {
    type: string
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_2_" ;;
  }

  dimension: lo_tag_id_combined_set_1_ {
    label: "Learning Outcomes - Cost IP"
    type: string
    sql: ${TABLE}."LO_TAG_ID_COMBINED_SET_1_" ;;
  }

  dimension: lo_tag_id_combined_set_2_ {
    label: "Learning Outcomes - Managerial IP"
    type: string
    sql: ${TABLE}."LO_TAG_ID_COMBINED_SET_2_" ;;
  }

  dimension: question {
    type: string
    sql: ${TABLE}."QUESTION" ;;
  }

  dimension: set_1_multiple_los_tag_id_list_all_ {
    type: string
    sql: ${TABLE}."SET_1_MULTIPLE_LOS_TAG_ID_LIST_ALL_" ;;
  }

  dimension: set_2_multiple_los_tag_id_list_all_ {
    type: string
    sql: ${TABLE}."SET_2_MULTIPLE_LOS_TAG_ID_LIST_ALL_" ;;
  }

  measure: count {
    type: count
    drill_fields: [item_name]
  }
}
