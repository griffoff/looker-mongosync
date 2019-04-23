explore: csfi_view {}
view: csfi_view {
  derived_table: {
    sql: Select
          LAG(SUBMISSION_DATE) over (partition by USER_IDENTIFIER,ACTIVITY_TYPE_URI order by SUBMISSION_DATE)  as prev_applicationusagedate
          ,split_part(COURSE_URI, ':', -1)::string as course_key
          ,*
          from realtime.take_node
          where ACTIVITY_TYPE_URI LIKE 'imilac:als-csfi'
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: prev_applicationusagedate {
    type: date
    sql: ${TABLE}."PREV_APPLICATIONUSAGEDATE" ;;
  }


  measure: app_firstusage {
    label: "First Time Usage"
    description: "Count of unique users who have used an application for the first time "
    type: count_distinct
    sql: case when ${prev_applicationusagedate} is null then array_construct(${user_identifier}) end ;;
  }


  dimension_group: _ldts {
    type: time
    sql: ${TABLE}."_LDTS" ;;
    hidden: yes
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
    hidden: yes
  }

  dimension: activity_uri {
    type: string
    sql: ${TABLE}."ACTIVITY_URI" ;;
  }

  dimension: activity_node_uri {
    type: string
    sql: ${TABLE}."ACTIVITY_NODE_URI" ;;
  }

  dimension: external_take_uri {
    type: string
    sql: ${TABLE}."EXTERNAL_TAKE_URI" ;;
  }

  dimension: course_uri {
    type: string
    sql: ${TABLE}."COURSE_URI" ;;
  }

  dimension: user_identifier {
    type: string
    sql: ${TABLE}."USER_IDENTIFIER" ;;
  }

  dimension_group: submission_date {
    type: time
    sql: ${TABLE}."SUBMISSION_DATE" ;;
  }

  dimension: possible_score {
    type: number
    sql: ${TABLE}."POSSIBLE_SCORE" ;;
  }

  dimension: interaction_grade {
    type: string
    sql: ${TABLE}."INTERACTION_GRADE" ;;
  }

  dimension: activity_grade {
    type: string
    sql: ${TABLE}."ACTIVITY_GRADE" ;;
  }

  dimension: final_grade {
    type: string
    sql: ${TABLE}."FINAL_GRADE" ;;
  }

  dimension: activity {
    type: string
    sql: ${TABLE}."ACTIVITY" ;;
  }

  dimension: mastery_item {
    type: string
    sql: ${TABLE}."MASTERY_ITEM" ;;
  }

  dimension: activity_type_uri {
    type: string
    sql: ${TABLE}."ACTIVITY_TYPE_URI" ;;
  }

  dimension: course_key {
    type: string
    #sql: split_part(${TABLE}.COURSE_URI, ':', -1)::string ;;
  }

  dimension: assignable_content_uri {
    type: string
    sql: ${TABLE}."ASSIGNABLE_CONTENT_URI" ;;
  }

  dimension: hash {
    type: string
    sql: ${TABLE}."HASH" ;;
    hidden: yes
  }

  dimension_group: last_update_date {
    type: time
    sql: ${TABLE}."LAST_UPDATE_DATE" ;;
  }

  set: detail {
    fields: [
      prev_applicationusagedate,
      _ldts_time,
      _rsrc,
      activity_uri,
      activity_node_uri,
      external_take_uri,
      course_uri,
      user_identifier,
      submission_date_time,
      possible_score,
      interaction_grade,
      activity_grade,
      final_grade,
      activity,
      mastery_item,
      activity_type_uri,
      assignable_content_uri,
      hash,
      last_update_date_time
    ]
  }
}
