connection: "snowflake_prod"
label: "RealTime Data - Curated"

include: "datagroups.lkml"
include: "/core/common.lkml"
include: "/cube/dims.lkml"
include: "*.view.lkml"
#include: "*.dashboard.lookml"  # include all dashboards in this project

# Hide these when real models are created
# they are just used for exploring the individual tables
explore: curated_activity_take {}

explore: curated_item_take {}

explore: curated_user {}

explore: curated_item {}

explore: curated_activity {}

# These explores are used as the base for NDTs (Native derived tables)
# there is in inheritance chain
explore: take_node_filtered {
  hidden: yes
  from: take_node
  view_name: take_node

  join: activity_type_map {
    sql_on: ${take_node.activity_type_uri} = ${activity_type_map.activity_type_uri_source} ;;
    relationship: many_to_one
  }

  always_filter: {
    filters: {
      field: activity_type_map.is_survey
      value: "No"
    }
    filters: {
      field: activity_type_map.activity_type_uri
      value: "-als-pete"
    }

    filters: {
      field: take_node.mastery_item
      value: "No"
    }


  }
}

explore: take_node_activity {
  hidden: yes
  extends: [take_node_filtered]
  from: take_node
  view_name: take_node

  join: product_activity_metadata {
    sql_on: (${take_node.product_code}, ${take_node.section_id}) = (${product_activity_metadata.product_code}, ${product_activity_metadata.item_id}) ;;
    relationship: many_to_one
  }

  join: product_toc_metadata {
    sql_on: (${product_activity_metadata.product_code}, ${product_activity_metadata.item_id}) = (${product_toc_metadata.product_code}, ${product_toc_metadata.node_id}) ;;
    relationship: many_to_one
  }

  always_filter: {
    filters: {
      field: take_node.activity
      value: "Yes"
    }
  }
}

explore: take_node_item {
  hidden: yes
  extends: [take_node_activity]
  view_name: take_node

  join: product_item_metadata {
    sql_on: ${take_node.activity_node_uri} = ${product_item_metadata.item_uri} ;;
    relationship: many_to_one
  }

  join: product_toc_metadata {
    sql_on: (${product_item_metadata.product_code}, ${product_item_metadata.item_id}) = (${product_toc_metadata.product_code}, ${product_toc_metadata.node_id}) ;;
    relationship: many_to_one
  }

  always_filter: {
    filters: {
      field: take_node.activity
      value: "No"
    }
  }
}

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
