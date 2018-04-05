connection: "snowflake_prod"

include: "datagroups.lkml"
include: "/core/common.lkml"
include: "*.view.lkml"
#include: "*.dashboard.lookml"  # include all dashboards in this project


explore: take_node_filtered {
  from: take_node
  view_name: take_node
  always_filter: {
    filters: {
      field: take_node.activity_uri
      value: "-%csfi%"
    }
    filters: {
      field: take_node.mastery_item
      value: "No"
    }
  }
}

explore: take_node_activity {
  extends: [take_node_filtered]
  from: take_node
  view_name: take_node

  join: product_activity_metadata {
    sql_on: (${take_node.product_code}, ${take_node.section_id}) = (${product_activity_metadata.product_code}, ${product_activity_metadata.item_id}) ;;
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

explore: curated_activity_take {
  join: curated_item_take {
    sql_on: (${curated_activity_take.external_take_uri}) = (${curated_item_take.external_take_uri}) ;;
    relationship: one_to_many
  }
}

explore: curated_item_take {}

explore: curated_user {}

explore: curated_item {}

explore: curated_activity {}
