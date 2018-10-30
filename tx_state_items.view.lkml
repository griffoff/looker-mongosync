view: tx_state_items {
  sql_table_name: Uploads.TX_STATE.TX_STATE_ITEMS ;;

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
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
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: aacsb_taxonomy_code {
    type: number
    sql: ${TABLE}."AACSB_TAXONOMY_CODE" ;;
  }

  dimension: aacsb_taxonomy_tag {
    type: string
    sql: ${TABLE}."AACSB_TAXONOMY_TAG" ;;
  }

  dimension: bloom_s_level {
    type: string
    sql: ${TABLE}."BLOOM_S_LEVEL" ;;
  }

  dimension: chapter {
    type: string
    sql: ${TABLE}."CHAPTER" ;;
  }

  dimension: generic_taxonomy {
    type: string
    sql: ${TABLE}."GENERIC_TAXONOMY" ;;
  }

  dimension: item_handler {
    type: string
    sql: ${TABLE}."ITEM_HANDLER" ;;
  }

  dimension: item_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."ITEM_IDENTIFIER" ;;
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}."ITEM_NAME" ;;
  }

  dimension: learning_objectives {
    type: string
    sql: ${TABLE}."LEARNING_OBJECTIVES" ;;
  }

  dimension: sacs_taxonomy_code {
    type: number
    sql: ${TABLE}."SACS_TAXONOMY_CODE" ;;
  }

  dimension: sacs_taxonomy_tag {
    type: string
    sql: ${TABLE}."SACS_TAXONOMY_TAG" ;;
  }

  measure: count {
    type: count
    drill_fields: [item_name]
  }
}