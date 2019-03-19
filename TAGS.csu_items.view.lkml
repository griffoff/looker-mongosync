view: csu_items {
  sql_table_name: Uploads.TX_STATE.CSU_ITEMS ;;

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
    type: string
    sql: ${TABLE}."_ROW" ;;
    hidden: yes
  }

  dimension: answers {
    type: string
    sql: ${TABLE}."ANSWERS" ;;
  }

  dimension: cgi {
    type: string
    sql: ${TABLE}."CGI" ;;
    hidden: yes
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

  dimension: learning_outcome_tag_set_1_ {
    type: string
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_1_" ;;
  }

  dimension: lo_tag_id_combined_set_1_ {
    type: string
    sql: ${TABLE}."LO_TAG_ID_COMBINED_SET_1_" ;;
  }

  dimension: multiple_los_tag_id_list_all_ {
    type: string
    sql: ${TABLE}."MULTIPLE_LOS_TAG_ID_LIST_ALL_" ;;
  }

  dimension: multiple_rollups_tag_id_list_all_ {
    type: string
    sql: ${TABLE}."MULTIPLE_ROLLUPS_TAG_ID_LIST_ALL_" ;;
  }

  dimension: question {
    type: string
    sql: ${TABLE}."QUESTION" ;;
  }

  dimension: rollup_outcome_id {
    type: string
    sql: ${TABLE}."ROLLUP_OUTCOME_ID" ;;
  }

  dimension: rollup_outcome_tag {
    type: string
    sql: ${TABLE}."ROLLUP_OUTCOME_TAG" ;;
  }

  dimension: rollup_tag_id_combined {
    type: string
    sql: ${TABLE}."ROLLUP_TAG_ID_COMBINED" ;;
  }

  measure: count {
    type: count
    drill_fields: [item_name]
  }
}
