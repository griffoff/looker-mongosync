view: product_olr_metadata {
  sql_table_name: REALTIME.PRODUCT_OLR_METADATA ;;

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

  dimension: core_isbn {
    type: string
    sql: ${TABLE}.CORE_ISBN ;;
  }

  dimension: iac {
    type: string
    sql: ${TABLE}.IAC ;;
  }

  dimension_group: last_update {
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
    sql: ${TABLE}.LAST_UPDATE_DATE ;;
  }

  dimension: subject_major {
    type: string
    sql: ${TABLE}.SUBJECT_MAJOR ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
