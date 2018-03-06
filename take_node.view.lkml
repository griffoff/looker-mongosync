view: take_node {
  #sql_table_name: REALTIME.TAKE_NODE ;;
  derived_table: {
    sql:
      with data as (
        select
          "HASH" as business_key
          ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
          ,*
          ,split_part(COURSE_URI, ':', -1)::string as course_key
        from realtime.take_node
      )
      select *
      from data
      where latest = 1
      order by course_uri, activity_uri, user_identifier, activity_node_uri
    ;;

      datagroup_trigger: realtime_default_datagroup
    }

  dimension: business_key {
    type: string
    hidden: yes
    primary_key: yes
  }

  dimension_group: _ldts {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}._LDTS ;;
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}._RSRC ;;
  }

  dimension: activity {
    type: yesno
    sql: ${TABLE}.ACTIVITY ;;
  }

  dimension: activity_grade {
    type: string
    sql: ${TABLE}.ACTIVITY_GRADE ;;
  }

  dimension: activity_node_uri {
    type: string
    sql: ${TABLE}.ACTIVITY_NODE_URI ;;
    link: {
      label: "Scores Across Discipline"
#       url: "/explore/realtime/take_node?fields=take_node.count,take_node.final_grade_score_avg, dim_product,discipline&f[take_node.activity_node_uri]={{ value }}"#
      url: "/looks/1882?f[take_node.activity_node_uri]={{ value }}"
    }
  }

  dimension: activity_type_uri {
    type: string
    sql: ${TABLE}.ACTIVITY_TYPE_URI ;;
  }

  dimension: activity_uri {
    type: string
    sql: ${TABLE}.ACTIVITY_URI ;;
  }

  dimension: assignable_content_uri {
    type: string
    sql: ${TABLE}.ASSIGNABLE_CONTENT_URI ;;
  }

  dimension: course_uri {
    type: string
    sql: ${TABLE}.COURSE_URI ;;
  }

  dimension: course_key {
    type: string
    #sql: split_part(${TABLE}.COURSE_URI, ':', -1)::string ;;
  }

  dimension: external_take_uri {
    type: string
    sql: ${TABLE}.EXTERNAL_TAKE_URI ;;
  }

  dimension: final_grade {
    group_label: "Final Grade"
    label: "Raw JSON"
    type: string
    sql: ${TABLE}.FINAL_GRADE ;;
  }

  dimension: final_grade_taken {
    group_label: "Final Grade"
    label: "Taken?"
    type: yesno
    sql: ${final_grade}:taken::boolean ;;
  }

  dimension: final_grade_scored {
    group_label: "Final Grade"
    label: "Scored?"
    type: yesno
    sql: ${final_grade}:scored::boolean ;;
  }

  dimension: final_grade_timespent {
    group_label: "Final Grade"
    label: "Time spent"
    type: number
    sql: ${final_grade}:timeSpent::float / 60 / 60 / 24;;
    value_format_name: duration_hms
  }

  dimension: final_grade_score {
    group_label: "Final Grade"
    label: "Score"
    type: number
    sql: ${final_grade}:normalScore::float ;;
    value_format_name: percent_1
  }

  dimension: final_grade_score_tiers {
    group_label: "Final Grade"
    label: "Score (Buckets)"
    type: tier
    tiers: [0.1, 0.25, 0.4, 0.6, 0.75, 0.9, 0.95]
    style: relational
    sql: ${final_grade_score} ;;
    value_format_name: percent_1

  }

  measure: final_grade_score_avg {
    group_label: "Final Grade"
    label: "Score (avg)"
    type: average
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }

  measure: final_grade_score_min {
    group_label: "Final Grade"
    label: "Score (min)"
    type: min
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }

  measure: final_grade_score_max {
    group_label: "Final Grade"
    label: "Score (max)"
    type: max
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
  }

  measure: final_grade_score_sd {
    group_label: "Final Grade"
    label: "Score (sd)"
    type: number
    sql: stdev( ${final_grade_score}) ;;
    value_format_name: percent_1
  }

  measure: final_grade_timespent_avg {
    group_label: "Final Grade"
    label: "Time spent (avg)"
    type: average
    sql: ${final_grade_timespent};;
    value_format_name: duration_hms
  }

  dimension: hash {
    type: string
    sql: ${TABLE}.HASH ;;
  }

  dimension: interaction_grade {
    type: string
    sql: ${TABLE}.INTERACTION_GRADE ;;
  }

  dimension_group: last_update {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.LAST_UPDATE_DATE ;;
  }

  dimension: mastery_item {
    type: yesno
    sql: ${TABLE}.MASTERY_ITEM ;;
  }

  dimension: possible_score {
    type: number
    sql: ${TABLE}.POSSIBLE_SCORE ;;
  }

  dimension_group: submission {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.SUBMISSION_DATE ;;
  }

  dimension: user_identifier {
    type: string
    sql: ${TABLE}.USER_IDENTIFIER ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: course_count {
    type: count_distinct
    sql: ${course_uri} ;;
  }

  measure: courses_with_takes {
    type: count_distinct
    sql: case when ${final_grade_taken} then ${course_uri} end ;;
  }

  measure: courses_with_takes_percent {
    type: number
    sql: ${courses_with_takes}/nullif(${course_count}, 0) ;;
    value_format_name: percent_1
  }

}
