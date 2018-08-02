connection: "snowflake_prod"
label: "Realtime - Source"

include: "/core/common.lkml"
include: "/cube/dims.lkml"
include: "datagroups.lkml"

include: "/project_source/*.view.lkml"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

persist_with: realtime_default_datagroup


explore: product_activity_metadata {}

explore: product_item_metadata {
  fields: [ALL_FIELDS*, -product_item_metadata.discipline]
  #extension: required
  join: node_summary {
    sql_on: (${product_item_metadata.item_uri}) = (${node_summary.activity_node_uri}) ;;
    relationship: one_to_one
  }
}

explore: take_node {
  extension: required

  join: product_activity_metadata {
    sql_on: (${take_node.product_code}, ${take_node.section_id}) = (${product_activity_metadata.product_code}, ${product_activity_metadata.item_id}) ;;
    relationship: many_to_one
  }

  join: product_item_metadata {
    sql_on: ${take_node.activity_node_uri} = ${product_item_metadata.item_uri} ;;
    relationship: many_to_one
  }

  join: product_toc_metadata {
    sql_on: (${product_item_metadata.product_code}, ${product_item_metadata.item_id}) = (${product_toc_metadata.product_code}, ${product_toc_metadata.node_id}) ;;
    relationship: many_to_one
  }

  join: product_mastery_group {
    sql_on: ${take_node.activity_node_uri_masterygroup_cgid} = ${product_mastery_group.computed_hash} ;;
    relationship: many_to_one
  }
}

explore: course_activity {
  extension: required
# this is the way to do it without persisting course_activity_groups, there is a bug in snowflake that makes this fail currently
# https://support.snowflake.net/s/case/5000Z00000tEe65QAC/bug-with-lateral-flatten-alias
#   join: course_activity_groups {
#     required_joins: [course_activity]
#     sql_table_name:  lateral flatten(course_activity.activity_group_uris, outer=>True);;
#     type: cross
#     relationship: one_to_many
#   }

  join: course_activity_groups {
    sql_on: (${course_activity.course_uri}, ${course_activity.activity_uri}) = (${course_activity_groups.course_uri}, ${course_activity_groups.activity_uri})  ;;
    relationship: one_to_many
  }

  join: course_activity_group {
    required_joins: [course_activity_groups]
    #sql_on: (${course_activity.course_uri}, course_activity_groups.value::string = (${course_activity_group.course_uri}, ${course_activity_group.activity_group_uri});;
    sql_on: (${course_activity_groups.course_uri}, ${course_activity_groups.activity_group_uri}) = (${course_activity_group.course_uri}, ${course_activity_group.activity_group_uri});;
    relationship: many_to_one
  }
}

explore: realtime_course {
  view_label: "Course"
  extends: [dim_course, product_item_metadata, course_activity, take_node]

  join: dim_course {
    sql_on: ${realtime_course.course_key} = ${dim_course.coursekey} ;;
    relationship: one_to_one
  }

  join: course_activity {
    sql_on: ${realtime_course.course_uri} = ${course_activity.course_uri} ;;
    relationship: one_to_many
  }

  join: course_enrollment{
    sql_on: ${realtime_course.course_uri} = ${course_enrollment.course_uri} ;;
    relationship: one_to_many
  }

  join: take_node {
   sql_on: (${course_activity.course_uri}, ${course_activity.activity_uri}, ${course_enrollment.user_identifier})
       = (${take_node.course_uri}, ${take_node.activity_uri}, ${take_node.user_identifier});;
   relationship: one_to_many
  }

}

explore: product_toc_metadata {
  extends: [product_item_metadata, dim_product]
  label: "CXP Content Service"
  join: product_item_metadata {
    sql_on: (${product_toc_metadata.source_system}, ${product_toc_metadata.product_code})
        = (${product_item_metadata.source_system}, ${product_item_metadata.product_code})
          ;;
    relationship: one_to_many
  }
  join: dim_product {
    sql_on: ${product_toc_metadata.isbn} = ${dim_product.isbn13} ;;
    relationship: many_to_one
  }
  join: product_activity_metadata {
    sql_on: (${product_toc_metadata.source_system}, ${product_toc_metadata.product_code})
        = (${product_activity_metadata.source_system}, ${product_activity_metadata.product_code})
          ;;
    relationship: one_to_many
  }
  join: product_mastery_group {
    sql_on: (${product_toc_metadata.source_system}, ${product_toc_metadata.product_code})
        = (${product_mastery_group.source_system}, ${product_mastery_group.product_code})
          ;;
    relationship: one_to_many
  }
}

explore: node_summary {
  label: "Weekly Item Summery"
  description: "This contains all 'nodes' from realtime, including, items, mastery groups and activities, summerized into per week usage."
}

explore: all_take_nodes {
  from: take_node
  view_name: take_node
  label: "All Take Nodes"
  description: "All taken 'nodes' linked back to course information and to content books."
  extends: [dim_course, take_node]

  join: realtime_course {
    relationship: many_to_one
    sql_on: ${take_node.course_uri} = ${realtime_course.course_uri} ;;
  }

  join: mindtap_snapshot {
    relationship: many_to_one
    sql_on: ${mindtap_snapshot.snapshotid} = ${realtime_course.snapshot_label} ;;
  }

  join: dim_course {
    sql_on: coalesce(${realtime_course.course_key},${mindtap_snapshot.coursekey}) = ${dim_course.coursekey} ;;
    relationship: one_to_one
  }

  join: course_activity {
    sql_on: (${take_node.course_uri}, ${take_node.activity_uri}) = (${course_activity.course_uri}, ${course_activity.activity_uri}) ;;
    relationship: one_to_many
  }

  join: course_enrollment{
    sql_on: (${take_node.course_uri}, ${take_node.user_identifier}) = (${course_enrollment.course_uri}, ${course_enrollment.user_identifier}) ;;
    relationship: many_to_one
  }

  join: product_toc_metadata {
    sql_on: (${take_node.product_code}) = (${product_toc_metadata.product_code}) ;;
    relationship: many_to_one
  }

  join: product_activity_metadata {
    sql_on: (${take_node.product_code}, ${take_node.assignable_content_product_section_id}) = (${product_activity_metadata.product_code}, ${product_activity_metadata.item_id}) ;;
    relationship: many_to_one
  }

  join: product_item_metadata {
    sql_on: (${take_node.product_code}, ${take_node.item_id}) = (${product_item_metadata.product_code}, ${product_item_metadata.item_id}) ;;
    relationship: many_to_one
  }

#   join: product_toc_metadata2 {
#     from: product_toc_metadata
#     sql_on: (${product_item_metadata.product_code}) = (${product_toc_metadata2.product_code}) ;;
#     relationship: many_to_one
#   }

}
