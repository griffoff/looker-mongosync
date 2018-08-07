view: lo_items {
  sql_table_name: UPLOADS.TX_STATE.LO_ITEMS ;;

  dimension: bloom_s_level {
    type: string
    sql: ${TABLE}."BLOOM_S_LEVEL" ;;
  }

  dimension: chapter {
    type: string
    sql: ${TABLE}."CHAPTER" ;;
  }

  dimension: difficulty_ranking {
    type: string
    sql: ${TABLE}."DIFFICULTY_RANKING" ;;
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

  dimension: learning_styles {
    type: string
    sql: ${TABLE}."LEARNING_STYLES" ;;
  }

  dimension: problem_types {
    type: string
    sql: ${TABLE}."PROBLEM_TYPES" ;;
  }

  dimension: skillsets {
    type: string
    sql: ${TABLE}."SKILLSETS" ;;
  }

  measure: count {
    type: count
    drill_fields: [item_name]
  }
}
