view: product_mastery_group {
#   sql_table_name: REALTIME.PRODUCT_MASTERY_GROUP ;;
  derived_table: {
    sql:
      with data as (
        select
          _hash as business_key
          ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
          ,*
        from REALTIME.PRODUCT_MASTERY_GROUP
      )
      select *
      from data
      where latest = 1
      order by source_system, product_code
      ;;

      datagroup_trigger: realtime_default_datagroup
    }

  dimension: business_key {
    type: string
    hidden: yes
    primary_key: yes
  }

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

  dimension: cgid {
    type: string
    sql: ${TABLE}.CGID ;;
  }

  dimension: computed_hash {
    type: string
    sql: ${TABLE}.COMPUTED_HASH ;;
  }

  dimension: historical_hashes {
    type: string
    sql: ${TABLE}.HISTORICAL_HASHES ;;
  }

  dimension: item_cgids {
    type: string
    sql: ${TABLE}.ITEM_CGIDS ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}.ITEM_ID ;;
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

  dimension: link {
    type: string
    sql: ${TABLE}.LINK ;;
  }

  dimension: product_code {
    type: string
    sql: ${TABLE}.PRODUCT_CODE ;;
  }

  dimension: source_system {
    type: string
    sql: ${TABLE}.SOURCE_SYSTEM ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
