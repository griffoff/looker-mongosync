include: "./datagroups.lkml"
include: "//cengage_unlimited/views/cu_user_analysis/product_info.view"
include: "./product_item_metadata.view"
include: "./course_activity.view"
include: "./course_enrollment.view"
include: "./take_node.view"
include: "//cengage_unlimited/views/cu_user_analysis/course_info.explore"

explore: realtime_course {
  view_name: realtime_course
  from: realtime_course
  hidden: yes
  view_label: "Course (Realtime)"
  extends: [course_info, product_item_metadata, course_activity, take_node]

  join: course_info {
    sql_on: ${realtime_course.course_key} = ${course_info.course_key} ;;
    relationship: one_to_one
  }

  join: course_activity {
    sql_on: ${realtime_course.course_uri} = ${course_activity.course_uri} ;;
    relationship: one_to_many
  }

  join: course_enrollment{
    sql_on: ${realtime_course.course_uri} = ${course_enrollment.course_uri} ;;
    relationship: one_to_many
  }

  join: take_node {
    sql_on: (${course_activity.course_uri}, ${course_activity.activity_uri}, ${course_enrollment.user_identifier})
      = (${take_node.course_uri}, ${take_node.activity_uri}, ${take_node.user_identifier});;
    relationship: one_to_many
  }

}
view: realtime_course {

  view_label: "Course Details (from Real-time)"

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
            WHEN course_uri like 'soa:%' THEN NULL
            ELSE split_part(course_uri, ':', -1) END) as course_key
          ,UPPER(CASE
            WHEN external_properties:"soa:property:courseKey":value IS NOT NULL THEN external_properties:"soa:property:courseKey":value
            WHEN course_uri like 'soa:%' THEN NULL
            ELSE split_part(course_uri, ':', -1) END) as original_course_key
        from realtime.course
      )
      select *
      from data d
      where latest = 1
      order by course_uri
    ;;

 # insert missing course_uris
    sql_step:
    insert into looker_scratch.realtime_course (course_uri, course_key, original_course_key)
    select distinct
      course_uri
      ,UPPER(CASE
            WHEN course_uri like 'soa:%' THEN NULL
            ELSE split_part(course_uri, ':', -1) END
            ) as course_key
      ,UPPER(CASE
            WHEN course_uri like 'soa:%' THEN NULL
            ELSE split_part(course_uri, ':', -1) END
            ) as original_course_key
    from looker_scratch.item_take_activities
    where course_uri not in (select course_uri from realtime.course where course_uri is not null)
    ;;

  # should there be an additional insert of course_uri from take_node ?

  # validate course_keys
    sql_step:
    update looker_scratch.realtime_course
      set course_key = NULL
          , original_course_key = NULL
    where course_key not in (
          select course_key
          from prod.datavault.sat_coursesection
          where course_key is not null
          and _latest
      )
    ;;

  # map soa CGIs
  # soa:prod:CGI or just CGI in some takes
    sql_step:
    merge into looker_scratch.realtime_course rc
    using prod.datavault.sat_coursesection scs on split_part(course_uri, ':', -1) = scs.course_cgi
                                              and rc.course_key is null
                                              and scs._latest
    when matched then update
      set rc.course_key = UPPER(scs.course_key)
          , rc.original_course_key = UPPER(scs.course_key)
    ;;

  # map cnow shadow courses
  sql_step:
    merge into looker_scratch.realtime_course rc
    using (
    with shadow as (
        select split_part(short_label, '.', -1) as id, course_uri
        from looker_scratch.realtime_course
        where course_uri like 'cnow:course:%'
          and id != ''
          and course_key is null
       )
    select coalesce(c.course_key, o.external_id) as parent_course_key, shadow.course_uri as shadow_course_uri, ROW_NUMBER() OVER (PARTITION BY shadow_course_uri order by parent_course_key) as r
    from looker_scratch.realtime_course c
    left join shadow on c.external_properties:"mindtap:property:snapshot-id":value = shadow.id
    left join mindtap.prod_nb.snapshot s on shadow.id = s.id
    left join mindtap.prod_nb.org o on s.org_id = o.id
    ) map on rc.course_uri = map.shadow_course_uri and r = 1
    when matched then update
      set rc.course_key = UPPER(map.parent_course_key)
  ;;

  # map cnow
    sql_step:
    merge into looker_scratch.realtime_course rc
    using prod.datavault.sat_coursesection scs on rc.course_uri like 'cnow:course:%'
                                              and 'E' || split_part(course_uri, ':', -1) = REPLACE(scs.course_key, '-', '')
                                              and rc.course_key is null
                                              and scs._latest
    when matched then update
      set rc.course_key = UPPER(scs.course_key)
          , rc.original_course_key = UPPER(scs.course_key)
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

  dimension: source {
    type: string
    sql: IFF(ARRAY_SIZE(SPLIT(${course_uri}, ':')) = 1, 'Malformed-URI', SPLIT_PART(${course_uri}, ':', 1)) ;;
  }

  dimension: course_key {
    description: "Course key after CNOW shadow course mapping"
    type: string
  }

  dimension: original_course_key {
    description: "Course key before CNOW shadow course mapping"
    type: string
    hidden: yes
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
