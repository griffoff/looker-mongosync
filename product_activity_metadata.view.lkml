view: product_activity_metadata {
  #sql_table_name: REALTIME.PRODUCT_ACTIVITY_METADATA ;;
  derived_table: {
    sql:
      with data as (
        select
          _hash as business_key
          ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
          ,_LDTS
          ,_RSRC
          ,SOURCE_SYSTEM
          ,PRODUCT_CODE
          ,ITEM_ID
          ,CGID
          ,NAME
          ,LINK
          ,ACTIVITY_ENGINE
          ,any_value(ACTIVITY_TYPE) over (partition by product_code, item_id) as activity_type
          ,HANDLER
          ,PRODUCT
          ,CORE_ISBN
          ,LAST_UPDATE_DATE
        from REALTIME.PRODUCT_ACTIVITY_METADATA
      )
      select *
      from data
      where latest = 1
      order by product_code, item_id
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

  dimension: activity_engine {
    type: string
    sql: ${TABLE}.ACTIVITY_ENGINE ;;
  }

  dimension: activity_type {
    type: string
    sql: ${TABLE}.ACTIVITY_TYPE ;;
  }

  dimension: cgid {
    type: string
    sql: ${TABLE}.CGID ;;
  }

  dimension: core_isbn {
    type: string
    sql: ${TABLE}.CORE_ISBN ;;
  }

  dimension: handler {
    type: string
    sql: ${TABLE}.HANDLER ;;
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

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}.PRODUCT ;;
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
    drill_fields: [name]
  }
}
