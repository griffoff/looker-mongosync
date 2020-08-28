view: realtime_course {
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
    link: {label: "View in Analytics Diagnostic Tool" url: "https://analytics-tools.cengage.info/diagnostictool/#/course/view/production/uri/{{ value }}"}
  }

#   dimension: course_key {
#     type: string
#     sql: split_part(${course_uri}, ':', -1) ;;
#   }
# transformation to CONCAT 'E-' coursekeys for cnow courses
  dimension: course_key {
    type: string
    sql: COALESCE(${external_properties}:"soa:property:courseKey":value
          ,CASE WHEN split_part(${course_uri}, ':', 1) like 'cnow' THEN CONCAT ('E-',split_part(${course_uri}, ':', -1)) ELSE split_part(${course_uri}, ':', -1) END
          );;
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

  dimension: product_platform {
    type: string
    sql: COALESCE(${external_properties}:"soa:property:platform":value, SPLIT_PART(${course_uri}, ':', 1))::STRING ;;
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

  dimension: snapshot_label {
    type: string
    sql: try_cast(split_part(${TABLE}.SHORT_LABEL, '.', 3) as int)  ;;
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
