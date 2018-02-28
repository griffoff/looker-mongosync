connection: "snowflake_int"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

datagroup: realtime_default_datagroup {
  sql_trigger: SELECT current_date();;
  #max_cache_age: "24 hours"
}

persist_with: realtime_default_datagroup


explore: course {
  join: course_activity {
    sql_on: ${course.course_uri} = ${course_activity.course_uri} ;;
    relationship: one_to_many
  }
  join: course_enrollment{
    sql_on: ${course_enrollment.course_uri} = ${course_enrollment.course_uri} ;;
    relationship: one_to_many
  }
  join: take_node {
    sql_on: (${course.course_uri}, ${course_enrollment.user_sso_guid}, ${course_activity.activity_uri})
        = (${take_node.course_uri}, ${take_node.user_identifier}, ${take_node.activity_uri});;
    relationship: one_to_many
  }
}
