#include: "curated_base.model"
include: "//cengage_unlimited/views/cu_user_analysis/course_info.view"
include: "//cengage_unlimited/views/cu_user_analysis/user_profile.view"
include: "./curated.activity_take.view"
include: "./curated.item_take.view"
include: "./curated.item.view"
include: "./curated.user.view"
include: "./curated.activity.view"
include: "./realtime_course.view"
include: "./course_activity.view"
include: "./course_enrollment.view"
include: "./course_activity_group.view"

label: "RealTime Data - Curated"
connection: "snowflake_prod"

# Models for extension
explore: activity_take {
  extension: required
  from: curated_activity_take
  join: item_take {
    from: curated_item_take
    sql_on: (${activity_take.external_take_uri}) = (${item_take.external_take_uri}) ;;
    relationship: one_to_many
  }

  join: activity {
    from: curated_activity
    sql_on: ${activity_take.activity_uri} = ${activity.activity_uri}
      and ${activity_take.course_uri} = ${activity.course_uri};;
    relationship: many_to_one
  }

}

explore: course {
  extends: [course_info]
  extension: required
  from: realtime_course
  view_name: course

#   join: mindtap_snapshot {
#     relationship: one_to_one
#     sql_on: ${course.snapshot_label} = ${mindtap_snapshot.snapshotid};;
#   }

  join: course_info {
    sql_on: ${course.course_key} = ${course_info.course_key} ;;
    relationship: one_to_one
  }

}


# Models for exploration
explore: item_take {
  label: "Item Takes"
  from: curated_item_take
  view_name: item_take
  extends: [course]
  hidden: yes

  join: item {
    from: curated_item
    sql_on: ${item_take.activity_node_uri} = ${item.activity_node_uri} ;;
    relationship: many_to_one
  }

  join: course {
    from: realtime_course
    sql_on: ${item_take.course_uri} = ${course.course_uri} ;;
    relationship: many_to_one
  }

}

explore: course_activity {
  extension: required

  join: course_activity_group {
    fields: [course_activity_group.activity_group_type_uri]
    sql: left join lateral flatten(${course_activity.activity_group_uris}, outer=>True) g on g.value != 'soa:activity-group:default'
        left join ${course_activity_group.SQL_TABLE_NAME} course_activity_group on ${course_activity.course_uri} = ${course_activity_group.course_uri}
                                      and g.value = ${course_activity_group.activity_group_uri}
          ;;
    relationship: many_to_many
  }

}

explore: activity_takes {
  extends: [course, course_activity, activity_take, user_profile]
  label: "Activity Takes"
  view_label: "Activity Takes"
  from: curated_activity_take
  view_name: activity_take
  hidden: no

  join: course_activity {
    fields: []
    sql_on: ${course.course_uri} = ${course_activity.course_uri}
          and ${activity_take.activity_uri} = ${course_activity.activity_uri};;
    relationship: many_to_one
  }

  join: course {
    from: realtime_course
    sql_on: ${activity_take.course_uri} = ${course.course_uri} ;;
    relationship: one_to_one
  }

  join: user_profile {
    sql_on: ${activity_take.user_identifier}  = ${user_profile.user_sso_guid};;
    relationship: many_to_one
  }

}

explore: courses {
  case_sensitive: yes
  label: "Everything!"
  fields: [ALL_FIELDS*, -course.course_uri, -user.user_identifier]
  from: realtime_course
  view_name: course
  extends: [course, course_activity, activity_take]
  hidden: yes

  join: course_enrollment {
    fields: [course_enrollment.course_uri, course_enrollment.user_identifier]
    sql_on: ${course.course_uri} = ${course_enrollment.course_uri} ;;
    relationship: one_to_many
  }

  join: user {
    from: curated_user
    sql_on: ${course_enrollment.user_identifier} = ${user.user_identifier} ;;
    relationship: many_to_one
  }

  join: course_activity {
    #fields: []
    sql_on: ${course_enrollment.course_uri} = ${course_activity.course_uri};;
    relationship: one_to_many
  }

  join: activity_take {
    from: curated_activity_take
    sql_on: ${course_enrollment.course_uri} = ${activity_take.course_uri}
          and ${course_activity.activity_uri} = ${activity_take.activity_uri}
          and ${course_enrollment.user_identifier} = ${activity_take.user_identifier};;
    relationship: one_to_many
  }

}
