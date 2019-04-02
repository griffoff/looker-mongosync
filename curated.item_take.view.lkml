include:"curated.activity_take.view"
view: curated_item_take {
  extends: [curated_activity_take]
  derived_table: {
    explore_source: take_node_item {
      column: activity_item_uri {field: take_node.activity_node_uri}
    }
  }
  dimension: activity_item_uri {}
}
