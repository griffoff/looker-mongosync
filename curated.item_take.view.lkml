include:"curated.activity_take.view"
include:"curated.item.view"
explore: curated_item_take {
  hidden: yes
  join: item {
    sql_on: ${curated_item_take.activity_node_uri} = ${item.activity_node_uri} ;;
    relationship: many_to_one

  }
}

view: item {
  extends: [curated_item]
}

view: curated_item_take {
  extends: [final_grade]

  sql_table_name: looker_scratch.item_take_items ;;

  dimension: hash {
    primary_key:yes
    hidden:yes
  }
  dimension: activity_uri{type: string hidden:yes}
  dimension: activity_node_uri{type: string
    sql:CASE
        WHEN ${TABLE}.ACTIVITY_NODE_URI LIKE 'wa:%'
        THEN regexp_replace(${TABLE}.activity_node_uri, '(:box:\\d+)$', '')
        ELSE ${TABLE}.ACTIVITY_NODE_URI
        END ;;}
  dimension: external_take_uri{
    type: string
    link: {
      url: "cengage.looker.com/explore/activity_takes?_f['activity_take.external_take_uri']={{value | url_encode }}"
      label: "View all take nodes"
      }
    hidden: yes
  }
  dimension: course_uri{type: string hidden:yes}
  dimension: user_identifier{type: string hidden:yes}
  dimension: possible_score{type: number}
  dimension: interaction_grade{type: number}
  dimension: activity_grade{type: number}
  dimension: last_update_date{type: date_raw hidden:yes}
  dimension: parent_path{type: string}
  dimension: position_path{type: string}
  dimension: course_key{type: string hidden:yes}
  dimension: activity_node_product_code{type: string}
  dimension: activity_node_item_id{type: string}
  dimension: assignable_content_product_section_imilac{type: string hidden: yes}
  dimension: assignable_content_product_abbr{type: string hidden: yes}
  dimension: assignable_content_uri_section_id{type: string hidden: yes}
  dimension: product_code{type: string}
  dimension: item_id{type: string}
  dimension: section_id{type: string hidden:yes}
  dimension: attempts{type: number}

  dimension_group: submission_date{
    type: time
    timeframes: [time, date, time_of_day, hour_of_day, day_of_week]
  }
  dimension: final_grade {
    type: string
    hidden: yes
  }
  dimension: external_properties_raw {
    group_label: "External Properties"
    type: string
    sql: ${TABLE}.external_properties ;;
  }
  dimension: difficulty {
    group_label: "External Properties"
    type: number
    sql:  ${external_properties_raw}:"cengage:book:item:difficulty"::FLOAT;;
  }
  dimension: question_type {
    group_label: "External Properties"
    label: "Item Type"
    type: string
    sql:  UPPER(TRIM(
            COALESCE(
              SPLIT_PART(COALESCE(
              ${external_properties_raw}:"cengage:book:item:problem-type"
              , ${external_properties_raw}:"cas:property:question:type"
              )::STRING, ':', -1)
            ,${item.item_type})
            ));;
  }
  dimension: container_type {
    group_label: "External Properties"
    type: string
    sql: ${external_properties_raw}:"analytics:container-type";;
    }
  dimension: node_type {
    group_label: "External Properties"
    type: string
    sql: ${external_properties_raw}:"analytics:node-type";;
  }

  measure: sum_questions_attempted {
    type: number
    hidden: yes
    sql: NULLIF(COUNT(CASE WHEN ${attempts} > 0 THEN 1 END), 0) ;;
  }

  measure: avg_question_attempts {
    type: average
    sql: NULLIF(${attempts}, 0) ;;
  }

  measure: final_grade_percent_correct {
    group_label: "Score"
    type: number
    sql: COUNT(CASE WHEN ${final_grade_score} = 1 THEN 1 END) / ${sum_questions_attempted};;
    value_format_name: percent_1
  }

  measure: final_grade_percent_correct_attempt_1 {
    group_label: "Score"
    type: number
    sql: COUNT(CASE WHEN ${final_grade_score} = 1 AND ${attempts} = 1 THEN 1 END) / ${sum_questions_attempted};;
    value_format_name: percent_1
  }

  measure: final_grade_percent_correct_attempt_2 {
    group_label: "Score"
    type: number
    sql: COUNT(CASE WHEN ${final_grade_score} = 1 AND ${attempts} <= 2 THEN 1 END) / ${sum_questions_attempted};;
    value_format_name: percent_1
  }



}
