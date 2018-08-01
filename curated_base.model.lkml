connection: "snowflake_prod"
label: "RealTime Data - Curated (Simple Raw Views)"

include: "datagroups.lkml"
include: "/core/common.lkml"
include: "/cube/dims.lkml"
include: "*.view.lkml"
#include: "*.dashboard.lookml"  # include all dashboards in this project

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


# Hide these when real models are created
# they are just used for exploring the individual tables
explore: curated_activity_take {}

explore: curated_item_take {}

explore: curated_user {}

explore: curated_item {}

explore: curated_activity {}
