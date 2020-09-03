view: course_enrollment {
  #sql_table_name: REALTIME.COURSE_ENROLLMENT ;;
  derived_table: {
    create_process: {
      sql_step:
        CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME}
        AS
        with data as (
          select
            _hash as business_key
            ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
            ,*
          from realtime.course_enrollment
          where user_identifier is not null
        )
        select *
        from data
        where latest = 1
        order by course_uri, user_identifier
        ;;

        sql_step:
          ALTER TABLE ${SQL_TABLE_NAME} cluster by (course_uri) ;;

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

  dimension: aggregated {
    type: yesno
    sql: ${TABLE}.AGGREGATED ;;
  }

  dimension: course_uri {
    view_label: "Course"
    type: string
    sql: ${TABLE}.COURSE_URI ;;
    link: {label: "View in Analytics Diagnostic Tool" url: "https://analytics-tools.cengage.info/diagnostictool/#/course/view/production/uri/{{ value }}"}
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

  dimension: user_groups {
    type: string
    sql: ${TABLE}.USER_GROUPS ;;
  }

  dimension: user_identifier {
    view_label: "User"
    label: "User GUID"
    type: string
    sql: ${TABLE}.user_identifier ;;
  }

  measure: users_enrolled{
    label: "# Distinct users"
    type: count_distinct
    sql: ${TABLE}.user_identifier ;;
    drill_fields: []
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
