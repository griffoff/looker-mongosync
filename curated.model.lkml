include: "curated_base.model"
label: "RealTime Data - Curated"

# Models for extension
explore: activity_take {
  extension: required
  from: curated_activity_take
  join: item_take {
    from: curated_item_take
    sql_on: (${activity_take.external_take_uri}) = (${item_take.external_take_uri}) ;;
    relationship: one_to_many
  }
}

explore: course {
  extension: required
  from: realtime_course
  view_name: course

  join: dim_course {
    sql_on: (${course.course_key}) = (${dim_course.coursekey}) ;;
    relationship: one_to_one
  }
}

# Models for exploration
explore: item_take {
  label: "Item Takes"
  from: curated_item_take

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
}

explore: activity_takes {
  label: "Activity Takes"
  from: curated_activity_take
  view_name: activity_takes
  extends: [course]

  join: activity {
    from: curated_activity
    sql_on: ${activity_takes.activity_uri} = ${activity.activity_uri}
            and ${activity_takes.activity_type_uri} = ${activity.activity_type_uri};;
    relationship: many_to_one
  }

  join: user {
    sql_on: ${activity_takes.user_identifier} = ${user.source_id} ;;
    relationship: many_to_one
  }

  join: dim_party {
    sql_on: ${activity_takes.user_identifier} = ${dim_party.guid_raw} ;;
    relationship: many_to_one
  }

  join: course {
    from: realtime_course
    sql_on: ${activity_takes.course_uri} = ${course.course_uri} ;;
    relationship: many_to_one
  }
}

explore: courses {
  label: "Everything!"
  from: realtime_course
  view_name: course
  extends: [activity_take, course]

  join: course_activity {
    fields: []
    sql_on: ${course.course_uri} = ${course_activity.course_uri} ;;
    relationship: one_to_many
  }

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

  join: activity {
    from: curated_activity
    sql_on: ${course_activity.activity_uri} = ${activity.activity_uri} ;;
    relationship: many_to_one
  }

  join: activity_take {
    from: curated_activity_take
    sql_on: ${activity.activity_uri} = ${activity_take.activity_uri}
          and ${user.user_identifier} = ${activity_take.user_identifier};;
    relationship: one_to_many
  }

}
