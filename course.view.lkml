view: course {
  sql_table_name: COVALENT_NEW.COURSE ;;

  dimension: jsondata {
    type: string
    sql: ${TABLE}.JSONDATA ;;
  }

  dimension_group: lastupdate {
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
    sql: ${TABLE}.LASTUPDATE ;;
  }

  dimension_group: ldts {
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
    sql: ${TABLE}.LDTS ;;
  }

  dimension: oid {
    type: string
    sql: ${TABLE}.OID ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.STATUS ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: docs {
    type: count_distinct
    sql: ${oid} ;;
  }
}
