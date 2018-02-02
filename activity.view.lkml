view: activity {
  sql_table_name: COVALENT_NEW.ACTIVITY ;;

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
}
