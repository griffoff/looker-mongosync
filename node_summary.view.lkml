#include: "//core/named_formats.lkml"

view: node_summary {
#   sql_table_name: REALTIME.NODE_SUMMARY ;;
  derived_table: {
    sql:
      with data as (
        select
          hash as business_key
          ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
          ,*
        from realtime.node_summary
      )
      select *
      from data
      where latest = 1
      order by activity_node_uri
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
    value_format_name: percent_1
  }

  dimension: correct_percentage_tier {
    type: tier
    sql: ${correct_percentage} ;;
    tiers: [0.25, 0.5, 0.75]
    style: relational
    value_format_name: percent_0
  }

  dimension: difficulty {
    type: number
    sql: ${TABLE}.DIFFICULTY ;;
  }

  dimension: hash {
    type: string
    sql: ${TABLE}.HASH ;;
  }

  dimension_group: batch_key_date {
    type: time
    timeframes: [
      raw,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.batch_key_date ;;
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
#
#   {
#   "count": {
#     "$numberLong": "204"
#   },
#   "mean": 0.6813725490196079,
#   "standardDeviation": 0.465944201017815,
#   "sum": 139,
#   "sumOfSquares": 139
# }

  dimension: normal_score_count {
    group_label: "Normal Score Metrics"
    type: number
    sql: ${normal_score_summary}:count:$numberLong::int  ;;
  }

  dimension: normal_score_mean {
    group_label: "Normal Score Metrics"
    type: number
    sql: nullif(${normal_score_summary}:mean, 'NaN')::float  ;;
    value_format_name: percent_2
  }

  dimension: normal_score_stdev {
    group_label: "Normal Score Metrics"
    type: number
    sql: nullif(${normal_score_summary}:standardDeviation, 'NaN')::float  ;;
  }

  measure: normal_score_count_average {
    group_label: "Normal Score Metrics"
    type: average
    sql: ${normal_score_count}  ;;
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

  dimension: successful_percent {
    type: number
    sql: ${successful_user_count} / nullif(${scored_count}, 0) ;;
    value_format_name: percent_1
  }

  dimension: successful_percent_tier {
    type: tier
    tiers: [0.25, 0.5, 0.75]
    sql: ${successful_percent} ;;
    value_format_name: percent_0
  }

  dimension: time_spent_count {
    type: number
    sql: ${TABLE}.TIME_SPENT_COUNT ;;
  }

  dimension: time_spent_summary {
    type: string
    sql: ${TABLE}.TIME_SPENT_SUMMARY ;;
  }

#   dimension: time_spent_count {
#     group_label: "Time Spent Metrics"
#     hidden: yes
#     type: number
#     sql: ${time_spent_summary}:count:$numberLong::int  ;;
#   }

  dimension: time_spent_mean {
    group_label: "Time Spent Metrics"
    hidden: yes
    type: number
    sql: nullif(${time_spent_summary}:mean, 'NaN')::float / 60 / 60 / 24  ;;
    value_format_name: duration_hms
  }

  dimension: time_spent_stdev {
    group_label: "Time Spent Metrics"
    hidden: yes
    type: number
    sql: nullif(${time_spent_summary}:standardDeviation, 'NaN')::float  ;;
  }

  dimension: total_take_count {
    type: number
    sql: ${TABLE}.TOTAL_TAKE_COUNT ;;
  }

  measure: total_take_count_sum {
    type: sum
    sql: ${total_take_count} ;;
  }

  measure: total_take_count_avg {
    type: average
    sql: ${total_take_count} ;;
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
    drill_fields: [activity_node_uri, latest_submission_date, unique_user_count, successful_percent, time_spent_mean, normal_score_mean, mastery_item, difficulty]
  }
}
