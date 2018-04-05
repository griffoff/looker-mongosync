connection: "snowflake_prod"
label: "RealTime Data - Curated"

include: "datagroups.lkml"
include: "/core/common.lkml"
include: "*.view.lkml"
#include: "*.dashboard.lookml"  # include all dashboards in this project


explore: take_node_filtered {
  hidden: yes
  from: take_node
  view_name: take_node
  always_filter: {
    filters: {
      field: take_node.activity_uri
      value: "-%csfi%"
    }
#     filters: {
#       field: take_node.activity_uri
#       value: "~%als%"
#     }
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

  #add toc_metadata productcode, section_id = productcode, node_id

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

explore: curated_activity_take {}

explore: curated_item_take {}

explore: curated_user {}

explore: curated_item {}

explore: curated_activity {}

explore: activity_take {
  extension: required
  from: curated_activity_take
  join: item_take {
    from: curated_item_take
    sql_on: (${activity_take.external_take_uri}) = (${item_take.external_take_uri}) ;;
    relationship: one_to_many
  }
}

explore: item_take {
  label: "Item Takes"
  from: curated_item_take

  join: item {
    from: curated_item
    sql_on: ${item_take.activity_item_uri} = ${item.activity_item_uri} ;;
  }

  join: course {
    from: realtime_course
    sql_on: ${item_take.course_uri} = ${course.course_uri} ;;
  }
}

explore: activity_takes {
  label: "Activity Takes"
  from: curated_activity_take

  join: activity {
    from: curated_activity
    sql_on: ${activity_takes.activity_uri} = ${activity.activity_uri} ;;
  }

  join: course {
    from: realtime_course
    sql_on: ${activity_takes.course_uri} = ${course.course_uri} ;;
  }
}

explore: course {
  label: "Everything!"
  extends: [activity_take]
  from: realtime_course
  view_name: course

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
  }

}
