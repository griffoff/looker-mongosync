include: "curated_base.model"
connection: "snowflake_prod"
label: "Realtime - Source"

include: "//core/common.lkml"
include: "//cengage_unlimited/views/cu_user_analysis/course_info.view"
include: "//cengage_unlimited/views/cu_user_analysis/product_info.view"
include: "realtime_course.view"
include: "datagroups.lkml"

include: "//project_source/*.view.lkml"

# persist_with: realtime_default_datagroup


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
  from: realtime_course
  view_name: realtime_course
  view_label: "Course"
  extends: [course_info, product_item_metadata, course_activity, take_node]

  join: course_info {
    sql_on: ${realtime_course.course_key} = ${course_info.course_key} ;;
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
  extends: [product_item_metadata, product_info]
  label: "CXP Content Service"
  join: product_item_metadata {
    sql_on: (${product_toc_metadata.source_system}, ${product_toc_metadata.product_code})
        = (${product_item_metadata.source_system}, ${product_item_metadata.product_code})
          ;;
    relationship: one_to_many
  }
  join: product_info {
    sql_on: ${product_toc_metadata.isbn} = ${product_info.isbn13} ;;
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

explore: lo_items {}

explore: node_summary {
  label: "Weekly Summary of Items"
  description: "This contains all 'nodes' from realtime, including, items, mastery groups and activities, summarized into per week usage. Use of metrics measures will likely result in NOT the data you want."
}

explore: all_take_nodes {
  from: take_node
  view_name: take_node
  label: "All Take Nodes"
  description: "All taken 'nodes' linked back to course information and to content books."
  extends: [course_info, take_node]

  join: realtime_course {
    relationship: many_to_one
    sql_on: ${take_node.course_uri} = ${realtime_course.course_uri} ;;
  }

  join: course_info {
    sql_on: ${realtime_course.course_key} = ${course_info.course_key} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: mindtap_snapshot {
    relationship: many_to_one
    sql_on: ${mindtap_snapshot.snapshotid} = ${realtime_course.snapshot_label};;
  }

  join: lo_items {
    sql_on: ${take_node.activity_node_item_id} = ${lo_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: tx_state_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${tx_state_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: snhu_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${snhu_items.cnow_item_id} ;;
    relationship: many_to_one
  }

  join: csu_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${csu_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: nwtc_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${nwtc_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: nwtc_payroll_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${nwtc_payroll_items.item_identifier};;
    relationship: many_to_one
  }

  join: concorde_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${concorde_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: rcc_bus_10_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${rcc_bus_10_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: rcc_mag_51_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${rcc_mag_51_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: hbu_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${hbu_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: snu_items {
    view_label: "LOTS"
    sql_on: ${take_node.activity_node_item_id} = ${snu_items.item_identifier} ;;
    relationship: many_to_one
  }

  join: all_users {
    view_label: "LMS User Info"
    sql_on: ${take_node.user_identifier} = ${all_users.user_sso_guid} ;;
    relationship: many_to_one
  }

#   join: course_two {
#     view_label: "course dup"
#     from: dim_course
#     sql_on:  ${mindtap_snapshot.coursekey} = ${course_two.coursekey} ;;
#     type: left_outer
#   }

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

explore: item_take {
  label: "Item Takes"
  from: curated_item_take

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
