connection: "snowflake_prod"

include: "/core/common.lkml"
include: "/cube/dims.model.lkml"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

datagroup: realtime_default_datagroup {
  #sql_trigger: SELECT current_date();;
  sql_trigger: select floor(datediff(hour, '2018-01-22 06:00:00', current_timestamp())) / 24 ;;
  #max_cache_age: "24 hours"
}

persist_with: realtime_default_datagroup


explore: product_item_metadata {
  extension: required
  join: node_summary {
    sql_on: (${product_item_metadata.item_uri}) = (${node_summary.activity_node_uri}) ;;
    relationship: one_to_one
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

explore: course {
  extends: [dim_course, product_item_metadata, course_activity]

  join: dim_course {
    sql_on: ${course.course_key} = ${dim_course.coursekey} ;;
    relationship: one_to_one
  }

#   join: take_node {
#     sql_on: ${course.course_uri} = ${take_node.course_uri};;
#     relationship: one_to_many
#   }
#
#   join: course_activity {
#     sql_on: (${take_node.course_uri}, ${take_node.activity_uri}) = (${course_activity.course_uri}, ${course_activity.activity_uri}) ;;
#     relationship: many_to_one
#   }
#
#   join: course_enrollment{
#     sql_on: (${take_node.course_uri}, ${take_node.user_identifier}) = (${course_enrollment.course_uri}, ${course_enrollment.user_identifier}) ;;
#     relationship: many_to_one
#   }


  join: course_activity {
    sql_on: ${course.course_uri} = ${course_activity.course_uri} ;;
    relationship: one_to_many
  }

  join: course_enrollment{
    sql_on: ${course.course_uri} = ${course_enrollment.course_uri} ;;
    relationship: one_to_many
  }

  join: take_node {
   sql_on: (${course_activity.course_uri}, ${course_activity.activity_uri}, ${course_enrollment.user_identifier})
       = (${take_node.course_uri}, ${take_node.activity_uri}, ${take_node.user_identifier});;
   relationship: one_to_many
  }

  join: product_item_metadata {
    sql_on: ${take_node.activity_node_uri} = ${product_item_metadata.item_id} ;;
    relationship: many_to_one
  }

}

explore: product_toc_metadata {
  extends: [product_item_metadata, dim_product]
  label: "CXP Item Analysis"
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
  label: "All Items (including CXP)"
}

explore: take_node {
  label: "All Take Nodes"
  extends: [dim_course]

  join: course {
    relationship: many_to_one
    sql_on: ${take_node.course_uri} = ${course.course_uri} ;;
  }

  join: dim_course {
    sql_on: ${course.course_key} = ${dim_course.coursekey} ;;
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
}
