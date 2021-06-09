#include: "curated_base.model"

include: "//core/common.lkml"
include: "//cengage_unlimited/views/cu_user_analysis/user_profile.view"
include: "//cengage_unlimited/views/cu_user_analysis/course_info.explore"
#include: "//fivetran_mindtap/nb.snapshot.view"

include: "take_node.view"
include: "datagroups.lkml"

include: "./node_summary.view"
include: "./TAGS.*"
include: "./realtime_course.view"
include: "/csfi_view.view"
# include: "./lo_items.view"

connection: "snowflake_prod"
label: "Realtime - Source"


# persist_with: realtime_default_datagroup


explore: all_take_nodes {
  view_label: "Take Node"
  from: take_node
  view_name: take_node
  label: "All Take Nodes"
  description: "All taken 'nodes' linked back to course information and to content books."
  extends: [course_info, user_profile, take_node]
  hidden: no

  join: realtime_course {
    relationship: many_to_one
    sql_on: ${take_node.course_uri} = ${realtime_course.course_uri} ;;
  }

  join: course_info {
    sql_on: ${realtime_course.course_key} = ${course_info.course_key} ;;
    type: left_outer
    relationship: many_to_one
  }

  # join: lo_items {
  #   sql_on: ${take_node.activity_node_item_id} = ${lo_items.item_identifier} ;;
  #   relationship: many_to_one
  # }

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

  join: user_profile {
    view_label: "User Info"
    sql_on: ${take_node.user_identifier} = ${user_profile.user_sso_guid} ;;
    relationship: many_to_one
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

}
