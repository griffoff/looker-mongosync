view: product_toc_metadata {
  sql_table_name: REALTIME.PRODUCT_TOC_METADATA ;;

  dimension_group: _ldts {
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
    sql: ${TABLE}._LDTS ;;
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}._RSRC ;;
  }

  dimension: abbr {
    type: string
    sql: ${TABLE}.ABBR ;;
  }

  dimension: ancestor_ids {
    type: string
    sql: ${TABLE}.ANCESTOR_IDS ;;
  }

  dimension: cgid {
    type: string
    sql: ${TABLE}.CGID ;;
  }

  dimension_group: date_processed {
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
    sql: ${TABLE}.DATE_PROCESSED ;;
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}.DISCIPLINE ;;
  }

  dimension: format {
    type: string
    sql: ${TABLE}.FORMAT ;;
  }

  dimension: isbn {
    type: string
    sql: ${TABLE}.ISBN ;;
  }

  dimension: link {
    type: string
    sql: ${TABLE}.LINK ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: node_id {
    type: string
    sql: ${TABLE}.NODE_ID ;;
  }

  dimension: parent_id {
    type: string
    sql: ${TABLE}.PARENT_ID ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}.PRODUCT ;;
  }

  dimension: product_code {
    type: string
    sql: ${TABLE}.PRODUCT_CODE ;;
  }

  dimension: sibling_order {
    type: string
    sql: ${TABLE}.SIBLING_ORDER ;;
  }

  dimension: source_system {
    type: string
    sql: ${TABLE}.SOURCE_SYSTEM ;;
  }

  measure: count {
    type: count
    drill_fields: [name]
  }
}