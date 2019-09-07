view: course_activity {
  #sql_table_name: realtime.course_activity ;;
  derived_table: {
    sql:
      with data as (
        select
          _hash as business_key
          ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
          ,*
          ,LAG(external_properties) OVER (PARTITION BY business_key ORDER BY last_update_date) AS prev_external_properties
          ,FIRST_VALUE(external_properties) OVER (PARTITION BY business_key ORDER BY last_update_date) AS initial_external_properties
        from realtime.course_activity
      )
      select *
      from data
      where latest = 1
      order by course_uri, activity_uri
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

  dimension: activity_group_uris {
    type: string
    sql: ${TABLE}.ACTIVITY_GROUP_URIS ;;
  }

  dimension: activity_uri {
    type: string
    sql: ${TABLE}.ACTIVITY_URI ;;
  }

  dimension: assignable_content_uri {
    type: string
    sql: ${TABLE}.ASSIGNABLE_CONTENT_URI ;;
  }

  dimension: course_uri {
    type: string
    sql: ${TABLE}.COURSE_URI ;;
  }

  dimension: default_aggregation_spec {
    type: string
    sql: ${TABLE}.DEFAULT_AGGREGATION_SPEC ;;
  }

  dimension: excluded {
    type: yesno
    sql: ${TABLE}.EXCLUDED ;;
  }

  dimension: external_properties {
    type: string
    sql: ${TABLE}.EXTERNAL_PROPERTIES ;;
  }

  dimension: prev_external_properties {
    type: string
    sql: ${TABLE}.PREV_EXTERNAL_PROPERTIES ;;
    hidden: yes
  }

  dimension: initial_external_properties {
    type: string
    sql: ${TABLE}.INITIAL_EXTERNAL_PROPERTIES ;;
    hidden: yes
  }

  dimension: max_takes {
    group_label: "Current Settings"
    description: "external_properties.soa:property:maxTakes"
    type: number
    sql:  TRY_CAST(${external_properties}:"soa:property:maxTakes":value:"$numberLong"::STRING as DECIMAL(3, 0)) ;;
  }

  dimension: prev_max_takes {
    group_label: "Previous Settings"
    description: "previous external_properties.soa:property:maxTakes"
    type: number
    sql:  TRY_CAST(${prev_external_properties}:"soa:property:maxTakes":value:"$numberLong"::STRING as DECIMAL(3, 0)) ;;
  }

  dimension: initial_max_takes {
    group_label: "Initial Settings"
    description: "previous external_properties.soa:property:maxTakes"
    type: number
    sql:  TRY_CAST(${initial_external_properties}:"soa:property:maxTakes":value:"$numberLong"::STRING as DECIMAL(3, 0)) ;;
  }

  dimension: label {
    type: string
    sql: ${TABLE}.LABEL ;;
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

  measure: count {
    type: count
    drill_fields: []
  }
}
