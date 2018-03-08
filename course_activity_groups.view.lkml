view: course_activity_groups {
  derived_table: {
    sql:
      select
        course_uri
        ,activity_uri
        ,groups.value::string as activity_group_uri
        ,hash(course_uri, activity_uri, activity_group_uri) as primary_key
      from ${course_activity.SQL_TABLE_NAME} course_activity
      cross join lateral flatten(course_activity.activity_group_uris) groups
      order by 1, 2, 3
      ;;

      datagroup_trigger: realtime_default_datagroup
  }

  dimension: primary_key {
    type: string
    hidden: yes
    primary_key: yes
  }

  dimension: course_uri {type:string hidden:yes}
  dimension: activity_uri {type:string hidden:yes}
  dimension: activity_group_uri {type:string hidden:yes}

}
