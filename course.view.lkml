view: course {
  #sql_table_name: REALTIME.COURSE ;;
  derived_table: {
    sql:
      with data as (
        select
          course_uri as business_key
          ,hash(course_uri, last_update_date) as primary_key
          ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
          ,*
        from realtime.course
      )
      select *
      from data
      where latest = 1
      order by course_uri
    ;;

    datagroup_trigger: realtime_default_datagroup
  }

  dimension: primary_key {
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

  dimension: course_uri {
    type: string
    sql: ${TABLE}.COURSE_URI ;;
  }

  dimension: course_key {
    type: string
    sql: split_part(${course_uri}, ':', -1) ;;
  }

  dimension_group: end {
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
    sql: ${TABLE}.END_DATE ;;
  }

  dimension: external_properties {
    type: string
    sql: ${TABLE}.EXTERNAL_PROPERTIES ;;
  }

  dimension: institution_uri {
    type: string
    sql: ${TABLE}.INSTITUTION_URI ;;
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

  dimension: long_label {
    type: string
    sql: ${TABLE}.LONG_LABEL ;;
  }

  dimension: short_label {
    type: string
    sql: ${TABLE}.SHORT_LABEL ;;
  }

  dimension_group: start {
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
    sql: ${TABLE}.START_DATE ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
