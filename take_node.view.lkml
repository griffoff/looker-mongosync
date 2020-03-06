view: take_node {
  #sql_table_name: REALTIME.TAKE_ITEM ;;
  derived_table: {
    sql:
      with data as (
        select
          hash as business_key
          ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
          ,*
          ,split_part(COURSE_URI, ':', -1)::string as course_key
          ,case
              when take_node.ACTIVITY
                then null
              when (take_node.ACTIVITY_NODE_URI) ilike 'cxp:activity:masterygroup:%'
                then null
              when (take_node.ACTIVITY_NODE_URI) ilike 'cxp:%'
                then
                  case
                    when (take_node.ACTIVITY_NODE_URI) ilike 'cxp:activity:%'
                      then
                        case array_size(split((LOWER(take_node.ACTIVITY_NODE_URI)),':'))
                          when 3
                            then split_part(replace(split_part((LOWER(take_node.ACTIVITY_NODE_URI)), ':', -1), '-', '/'), '/', 1)
                          when 4
                            then array_to_string(array_slice(split((LOWER(take_node.ACTIVITY_NODE_URI)), ':'), 1, 2), ':')
                          end
                    else split_part((LOWER(take_node.ACTIVITY_NODE_URI)), ':', 2)
                    end
              when (take_node.ACTIVITY_NODE_URI) ilike 'link:%'
                then split_part(split_part((LOWER(take_node.ACTIVITY_NODE_URI)), ':', 2), '-', 1)
              -- cnow:item:/book/ell5bms15h/itemid/75003942
              -- ils://cnow/books/esmt07t/itemid/752573077
              when (take_node.ACTIVITY_NODE_URI) ilike 'cnow:item:/book%'
                  or (take_node.ACTIVITY_NODE_URI) ilike 'ils://%'
                then split_part((LOWER(take_node.ACTIVITY_NODE_URI)), '/', -3)
              -- mindtap:item:/book/waac24h/itemid/1481067391/global:1de67454-dc0c-486d-9f49-4be509370846
              when (take_node.ACTIVITY_NODE_URI) ilike 'mindtap:item:/book%'
                  or (take_node.ACTIVITY_NODE_URI) ilike 'cnow:alsnode:/book%'
                then split_part((LOWER(take_node.ACTIVITY_NODE_URI)), '/', 3)
                --imilac:likert:question:daftsaaum09l/qLeadershipBeliefs_question_7
              when (take_node.ACTIVITY_NODE_URI) ilike 'imilac:likert:%'
                then split_part(split_part((LOWER(take_node.ACTIVITY_NODE_URI)), ':', 4), '/', 1)
              end::string AS activity_node_product_code
            ,case
              when take_node.ACTIVITY
                then null
              when (take_node.ACTIVITY_NODE_URI) ilike 'cxp:activity:masterygroup:%'
                then null
             when (take_node.ACTIVITY_NODE_URI) ilike 'cxp:%'
                then
                  case
                    when (take_node.ACTIVITY_NODE_URI) ilike 'cxp:activity:%'
                      then
                        case array_size(split((LOWER(take_node.ACTIVITY_NODE_URI)),':'))
                          when 3
                            then split_part(replace(split_part((LOWER(take_node.ACTIVITY_NODE_URI)), ':', -1), '-', '/'), '/', -1)
                          when 4
                            then null
                        end
                    else split_part((LOWER(take_node.ACTIVITY_NODE_URI)), ':', -1)
                  end
              when (take_node.ACTIVITY_NODE_URI) ilike 'cnow:item:/book%'
                  or (take_node.ACTIVITY_NODE_URI) ilike 'ils://%'
                then split_part((LOWER(take_node.ACTIVITY_NODE_URI)), '/', -1)
              when (take_node.ACTIVITY_NODE_URI) ilike 'mindtap:item:/book%'
                --or (LOWER(take_node.ACTIVITY_NODE_URI)) like 'cnow:alsnode:/book%' --section id
                then split_part((LOWER(take_node.ACTIVITY_NODE_URI)), '/', 5)
              --when (LOWER(take_node.ACTIVITY_NODE_URI)) like 'imilac:%'
              --  then split_part((LOWER(take_node.ACTIVITY_NODE_URI)), ':', -1)
              end::string AS activity_node_item_id
            ,split_part(take_node.assignable_content_uri, ':', -1)::string as assignable_content_product_section_imilac
            ,case
              when take_node.assignable_content_uri ilike 'cnow:activity:als:%'
                then split_part(take_node.assignable_content_uri, '/', -3)
              when take_node.assignable_content_uri like 'imilac:%'
                then split_part(assignable_content_product_section_imilac, '/', 1)
              end ::string as assignable_content_product_abbr
            ,case
              when take_node.assignable_content_uri ilike 'cnow:activity:als:%' or take_node.assignable_content_uri ilike 'imilac:%'
                then split_part(take_node.assignable_content_uri, '/', -1)
              end ::string as assignable_content_uri_section_id
            ,coalesce(activity_node_product_code, assignable_content_product_abbr) as product_code
            ,activity_node_item_id as item_id
            ,assignable_content_uri_section_id as section_id
        from realtime.take_item as take_node
      )
      select *
      from data
      where latest = 1
      order by course_uri, activity_uri, user_identifier, activity_node_uri
    ;;

      datagroup_trigger: realtime_default_datagroup
  }

  set: course_details {fields:[course_uri]}
  set: details {fields:[_rsrc, _ldts_time, course_details*, user_identifier, activity_uri, activity_node_uri, submission_time, activity_grade, interaction_grade, final_grade]}

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
    group_label: "Record type"
    description: "Activity or Item level data?"
    type: yesno
    sql: ${TABLE}.ACTIVITY ;;
  }

  dimension: item {
    group_label: "Record type"
    description: "Activity or Item level data?"
    type: yesno
    sql: not ${activity} ;;
  }

  dimension: activity_grade {
    type: string
    sql: ${TABLE}.ACTIVITY_GRADE ;;
  }

  dimension: activity_node_uri {
    group_label: "Activity Node Uri"
    type: string
    sql: LOWER(${TABLE}.ACTIVITY_NODE_URI) ;;
    link: {
      label: "Scores Across Discipline"
#       url: "/explore/realtime/take_node?fields=take_node.count,take_node.final_grade_score_avg, dim_product,discipline&f[take_node.activity_node_uri]={{ value }}"#
      url: "/looks/1882?f[take_node.activity_node_uri]={{ value }}"
    }
  }

  dimension: activity_node_system {
    group_label: "Activity Node Uri"
    label: "Activity Platform"
    type: string
    sql:  case
            when array_size(split(${activity_node_uri}, ':')) = 1
              then 'UNKNOWN'
            else split_part(${activity_node_uri}, ':', 1)::string
          end;;
    hidden: no
  }

  #--cxp:activity:masterygroup, 4 parts, -1=cgi
  #--cxp:activity, 3 parts, 2=book, -1=itemid
  #--cxp: 4 parts, 2+3, 4 assetid

  dimension: activity_node_product_code {
    group_label: "Activity Node Uri"
    type: string
#     sql:  case
#               when ${activity}
#                 then null
#               when ${activity_node_uri} like 'cxp:activity:masterygroup:%'
#                 then null
#               when ${activity_node_uri} like 'cxp:%'
#                 then
#                   case
#                     when ${activity_node_uri} like 'cxp:activity:%'
#                       then
#                         case array_size(split(${activity_node_uri},':'))
#                           when 3
#                             then split_part(replace(split_part(${activity_node_uri}, ':', -1), '-', '/'), '/', 1)
#                           when 4
#                             then array_to_string(array_slice(split(${activity_node_uri}, ':'), 1, 2), ':')
#                           end
#                     else split_part(${activity_node_uri}, ':', 2)
#                     end
#               when ${activity_node_uri} like 'link:%'
#                 then split_part(split_part(${activity_node_uri}, ':', 2), '-', 1)
#               -- cnow:item:/book/ell5bms15h/itemid/75003942
#               -- ils://cnow/books/esmt07t/itemid/752573077
#               when ${activity_node_uri} like 'cnow:item:/book%'
#                   or ${activity_node_uri} like 'ils://%'
#                 then split_part(${activity_node_uri}, '/', -3)
#               -- mindtap:item:/book/waac24h/itemid/1481067391/global:1de67454-dc0c-486d-9f49-4be509370846
#               when ${activity_node_uri} like 'mindtap:item:/book%'
#                   or ${activity_node_uri} like 'cnow:alsnode:/book%'
#                 then split_part(${activity_node_uri}, '/', 3)
#                 --imilac:likert:question:daftsaaum09l/qLeadershipBeliefs_question_7
#               when ${activity_node_uri} like 'imilac:likert:%'
#                 then split_part(split_part(${activity_node_uri}, ':', 4), '/', 1)
#               end::string;;
  }

  dimension: activity_node_item_id {
    group_label: "Activity Node Uri"
    type: string
#     sql:  case
#               when ${activity}
#                 then null
#               when ${activity_node_uri} like 'cxp:activity:masterygroup:%'
#                 then null
#              when ${activity_node_uri} like 'cxp:%'
#                 then
#                   case
#                     when ${activity_node_uri} like 'cxp:activity:%'
#                       then
#                         case array_size(split(${activity_node_uri},':'))
#                           when 3
#                             then split_part(replace(split_part(${activity_node_uri}, ':', -1), '-', '/'), '/', -1)
#                           when 4
#                             then null
#                         end
#                     else split_part(${activity_node_uri}, ':', -1)
#                   end
#               when ${activity_node_uri} like 'cnow:item:/book%'
#                   or ${activity_node_uri} like 'ils://%'
#                 then split_part(${activity_node_uri}, '/', -1)
#               when ${activity_node_uri} like 'mindtap:item:/book%'
#                 --or ${activity_node_uri} like 'cnow:alsnode:/book%' --section id
#                 then split_part(${activity_node_uri}, '/', 5)
#               --when ${activity_node_uri} like 'imilac:%'
#               --  then split_part(${activity_node_uri}, ':', -1)
#               end::string;;
  }

  dimension: activity_node_product_type {
    group_label: "Activity Node Uri"
    type: string
    sql: case right(${activity_node_product_code}, 1)
          when 'q' then 'Quiz'
          when 'a' then 'Assessment'
          when 'h' then 'Homework'
          else right(${activity_node_product_code}, 1)
          end;;

  }

  dimension: activity_node_cgid {
    group_label: "Activity Node Uri"
    type: string
    sql: case
          when ${TABLE}.activity_node_uri ilike 'cas:view:%'
              or ${TABLE}.activity_node_uri ilike 'soa:prod:activity:%'
              or ${TABLE}.activity_node_uri ilike 'cgi:%'
            then split_part(${activity_node_uri}, ':', -1)
         end::string;;
  }

  dimension: activity_node_uri_masterygroup_cgid {
    group_label: "Activity Node Uri"
    type: string
    sql:  case when ${TABLE}.activity_node_uri ilike 'cxp:activity:masterygroup:%'
            then split_part(${activity_node_uri}, ':', -1)
            end::string;;
  }

  measure: activity_node_uri_example {
    group_label: "Activity Node Uri"
    type: string
    sql: any_value(${activity_node_uri}) ;;
  }

  dimension: activity_type_uri {
    type: string
    sql: LOWER(${TABLE}.ACTIVITY_TYPE_URI) ;;
  }

  dimension: activity_uri {
    type: string
    sql: LOWER(${TABLE}.ACTIVITY_URI) ;;
  }

  dimension: cnowmindapp  {
    group_label: "Record type"
    type: yesno
    sql:  ${TABLE}.ACTIVITY_URI ILIKE 'cnow:assignment:/inst/mindapps/%'::string ;;
  }

  dimension: assignable_content_uri {
    group_label: "Assignable Content Uri"
    type: string
    sql: ${TABLE}.ASSIGNABLE_CONTENT_URI ;;
  }

  measure: assignable_content_uri_example {
    group_label: "Assignable Content Uri"
    type: string
    sql: any_value(${assignable_content_uri}) ;;
  }

  dimension: assignable_content_product_section_imilac {
    group_label: "Assignable Content Uri"
    type: string
    sql: split_part(${assignable_content_uri}, ':', -1)::string;;
    hidden: yes
  }

  dimension: assignable_content_product_abbr {
    group_label: "Assignable Content Uri"
    type: string
    #cnow:activity:als:/cengage:book:abbr/waac25l/section/162493553
#     sql: case
#             when ${assignable_content_uri} like 'cnow:activity:als:%'
#             then split_part(${assignable_content_uri}, '/', -3)
#             when ${assignable_content_uri} like 'imilac:%'
#             then split_part(${assignable_content_product_section_imilac}, '/', 1)
#             end ::string ;;

  }

  dimension: assignable_content_product_section_id {
    group_label: "Assignable Content Uri"
    type: string
    sql:  ${TABLE}.assignable_content_uri_section_id ;;
#     sql:   case
#           when ${assignable_content_uri} like 'cnow:activity:als:%' or ${assignable_content_uri} like 'imilac:%'
#           then split_part(${assignable_content_uri}, '/', -1)
#           end ::string ;;

    }

  dimension: product_code {
    group_label: "geyser identifiers"
#     sql: coalesce(${activity_node_product_code}, ${assignable_content_product_abbr}) ;;
    link: {
      label: "Geyser: PreProd"
      url: "https://preprod.geyser.cl-cms.com/nav-toc.xqy/{{ value }}"
    }
    link: {
      label: "Geyser: Prod"
      url: "https://geyser.cl-cms.com/nav-toc.xqy/{{ value }}"
    }
  }

  dimension: item_id {
    group_label: "geyser identifiers"
#     sql: ${activity_node_item_id} ;;
  }

  dimension: section_id {
    group_label: "geyser identifiers"
#     sql: ${assignable_content_product_section_id} ;;
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
    group_label: "External Take Uri"
    type: string
    sql: ${TABLE}.EXTERNAL_TAKE_URI ;;
  }

  dimension: activity_system {
    label: "Activity Engine"
    type: string
    sql:  split_part(${external_take_uri}, ':', 1)::string ;;
  }

  dimension: activity_final_grade {
    group_label: "Final Grade - Activity"
    hidden: yes
    label: "Raw JSON"
    type: string
    sql: case when ${activity} then ${TABLE}.FINAL_GRADE end ;;
  }

  dimension: activity_final_grade_taken {
    group_label: "Final Grade - Activity"
    label: "Taken?"
    type: yesno
    sql: ${activity_final_grade}:taken::boolean ;;
  }

  dimension: activity_final_grade_scored {
    group_label: "Final Grade - Activity"
    label: "Scored?"
    type: yesno
    sql: ${activity_final_grade}:scored::boolean ;;
  }

  dimension: activity_final_grade_timespent {
    group_label: "Final Grade - Activity"
    label: "Time spent"
    type: number
    sql: ${activity_final_grade}:timeSpent::float / 60 / 60 / 24;;
    value_format_name: duration_hms
  }

  dimension: activity_final_grade_score {
    group_label: "Final Grade - Activity"
    label: "Score"
    type: number
    sql: ${activity_final_grade}:normalScore::float ;;
    value_format_name: percent_1
  }


  measure: activity_final_grade_score_avg {
    group_label: "Final Grade - Activity"
    label: "Score (avg)"
    type: average
    sql: ${activity_final_grade_score} ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: activity_final_grade_score_min {
    group_label: "Final Grade - Activity"
    label: "Score (min)"
    type: min
    sql: ${activity_final_grade_score} ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: activity_final_grade_score_max {
    group_label: "Final Grade - Activity"
    label: "Score (max)"
    type: max
    sql: ${activity_final_grade_score} ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: activity_final_grade_score_sd {
    group_label: "Final Grade - Activity"
    label: "Score (sd)"
    type: number
    sql: stddev( ${activity_final_grade_score}) ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: activity_final_grade_timespent_avg {
    group_label: "Final Grade - Activity"
    label: "Time spent (avg)"
    type: average
    sql: ${activity_final_grade_timespent};;
    value_format_name: duration_hms
    drill_fields: [details*]
  }

  measure: activity_final_grade_timespent_sum {
    group_label: "Final Grade - Activity"
    label: "Time spent (total)"
    type: sum
    sql: ${activity_final_grade_timespent};;
    value_format_name: duration_hms
    drill_fields: [details*]
  }

  measure: activity_final_grade_timespent_max {
    group_label: "Final Grade - Activity"
    label: "Time spent (max)"
    type: max
    sql: ${activity_final_grade_timespent};;
    value_format_name: duration_hms
    drill_fields: [details*]
  }

  measure: activity_final_grade_timespent_min {
    group_label: "Final Grade - Activity"
    label: "Time spent (min)"
    type: min
    sql: ${activity_final_grade_timespent};;
    value_format_name: duration_hms
    drill_fields: [details*]
  }

  dimension: item_final_score {
    group_label: "Final Grade - Item Score"
    hidden: yes
    label: "Raw JSON"
    type: string
    sql: case when not ${activity} then ${TABLE}.FINAL_GRADE end ;;
  }

  dimension: item_final_score_score {
    group_label: "Final Grade - Item Score"
    label: "Score"
    type: number
    sql: try_cast(nullif(${item_final_score}:normalScore::string, '') as decimal(10, 6)) ;;
  }

  dimension: item_final_score_timespent {
    group_label: "Final Grade - Item Score"
    label: "Time spent"
    type: number
    sql: try_cast(nullif(${final_grade}:timeSpent::string, '') as decimal(18, 6)) / 60 / 60 / 24;;
    value_format_name: duration_hms
  }

  dimension: item_possible_score {
    hidden: yes
    sql: case when not ${activity} then ${possible_score} end;;
  }

  measure: item_final_score_correct_percent {
    group_label: "Final Grade - Item Score"
    label: "Correct (%)"
    type: number
    sql: count(case when ${item_possible_score} <= 1 and ${item_final_score_score} = ${item_possible_score} then 1 end) / nullif(count(case when ${item_possible_score} <= 1 then 1 end), 0) ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: item_final_score_percent {
    group_label: "Final Grade - Item Score"
    label: "Item Score (%)"
    description: "Score on an item by an user, use this against an item dimension"
    type: average
    sql: ${item_final_score_score} ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: item_max_score_percent {
    group_label: "Final Grade - Item Score"
    label: "Highest Item Score (%)"
    description: "Score on an item by an user, use this against an item dimension"
    type: max
    sql: ${item_final_score_score} ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: item_final_score_timespent_avg {
    group_label: "Final Grade - Item Score"
    label: "Time spent (avg)"
    type: average
    sql: ${item_final_score_timespent};;
    value_format_name: duration_hms
    drill_fields: [details*]
  }

  dimension: final_grade {
    group_label: "Final Grade - All"
    label: "Raw JSON"
    type: string
    sql: ${TABLE}.FINAL_GRADE ;;
  }

  dimension: final_grade_taken {
    group_label: "Final Grade - All"
    label: "Taken?"
    type: yesno
    sql: ${final_grade}:taken::boolean ;;
  }

  dimension: final_grade_scored {
    group_label: "Final Grade - All"
    label: "Scored?"
    type: yesno
    sql: ${final_grade}:scored::boolean ;;
  }

  dimension: final_grade_timespent {
    group_label: "Final Grade - All"
    label: "Time spent"
    type: number
    sql: try_cast(nullif(${final_grade}:timeSpent::string, '') AS decimal(18, 6)) / 60 / 60 / 24;;
    value_format_name: duration_hms
  }

  dimension: final_grade_score {
    group_label: "Final Grade - All"
    label: "Score"
    type: number
    sql: ${final_grade}:normalScore::float ;;
    value_format_name: percent_1
  }

  dimension: final_grade_is_correct {
    group_label: "Final Grade - All"
    label: "Correct?"
    type: yesno
    sql: case when ${possible_score} <= 1 then ${final_grade_score} = ${possible_score} end ;;
  }

  measure: final_grade_correct_percent {
    group_label: "Final Grade - All"
    label: "Correct (%)"
    type: number
    sql: count(case when ${possible_score} <= 1 and ${final_grade_score} = ${possible_score} then 1 end) / nullif(count(case when ${possible_score} <= 1 then 1 end), 0) ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: final_grade_score_avg {
    group_label: "Final Grade - All"
    label: "Score (avg)"
    type: average
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: final_grade_score_min {
    group_label: "Final Grade - All"
    label: "Score (min)"
    type: min
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: final_grade_score_max {
    group_label: "Final Grade - All"
    label: "Score (max)"
    type: max
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: final_grade_score_sd {
    group_label: "Final Grade - All"
    label: "Score (sd)"
    type: number
    sql: stddev( ${final_grade_score}) ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: final_grade_ns_sum {
    group_label: "Final Grade - All"
    label: "N Score (sum)"
    type: sum
    sql: try_cast(coalesce(${final_grade}:normalScore:"$numberDouble", ${final_grade}:normalScore)::string as decimal(10, 6)) ;;
    value_format_name: percent_1
    drill_fields: [details*]
  }

  measure: final_grade_ps_sum {
    group_label: "Final Grade - All"
    label: "P Score (sum)"
    type: sum
    sql: try_cast(coalesce(${final_grade}:possibleScore:"$numberDouble", ${final_grade}:possibleScore)::string as decimal(10, 6)) ;;
    drill_fields: [details*]
  }

  measure: final_grade_ss_sum {
    group_label: "Final Grade - All"
    label: "S Score (sum)"
    type: sum
    sql: try_cast(coalesce(${final_grade}:scaledScore:"$numberDouble", ${final_grade}:scaledScore)::string as decimal(10, 6)) ;;
    drill_fields: [details*]
  }

  measure: final_grade_timespent_avg {
    group_label: "Final Grade - All"
    label: "Time spent (avg)"
    type: average
    sql: ${final_grade_timespent};;
    value_format_name: duration_hms
    drill_fields: [details*]
  }

  measure: final_grade_timespent_sum {
    group_label: "Final Grade - All"
    label: "Time spent (total)"
    type: sum
    sql: ${final_grade_timespent};;
    value_format_name: duration_hms
    drill_fields: [details*]
  }

  dimension: final_grade_score_tiers {
    group_label: "Final Grade - All"
    label: "Score (Buckets)"
    type: tier
    tiers: [0.1, 0.25, 0.4, 0.6, 0.75, 0.9, 0.95]
    style: relational
    sql: ${final_grade_score} ;;
    value_format_name: percent_1
    drill_fields: [details*]
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
    group_label: "Record type"
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

  measure: latest_submission_date {
    type: max
    sql: ${submission_raw} ;;
    drill_fields: [details*]
  }

  dimension: user_identifier {
    type: string
    sql: ${TABLE}.USER_IDENTIFIER ;;
  }

  measure: sum_possible_score {
    label: "Sum possible Score"
    type: sum
    sql: ${TABLE}.POSSIBLE_SCORE ;;
  }

  measure: times_taken {
    label: "# Times taken"
    type: number
    sql: count(case when ${final_grade_taken} then 1 end);;
    drill_fields: [details*]
  }

  measure: users_taken {
    label: "# Users taken"
    type: count_distinct
    sql: ${user_identifier};;
    drill_fields: [details*]
  }

  measure: count {
    type: count
    drill_fields: [details*]
  }

  measure: take_count {
    label: "# Takes"
    type: count_distinct
    sql: ${external_take_uri} ;;
    drill_fields: [details*]
  }

  measure: course_count {
    label: "# Courses"
    type: count_distinct
    sql: ${course_uri} ;;
    drill_fields: [course_details*]
  }

  measure: courses_with_takes {
    group_label: "Instructor usage"
    label: "# times assigned"
    type: count_distinct
    sql: case when ${final_grade_taken} then ${course_uri} end ;;
    drill_fields: [course_details*]
  }

  measure: courses_with_takes_percent {
    group_label: "Instructor usage"
    label: "% times assigned"
    type: number
    sql: ${courses_with_takes}/nullif(${course_count}, 0) ;;
    value_format_name: percent_1
    drill_fields: [course_details*]
  }

  dimension: interaction_attempts {
    label: "Interaction Attempts"
    type: number
    sql: try_cast(coalesce(${TABLE}.INTERACTION_GRADE:attempts:"$numberLong", ${TABLE}.INTERACTION_GRADE:attempts)::string as decimal(10, 6)) ;;
  }

  dimension: interaction_attempts_tier {
    type: tier
    style: integer
    tiers: [0, 1, 2, 3, 5, 10]
    sql: ${interaction_attempts} ;;
  }

  measure: interaction_attempts_sum{
    label: "Interaction Attempts"
    type: sum
    sql: ${interaction_attempts} ;;
    drill_fields: [details*]
  }

  dimension: interaction_normal_score{
    label: "Interaction Normal Score"
    type: number
    sql: try_cast(coalesce(${TABLE}.INTERACTION_GRADE:normalScore:"$numberDouble", ${TABLE}.INTERACTION_GRADE:normalScore)::string as decimal(10, 6)) ;;
  }

  measure: interaction_normal_score_sum{
    label: "Interaction Normal Score"
    type: sum
    sql: ${interaction_normal_score} ;;
    drill_fields: [details*]
  }

  dimension: parent_path_0 {
    group_label: "Node Selectors"
    label: "Parent Path 0"
    type:  string
    sql: ${TABLE}.PARENT_PATH[0]::string ;;
  }

  dimension: parent_path_1 {
    group_label: "Node Selectors"
    label: "Parent Path 1"
    type:  string
    sql: ${TABLE}.PARENT_PATH[1]::string ;;
  }

  dimension: parent_path_2 {
    group_label: "Node Selectors"
    label: "Parent Path 2"
    type:  string
    sql: ${TABLE}.PARENT_PATH[2]::string ;;
  }

  dimension: parent_path_3 {
    group_label: "Node Selectors"
    label: "Parent Path 3"
    type:  string
    sql: ${TABLE}.PARENT_PATH[3]::string ;;
  }

  dimension: parent_path_4 {
    group_label: "Node Selectors"
    label: "Parent Path 4"
    type:  string
    sql: ${TABLE}.PARENT_PATH[4]::string ;;
  }

  dimension: external_properties_activity_type {
    group_label: "Node Selectors"
    label: "External Property - activity-type"
    type:  string
    sql: ${TABLE}.EXTERNAL_PROPERTIES:"analytics:activity-type" ;;
  }

  dimension: external_properties_node_type {
    group_label: "Node Selectors"
    label: "External Property - node-type"
    type:  string
    sql: ${TABLE}.EXTERNAL_PROPERTIES:"analytics:node-type" ;;
  }

  dimension: external_properties_container_type {
    group_label: "Node Selectors"
    label: "External Property - container-type"
    type:  string
    sql: ${TABLE}.EXTERNAL_PROPERTIES:"analytics:container-type" ;;
  }

  dimension: external_properties_raw {
    group_label: "Node Selectors"
    label: "External Property Raw"
    type:  string
    sql: ${TABLE}.EXTERNAL_PROPERTIES ;;
  }

  dimension: book_item_name {
    sql: ${TABLE}.EXTERNAL_PROPERTIES:"cengage:book:item:name"::string ;;
  }

}
