view: realtime_course {
  #sql_table_name: REALTIME.COURSE ;;
  derived_table: {
    create_process: {
      sql_step:
      create or replace transient table looker_scratch.realtime_course
      as
      with data as (
        select
          course_uri as business_key
          ,hash(course_uri, last_update_date) as primary_key
          ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
          ,*
          ,UPPER(CASE
            WHEN external_properties:"soa:property:courseKey":value IS NOT NULL THEN external_properties:"soa:property:courseKey":value
            WHEN split_part(course_uri, ':', 1) like 'cnow' THEN CONCAT ('E-',split_part(course_uri, ':', -1))
            WHEN course_uri like 'soa:%' THEN NULL
            ELSE split_part(course_uri, ':', -1) END) as course_key
        from realtime.course
      )
      select *
      from data
      where latest = 1
      order by course_uri
    ;;

    sql_step:
    insert into looker_scratch.realtime_course (course_uri, course_key)
    with missing as (
      select distinct course_uri
      from looker_scratch.item_take_activities
      where course_uri not in (select course_uri from realtime.course)
        and course_uri like 'soa:prod%'
     )
    select course_uri, UPPER(scs.course_key) as course_key
    from missing
    left join prod.datavault.sat_coursesection scs on split_part(course_uri, ':', -1) = scs.course_cgi
                                                  and scs._latest
    ;;

    sql_step:
    insert into looker_scratch.realtime_course (course_uri, course_key)
    with missing as (
    select distinct course_uri
    from looker_scratch.item_take_activities
    where course_uri not in (select course_uri from realtime.course)
    and course_uri not like 'soa:prod%'
    )
    select course_uri, UPPER(scs.course_key) as course_key
    from missing
    left join prod.datavault.sat_coursesection scs on split_part(course_uri, ':', -1) = scs.course_key
                                                  and scs._latest
    ;;

    sql_step:
    merge into looker_scratch.realtime_course rc
    using prod.datavault.sat_coursesection scs on rc.course_uri like 'soa:prod:%'
                                              and split_part(course_uri, ':', -1) = scs.course_cgi
                                              and rc.course_key is null
                                              and scs._latest
    when matched then update
      set rc.course_key = UPPER(scs.course_key)
    ;;

    sql_step:
    create or replace transient table ${SQL_TABLE_NAME} clone looker_scratch.realtime_course
    ;;

    }
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
