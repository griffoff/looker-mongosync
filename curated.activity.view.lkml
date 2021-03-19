include: "curated_base.model"
include: "//core/named_formats.lkml"

view: curated_activity {
    derived_table: {
      create_process: {
        sql_step:
          use schema prod.looker_scratch
        ;;

        sql_step:
          create or replace temporary table activities
          as
          with content as (
            select
              assignable_content_uri
              , count(*) as total_takes
              , count(case when submission_date >= current_date - 30 then 1 end) as total_takes_last_30_days
              , count(distinct course_uri) as courses_with_activity
              , min(final_grade:normalScore::float) as final_score_min
              , avg(final_grade:normalScore::float) as final_score_avg
              , max(final_grade:normalScore::float) as final_score_max
              , median(final_grade:normalScore::float) as final_score_med
              , min(final_grade:timeSpent::float) as time_spent_min
              , avg(final_grade:timeSpent::float) as time_spent_avg
              , max(final_grade:timeSpent::float) as time_spent_max
              , median(final_grade:timeSpent::float) as time_spent_med
            from looker_scratch.item_take_activities
            where assignable_content_uri is not null
            group by 1
          )
          ,course_activities as (
          select
            activity_uri
            , any_value(activity_type_uri) as activity_type_uri
            , any_value(external_properties:"analytics:activity-type") as activity_type
            , any_value(a.assignable_content_uri) as assignable_content_uri
            , count(*) as course_activity_total_takes
            , count(case when submission_date >= current_date - 30 then 1 end) as course_activity_total_takes_last_30_days
            , min(final_grade:normalScore::float) as course_activity_final_score_min
            , avg(final_grade:normalScore::float) as course_activity_final_score_avg
            , max(final_grade:normalScore::float) as course_activity_final_score_max
            , median(final_grade:normalScore::float) as course_activity_final_score_med
            , min(final_grade:timeSpent::float) as course_activity_time_spent_min
            , avg(final_grade:timeSpent::float) as course_activity_time_spent_avg
            , max(final_grade:timeSpent::float) as course_activity_time_spent_max
            , median(final_grade:timeSpent::float) as course_activity_time_spent_med
          from looker_scratch.item_take_activities a
          where a.activity_uri is not null
          group by 1
          )
          select
              a.*
              , c.total_takes
              , c.total_takes_last_30_days
              , c.courses_with_activity
              , c.final_score_min
              , c.final_score_avg
              , c.final_score_max
              , c.final_score_med
              , c.time_spent_min
              , c.time_spent_avg
              , c.time_spent_max
              , c.time_spent_med
          from course_activities a
          left join content c on a.assignable_content_uri = c.assignable_content_uri
        ;;

        sql_step:
          create or replace temporary table adfs
          as
          select concat('soa:prod:activity:', cgi) as activity_uri, title as label, count(*) as pop, row_number() over (partition by activity_uri order by pop desc) as n
          from lcs.prod.adf
          group by 1, 2
        ;;

        sql_step:
          create or replace temporary table labels
          as
          select activity_uri, label, count(*) as pop, row_number() over (partition by activity_uri order by pop desc) as n
          from realtime.course_activity
          group by 1, 2
        ;;

        sql_step:
          create or replace temporary table toc
          as
          select concat(source_system, ':activity:', product_code, decode(source_system, 'cxp', '-', '/'), node_id) as activity_uri, name as label, count(*) as pop, row_number() over (partition by activity_uri order by pop desc) as n
          from realtime.product_toc_metadata
          group by 1, 2
        ;;

        sql_step:
          create or replace temporary table all_labels
          as
          with l as (
            select 'LCS.PROD.ADF' as source, * from adfs where n = 1
            union all
            select 'PROD.REALTIME.COURSE_ACTIVITY', * from labels where n = 1 and upper(label) != 'UNKNOWN'
            union all
            select 'PROD.REALTIME.PrODUCT_TOC_METADATA', * from toc where n = 1
          )
          ,d as (
              select source, activity_uri, label, row_number() over(partition by activity_uri order by pop desc) = 1 as keep
              from l
          )
          select *
          from d
          where keep
        ;;

        sql_step:
          create or replace transient table ${SQL_TABLE_NAME}
          as
          select
              split_part(a.activity_uri, ':', 1) as source_system
              ,a.*
              ,l.source as label_source
              ,l.label
              ,NULL::STRING as content_label
          from activities a
          left join all_labels l on a.activity_uri = l.activity_uri
        ;;

        sql_step:
          merge into ${SQL_TABLE_NAME} a
          using (
            with content_name as (
              select
                assignable_content_uri
                , label
                , row_number() over (partition by assignable_content_uri order by label is null, course_activity_total_takes desc) = 1 as preferred
              from ${SQL_TABLE_NAME}
            )
            select
              assignable_content_uri
              , label
            from content_name
            where preferred
            ) c on a.assignable_content_uri = c.assignable_content_uri
          when matched then update
            set content_label = c.label
          ;;
      }

      persist_for: "24 hours"
    }

    dimension: source_system {}
    dimension: activity_uri {primary_key:yes}
    dimension: assignable_content_uri {}
    dimension: activity_type_uri {}
    dimension: activity_type {}
    dimension: label {
      label: "Activity Name"
      alias:[activity_name]
      sql: coalesce(${TABLE}.label, ${TABLE}.content_label, ${assignable_content_uri}, ${activity_uri}) ;;
      description: "Activity Name from the course section, falls back to conformed name, assignable_content_uri and activity_uri when activity names are not available"
      }
    dimension: content_label {
      label: "Conformed Activity Name"
      sql: coalesce(${TABLE}.content_label, ${label}) ;;
      description: "Name from activity in all courses with the most takes"
    }
    dimension: label_source {}
    dimension: final_score_min {hidden: yes group_label:"Overall Activity Metrics" value_format_name: percent_1}
    dimension: final_score_avg {hidden: no label: "Avg. Final Score" group_label:"Overall Activity Metrics" value_format_name: percent_1}
    dimension: final_score_max {hidden: yes group_label:"Overall Activity Metrics" value_format_name: percent_1}
    dimension: final_score_med {hidden: no label: "Median Final Score" group_label:"Overall Activity Metrics" value_format_name: percent_1}
    dimension: time_spent_min {hidden: yes group_label:"Overall Activity Metrics" type: number value_format_name: duration_minutes sql: ${TABLE}.time_spent_min / (3600 * 24);;}
    dimension: time_spent_avg {hidden: yes group_label:"Overall Activity Metrics" type: number value_format_name: duration_minutes sql: ${TABLE}.time_spent_avg / (3600 * 24);;}
    dimension: time_spent_max {hidden: yes group_label:"Overall Activity Metrics" type: number value_format_name: duration_minutes sql: ${TABLE}.time_spent_max / (3600 * 24);;}
    dimension: time_spent_med {hidden: no label: "Median Time Spent" group_label:"Overall Activity Metrics" type: number value_format_name: duration_minutes sql: ${TABLE}.time_spent_med / (3600 * 24);;}
    dimension: total_takes_last_30_days {
      group_label:"Overall Activity Metrics"
      type: tier
      style: integer
      tiers: [1, 10, 100, 500, 1000, 10000]
    }
    dimension: total_takes {
      group_label:"Overall Activity Metrics"
      type: tier
      style: integer
      tiers: [1, 10, 100, 500, 1000, 10000]
    }
    dimension: courses_with_activity {
      group_label:"Overall Activity Metrics"
      type: tier
      style: integer
      tiers: [1, 10, 100, 500, 1000, 10000]
    }

  dimension: course_activity_final_score_min {hidden: yes group_label:"Course Section Activity Metrics" value_format_name: percent_1}
  dimension: course_activity_final_score_avg {hidden: no label: "Course Section Avg. Final Score" group_label:"Course Section Activity Metrics" value_format_name: percent_1}
  dimension: course_activity_final_score_max {hidden: yes group_label:"Course Section Activity Metrics" value_format_name: percent_1}
  dimension: course_activity_final_score_med {hidden: no label: "Course Section Avg. Final Score" group_label:"Course Section Activity Metrics" value_format_name: percent_1}
  dimension: course_activity_time_spent_min {hidden: yes group_label:"Course Section Activity Metrics" type: number value_format_name: duration_minutes sql: ${TABLE}.course_activity_time_spent_min / (3600 * 24);;}
  dimension: course_activity_time_spent_avg {hidden: yes group_label:"Course Section Activity Metrics" type: number value_format_name: duration_minutes sql: ${TABLE}.course_activity_time_spent_avg / (3600 * 24);;}
  dimension: course_activity_time_spent_max {hidden: yes group_label:"Course Section Activity Metrics" type: number value_format_name: duration_minutes sql: ${TABLE}.course_activity_time_spent_max / (3600 * 24);;}
  dimension: course_activity_time_spent_med {hidden: no label: "Course Section Median Time Spent" group_label:"Course Section Activity Metrics" type: number value_format_name: duration_minutes sql: ${TABLE}.course_activity_time_spent_med / (3600 * 24);;}


}

# view: curated_activity {
#   derived_table: {
#     explore_source: take_node_activity {
#       column: activity_final_grade_score_avg { field: take_node.activity_final_grade_score_avg }
#       column: activity_final_grade_score_max { field: take_node.activity_final_grade_score_max }
#       column: activity_final_grade_score_min { field: take_node.activity_final_grade_score_min }
#       column: activity_final_grade_score_sd { field: take_node.activity_final_grade_score_sd }
#       column: activity_final_grade_timespent_avg { field: take_node.activity_final_grade_timespent_avg }
#       column: activity_final_grade_timespent_max { field: take_node.activity_final_grade_timespent_max }
#       column: activity_final_grade_timespent_min { field: take_node.activity_final_grade_timespent_min }
#       #column: activity_final_grade_scored { field: take_node.activity_final_grade_scored }
#       column: activity_handler { field: product_activity_metadata.handler }
#       column: activity_type { field: product_activity_metadata.activity_type }
#       column: activity_engine { field: product_activity_metadata.activity_engine }
#       column: activity_source_system { field: product_activity_metadata.source_system }
#       column: activity_core_isbn { field: product_activity_metadata.core_isbn }
#       column: activity_product { field: product_activity_metadata.product }
#       column: activity_product_code { field: product_activity_metadata.product_code }
#       column: activity_link { field: product_activity_metadata.link }
#       column: activity_name { field: product_activity_metadata.name }
#       column: product_discipline { field: product_toc_metadata.discipline }
#       column: product { field: product_toc_metadata.product }
#       column: product_name { field: product_toc_metadata.name }
#       column: product_source_system { field: product_toc_metadata.source_system }
#       column: product_abbr { field: product_toc_metadata.abbr }
#       column: product_link { field: product_toc_metadata.link }
#       column: activity_uri { field: take_node.activity_uri }
#       column: activity_type_uri { field: activity_type_map.activity_type_uri }
#       column: activity_type_system { field: activity_type_map.activity_type_system }
#       column: course_count { field: take_node.course_count }
#       column: take_count { field: take_node.take_count }
#     }
#     datagroup_trigger: realtime_default_datagroup
#   }

#   dimension: activity_key {
#     sql: ${activity_type_uri} || ':' || ${activity_uri} ;;
#     hidden: yes
#     primary_key: yes
#   }

#   dimension: activity_uri {link: {label: "View in Analytics Diagnostic Tool" url: "https://analytics-tools.cengage.info/diagnostictool/#/activity/view/production/uri/{{ value }}"}}
#   dimension: activity_type_uri {}
#   dimension: activity_handler {}
#   dimension: activity_type {}
#   dimension: activity_engine {sql:coalesce(${TABLE}.activity_engine, ${TABLE}.activity_type_system);;}
#   dimension: activity_source_system {}
#   dimension: activity_core_isbn {}
#   dimension: activity_product {}
#   dimension: activity_product_code {}
#   dimension: activity_link {}
#   dimension: activity_name {}

#   dimension: product_discipline {group_label:"TOC data"}
#   dimension: product {group_label:"TOC data"}
#   dimension: product_name {group_label:"TOC data"}
#   dimension: product_source_system {group_label:"TOC data"}
#   dimension: product_abbr {group_label:"TOC data"}
#   dimension: product_link {group_label:"TOC data"}

#   dimension: activity_final_grade_score_avg {
#     group_label: "Activity metrics"
#     label: "Score (avg)"
#     value_format_name: percent_1
#     type: number
#   }
#   dimension: activity_final_grade_score_avg_buckets {
#     group_label: "Activity metrics"
#     label: "Score (avg) buckets"
#     type: tier
#     tiers: [0.1, 0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
#     style: relational
#     sql: ${activity_final_grade_score_avg} ;;
#     value_format_name: percent_0
#   }
#   dimension: activity_final_grade_score_max {
#     group_label: "Activity metrics"
#     label: "Score (max)"
#     value_format_name: percent_1
#     type: number
#   }
#   dimension: activity_final_grade_score_min {
#     group_label: "Activity metrics"
#     label: "Score (min)"
#     value_format_name: percent_1
#     type: number
#   }
#   dimension: activity_final_grade_score_sd {
#     group_label: "Activity metrics"
#     label: "Score (sd)"
#     value_format_name: percent_1
#     type: number
#   }
#   dimension: activity_final_grade_timespent_avg {
#     group_label: "Activity metrics"
#     label: "Time spent (avg)"
#     value_format_name: duration_hms
#     type: number
#   }
# #   dimension: activity_final_grade_scored {
# #     type: yesno
# #     label: "Scored?"
# #   }
#   dimension: activity_final_grade_timespent_min {
#     group_label: "Activity metrics"
#     label: "Time spent (min)"
#     value_format_name: duration_hms
#     type: number
#   }

#   dimension: activity_final_grade_timespent_max {
#     group_label: "Activity metrics"
#     label: "Time spent (max)"
#     value_format_name: duration_hms
#     type: number
#   }

#   dimension: course_count {
#     label: "# Courses"
#     type: number
#   }
#   dimension: course_count_bucket {
#     label: "# Courses (buckets)"
#     type: tier
#     tiers: [2, 5, 10, 20, 50]
#     style: integer
#     sql: ${course_count} ;;
#   }
#   dimension: take_count {hidden:yes}
#   measure: take_count_sum {
#     label: "# Takes"
#     type: sum
#     sql: ${take_count} ;;
#   }
#   measure: take_count_avg {
#     label: "# Takes (avg)"
#     type: average
#     sql: ${take_count} ;;
#   }
#   measure: activity_count {
#     hidden: yes
#     label: "# Activities"
#     type: count_distinct
#     sql: SPLIT_PART(${activity_uri}, ':', -1) ;;
#   }
# }
