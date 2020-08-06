include: "curated_base.model"
label: "RealTime Data - Curated"
include: "//cube/dims.lkml"

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
      and COALESCE(${activity_take.activity_type_uri}, '') = COALESCE(${activity.activity_type_uri}, '');;
    relationship: many_to_one
  }

}

explore: course {
  extension: required
  from: realtime_course
  view_name: course

  join: mindtap_snapshot {
    relationship: one_to_one
    sql_on: ${course.snapshot_label} = ${mindtap_snapshot.snapshotid};;
  }

#   join: dim_course {
#     sql_on: coalesce(${mindtap_snapshot.coursekey}, ${course.course_key}) = ${dim_course.coursekey} ;;
#     relationship: one_to_one
#   }

#   join: dim_course {
#     sql_on: (${course.course_key}) = (${dim_course.coursekey}) ;;
#     relationship: one_to_one
#   }
}


# Models for exploration
explore: item_take {
  label: "Item Takes"
  from: curated_item_take
  extends: [dim_course]

  join: item {
    from: curated_item
    sql_on: ${item_take.activity_item_uri} = ${item.activity_item_uri} ;;
    relationship: many_to_one
  }

  join: course {
    from: realtime_course
    sql_on: ${item_take.course_uri} = ${course.course_uri} ;;
    relationship: many_to_one
  }

  join: dim_course {
    sql_on: ${course.course_key} = ${dim_course.coursekey} ;;
    relationship: one_to_one
  }

}

explore: course_activity {
  extension: required

  join: course_activity_group {
    sql: inner join lateral flatten(${course_activity.activity_group_uris}, outer=>True) g on g.value != 'soa:activity-group:default'
        left join ${course_activity_group.SQL_TABLE_NAME} course_activity_group on ${course_activity.course_uri} = ${course_activity_group.course_uri}
                                      and g.value = ${course_activity_group.activity_group_uri}
          ;;
  }

}

explore: activity_takes {
  label: "Activity Takes"
  from: curated_activity_take
  view_name: activity_take
  extends: [course, course_activity, activity_take]

  join: course_activity {
    #fields: []
    sql_on: ${activity_take.course_uri} = ${course_activity.course_uri}
          and ${activity_take.activity_uri} = ${course_activity.activity_uri};;
    relationship: many_to_one
  }

  join: course {
    from: realtime_course
    sql_on: ${activity_take.course_uri} = ${course.course_uri} ;;
    relationship: many_to_one
  }

}

explore: courses {
  label: "Everything!"
  from: realtime_course
  view_name: course
  extends: [course, course_activity, activity_take]

  join: course_enrollment {
    fields: []
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
    sql_on: ${course.course_uri} = ${course_activity.course_uri};;
    relationship: many_to_one
  }

  join: activity_take {
    from: curated_activity_take
    sql_on: ${course_activity.activity_uri} = ${activity_take.activity_uri}
          and ${course_enrollment.user_identifier} = ${activity_take.user_identifier};;
    relationship: one_to_many
  }

}
