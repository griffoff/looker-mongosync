view: rcc_mag_51_items {
  label: "LOTS - RCC MAG51"
  sql_table_name: Uploads.LOTS.RCC_MAG_51_ITEMS ;;

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
    group_label: "RCC MAG51"
    sql: ${TABLE}."CGI" ;;
  }

  dimension: chapter_name {
    type: string
    group_label: "RCC MAG51"
    sql: ${TABLE}."CHAPTER_NAME" ;;
  }

  dimension: item_handler {
    type: string
    group_label: "RCC MAG51"
    sql: ${TABLE}."ITEM_HANDLER" ;;
  }

  dimension: item_identifier {
    type: number
    group_label: "RCC MAG51"
    value_format_name: id
    sql: ${TABLE}."ITEM_IDENTIFIER" ;;
  }

  dimension: item_name {
    type: string
    group_label: "RCC MAG51"
    sql: ${TABLE}."ITEM_NAME" ;;
  }

  dimension: learning_outcome_tag_set_1_primary {
    label: "Learning Outcomes"
    type: string
    group_label: "RCC MAG51"
    sql: ${TABLE}."LEARNING_OUTCOME_TAG_SET_1_PRIMARY" ;;
  }

  dimension: multiple_los_set_1_ {
    type: string
    group_label: "RCC MAG51"
    sql: ${TABLE}."MULTIPLE_LOS_SET_1_" ;;
    hidden:  yes
  }

  dimension: question {
    type: string
    group_label: "RCC MAG51"
    sql: ${TABLE}."QUESTION" ;;
    hidden:  yes
  }

  dimension: sme_info_ {
    type: string
    group_label: "RCC MAG51"
    sql: ${TABLE}."SME_INFO_" ;;
    hidden:  yes
  }

  measure: count {
    type: count
    group_label: "RCC MAG51"
    drill_fields: [chapter_name, item_name]
  }
}
