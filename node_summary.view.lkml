view: node_summary {
  sql_table_name: REALTIME.NODE_SUMMARY ;;

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

  dimension: activity_node_uri {
    type: string
    sql: ${TABLE}.ACTIVITY_NODE_URI ;;
  }

  dimension: correct_count {
    type: number
    sql: ${TABLE}.CORRECT_COUNT ;;
  }

  dimension: correct_percentage {
    type: number
    sql: ${TABLE}.CORRECT_PERCENTAGE ;;
  }

  dimension: difficulty {
    type: number
    sql: ${TABLE}.DIFFICULTY ;;
  }

  dimension: hash {
    type: string
    sql: ${TABLE}.HASH ;;
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

  dimension_group: latest_submission {
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
    sql: ${TABLE}.LATEST_SUBMISSION_DATE ;;
  }

  dimension: mastery_item {
    type: yesno
    sql: ${TABLE}.MASTERY_ITEM ;;
  }

  dimension: normal_score_summary {
    type: string
    sql: ${TABLE}.NORMAL_SCORE_SUMMARY ;;
  }

  dimension: possible_score_summary {
    type: string
    sql: ${TABLE}.POSSIBLE_SCORE_SUMMARY ;;
  }

  dimension: scaled_score_summary {
    type: string
    sql: ${TABLE}.SCALED_SCORE_SUMMARY ;;
  }

  dimension: scored_count {
    type: number
    sql: ${TABLE}.SCORED_COUNT ;;
  }

  dimension: successful_user_count {
    type: number
    sql: ${TABLE}.SUCCESSFUL_USER_COUNT ;;
  }

  dimension: time_spent_count {
    type: number
    sql: ${TABLE}.TIME_SPENT_COUNT ;;
  }

  dimension: time_spent_summary {
    type: string
    sql: ${TABLE}.TIME_SPENT_SUMMARY ;;
  }

  dimension: total_take_count {
    type: number
    sql: ${TABLE}.TOTAL_TAKE_COUNT ;;
  }

  dimension: tried_summary {
    type: string
    sql: ${TABLE}.TRIED_SUMMARY ;;
  }

  dimension: unique_user_count {
    type: number
    sql: ${TABLE}.UNIQUE_USER_COUNT ;;
  }

  dimension: unscored_count {
    type: number
    sql: ${TABLE}.UNSCORED_COUNT ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
