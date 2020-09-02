view: course_activity_group {
  #sql_table_name: REALTIME.COURSE_ACTIVITY_GROUP ;;
  derived_table: {
    create_process: {
      sql_step:
      CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME}
      As
        with data as (
          select
            _hash as business_key
            ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
            ,*
          from realtime.course_activity_group
        )
        select *
        from data
        where latest = 1
        order by course_uri, activity_group_uri
        ;;
      sql_step:
        ALTER TABLE ${SQL_TABLE_NAME} CLUSTER BY (course_uri, activity_group_uri);;
    }

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

  dimension: activity_group_type_uri {
    type: string
    sql: ${TABLE}.ACTIVITY_GROUP_TYPE_URI ;;
  }

  dimension: activity_group_uri {
    type: string
    sql: ${TABLE}.ACTIVITY_GROUP_URI ;;
  }

  dimension: activity_selection_rule {
    type: string
    sql: ${TABLE}.ACTIVITY_SELECTION_RULE ;;
  }

  dimension: course_uri {
    type: string
    sql: ${TABLE}.COURSE_URI ;;
  }

  dimension: external_properties {
    type: string
    sql: ${TABLE}.EXTERNAL_PROPERTIES ;;
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
