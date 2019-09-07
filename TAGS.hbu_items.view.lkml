view: hbu_items {
  sql_table_name: Uploads.LOTS.HBU_ITEMS ;;

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
    hidden:  yes
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    hidden: yes
  }

  dimension: cgi {
    type: string
    group_label: "HBU"
    sql: ${TABLE}."CGI" ;;
  }

  dimension: chapter_name {
    type: string
    group_label: "HBU"
    sql: ${TABLE}."CHAPTER_NAME" ;;
  }

  dimension: item_handler {
    type: string
    group_label: "HBU"
    sql: ${TABLE}."ITEM_HANDLER" ;;
  }

  dimension: item_identifier {
    type: number
    group_label: "HBU"
    value_format_name: id
    sql: ${TABLE}."ITEM_IDENTIFIER" ;;
  }

  dimension: item_name {
    type: string
    group_label: "HBU"
    sql: ${TABLE}."ITEM_NAME" ;;
  }

  dimension: learning_outcome_tag_set_1_primary {
    label: "Learning Outcomes"
    type: string
    group_label: "HBU"
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_1_PRIMARY" ;;
  }

  dimension: multiple_los_set_1_ {
    type: string
    group_label: "HBU"
    sql: ${TABLE}."MULTIPLE_LOS_SET_1_" ;;
  }

  dimension: question {
    type: string
    group_label: "HBU"
    sql: ${TABLE}."QUESTION" ;;
  }

  measure: count {
    type: count
    group_label: "HBU"
    drill_fields: [chapter_name, item_name]
  }
}
