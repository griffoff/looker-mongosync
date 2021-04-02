include: "//cengage_unlimited/views/cu_user_analysis/course_info.explore"
include: "//cengage_unlimited/views/cu_user_analysis/user_profile.view"
include: "./TAGS.*.view"
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
  hidden: yes
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

# Models for exploration
explore: item_take {
  label: "Item Takes"
  from: curated_item_take
  view_name: item_take
  extends: [realtime_course]
  hidden: yes

  join: item {
    from: curated_item
    sql_on: ${item_take.activity_node_uri} = ${item.activity_node_uri} ;;
    relationship: many_to_one
  }

  join: realtime_course {
    sql_on: ${item_take.course_uri} = ${realtime_course.course_uri} ;;
    relationship: many_to_one
  }

  join: tx_state_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${tx_state_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: snhu_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${snhu_items.cnow_item_id} ;;
    relationship: many_to_one
  }

  join: csu_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${csu_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: nwtc_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${nwtc_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: nwtc_payroll_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${nwtc_payroll_items.item_identifier};;
    relationship: many_to_one
  }

  join: concorde_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${concorde_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: rcc_bus_10_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${rcc_bus_10_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: rcc_mag_51_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${rcc_mag_51_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: hbu_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${hbu_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: snu_items {
    view_label: "LOTS"
    sql_on: ${item_take.activity_node_item_id} = ${snu_items.item_identifier} ;;
    relationship: many_to_one
  }

}

explore: activity_takes {
  extends: [realtime_course, course_activity, activity_take, item_take, user_profile]
  label: "Activity Takes"
  view_label: "Activity Takes"
  description: "This is a view of all activity and item takes including related information such as activity, product, user, institution metadata"
  from: curated_activity_take
  view_name: activity_take
  hidden: no

  join: course_activity {
    fields: []
    sql_on: ${activity_take.course_uri} = ${course_activity.course_uri}
          and ${activity_take.activity_uri} = ${course_activity.activity_uri};;
    relationship: many_to_one
  }

  join: realtime_course {
    sql_on: ${activity_take.course_uri} = ${realtime_course.course_uri} ;;
    relationship: one_to_one
  }

  join: user_profile {
    sql_on: ${activity_take.user_identifier}  = ${user_profile.user_sso_guid};;
    relationship: many_to_one
  }

}

# explore: courses {
#   case_sensitive: yes
#   label: "Everything!"
#   fields: [ALL_FIELDS*, -course.course_uri, -user.user_identifier]
#   from: realtime_course
#   view_name: course
#   extends: [course, course_activity, activity_take]
#   hidden: yes

#   join: course_enrollment {
#     fields: [course_enrollment.course_uri, course_enrollment.user_identifier]
#     sql_on: ${course.course_uri} = ${course_enrollment.course_uri} ;;
#     relationship: one_to_many
#   }

#   join: user {
#     from: curated_user
#     sql_on: ${course_enrollment.user_identifier} = ${user.user_identifier} ;;
#     relationship: many_to_one
#   }

#   join: course_activity {
#     #fields: []
#     sql_on: ${course_enrollment.course_uri} = ${course_activity.course_uri};;
#     relationship: one_to_many
#   }

#   join: activity_take {
#     from: curated_activity_take
#     sql_on: ${course_enrollment.course_uri} = ${activity_take.course_uri}
#           and ${course_activity.activity_uri} = ${activity_take.activity_uri}
#           and ${course_enrollment.user_identifier} = ${activity_take.user_identifier};;
#     relationship: one_to_many
#   }

# }
