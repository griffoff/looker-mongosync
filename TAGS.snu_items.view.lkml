view: snu_items {
  label: "LOTS - SNU"
  sql_table_name: Uploads.LOTS.SNU_ITEMS ;;

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

  dimension: cgi {
    type: string
    sql: ${TABLE}."CGI" ;;
    group_label: "SNU"
  }

  dimension: chapter_name {
    type: string
    sql: ${TABLE}."CHAPTER_NAME" ;;
    group_label: "SNU"
  }

  dimension: item_handler {
    type: string
    sql: ${TABLE}."ITEM_HANDLER" ;;
    group_label: "SNU"
  }

  dimension: item_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."ITEM_IDENTIFIER" ;;
    group_label: "SNU"
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}."ITEM_NAME" ;;
    group_label: "SNU"
  }

  dimension: learning_outcome_tag_set_1_primary {
    type: string
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_1_PRIMARY" ;;
    group_label: "SNU"
  }

  dimension: learning_outcome_tag_set_2_primary {
    type: string
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_2_PRIMARY" ;;
    group_label: "SNU"
  }

  dimension: multiple_los_set_1_ {
    type: string
    sql: ${TABLE}."MULTIPLE_LOS_SET_1_" ;;
    group_label: "SNU"
  }

  dimension: multiple_los_set_2_ {
    type: string
    sql: ${TABLE}."MULTIPLE_LOS_SET_2_" ;;
    group_label: "SNU"
  }

  dimension: question {
    type: string
    sql: ${TABLE}."QUESTION" ;;
    group_label: "SNU"
  }

  dimension: sme_info {
    type: string
    sql: ${TABLE}."SME_INFO" ;;
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [item_name, chapter_name]
  }
}
