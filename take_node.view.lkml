view: take_node {
  #sql_table_name: REALTIME.TAKE_ITEM ;;
  derived_table: {
    create_process: {
      sql_step:
        USE SCHEMA looker_scratch
        ;;

      sql_step:
        CREATE TRANSIENT TABLE IF NOT EXISTS take_item
          CLUSTER BY (submission_date::DATE)
        (
          business_key                              STRING,
          _ldts                                     TIMESTAMP_LTZ(9),
          _rsrc                                     STRING,
          activity_uri                              STRING,
          activity_node_uri                         STRING,
          external_take_uri                         STRING,
          course_uri                                STRING,
          user_identifier                           STRING,
          submission_date                           TIMESTAMP_LTZ(9),
          possible_score                            FLOAT,
          interaction_grade                         VARIANT,
          activity_grade                            VARIANT,
          final_grade                               VARIANT,
          activity                                  BOOLEAN,
          mastery_item                              BOOLEAN,
          activity_type_uri                         STRING,
          assignable_content_uri                    STRING,
          hash                                      STRING,
          last_update_date                          TIMESTAMP_LTZ(9),
          parent_path                               VARIANT,
          position_path                             VARIANT,
          external_properties                       VARIANT,
          course_key                                STRING,
          activity_node_product_code                STRING,
          activity_node_item_id                     STRING,
          assignable_content_product_section_imilac STRING,
          assignable_content_product_abbr           STRING,
          assignable_content_uri_section_id         STRING,
          product_code                              STRING,
          item_id                                   STRING,
          section_id                                STRING,
          final_grade_scored                        BOOLEAN,
          final_grade_taken                         BOOLEAN,
          final_grade_score                         FLOAT,
          final_grade_possiblescore                 FLOAT,
          final_grade_scaledscore                   FLOAT,
          attempts                                  INT,
          final_grade_timespent                     DECIMAL(18, 6)
        )
        ;;

      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE take_item_incremental
        AS
        WITH latest AS (
                         SELECT hash AS h, MAX(_ldts) AS d
                         FROM prod.realtime.take_item
                         WHERE _ldts > (
                                         SELECT COALESCE(max(_ldts), '1970-01-01')
                                         FROM take_item
                                       )
                           AND submission_date >= dateadd(YEAR, -3, current_date())
                         GROUP BY 1
                       )
           , data AS (
                       SELECT hash AS business_key
                            , *
                            , split_part(course_uri, ':', -1)::STRING AS course_key
                            , CASE
                                WHEN take_node.activity
                                  THEN NULL
                                WHEN (take_node.activity_node_uri) ILIKE 'cxp:activity:masterygroup:%'
                                  THEN NULL
                                WHEN (take_node.activity_node_uri) ILIKE 'cxp:%'
                                  THEN
                                  CASE
                                    WHEN (take_node.activity_node_uri) ILIKE 'cxp:activity:%'
                                      THEN
                                      CASE array_size(split((LOWER(take_node.activity_node_uri)), ':'))
                                        WHEN 3
                                          THEN split_part(
                                                replace(split_part((LOWER(take_node.activity_node_uri)), ':', -1), '-', '/'),
                                                '/', 1)
                                        WHEN 4
                                          THEN array_to_string(
                                                array_slice(split((LOWER(take_node.activity_node_uri)), ':'), 1, 2), ':')
                                      END
                                    ELSE split_part((LOWER(take_node.activity_node_uri)), ':', 2)
                                  END
                                WHEN (take_node.activity_node_uri) ILIKE 'link:%'
                                  THEN split_part(split_part((LOWER(take_node.activity_node_uri)), ':', 2), '-', 1)
                         -- cnow:item:/book/ell5bms15h/itemid/75003942
                         -- ils://cnow/books/esmt07t/itemid/752573077
                                WHEN (take_node.activity_node_uri) ILIKE 'cnow:item:/book%'
                                  OR (take_node.activity_node_uri) ILIKE 'ils://%'
                                  THEN split_part((LOWER(take_node.activity_node_uri)), '/', -3)
                         -- mindtap:item:/book/waac24h/itemid/1481067391/global:1de67454-dc0c-486d-9f49-4be509370846
                                WHEN (take_node.activity_node_uri) ILIKE 'mindtap:item:/book%'
                                  OR (take_node.activity_node_uri) ILIKE 'cnow:alsnode:/book%'
                                  THEN split_part((LOWER(take_node.activity_node_uri)), '/', 3)
                         --imilac:likert:question:daftsaaum09l/qLeadershipBeliefs_question_7
                                WHEN (take_node.activity_node_uri) ILIKE 'imilac:likert:%'
                                  THEN split_part(split_part((LOWER(take_node.activity_node_uri)), ':', 4), '/', 1)
                              END::STRING AS activity_node_product_code
                            , CASE
                                WHEN take_node.activity
                                  THEN NULL
                                WHEN (take_node.activity_node_uri) ILIKE 'cxp:activity:masterygroup:%'
                                  THEN NULL
                                WHEN (take_node.activity_node_uri) ILIKE 'cxp:%'
                                  THEN
                                  CASE
                                    WHEN (take_node.activity_node_uri) ILIKE 'cxp:activity:%'
                                      THEN
                                      CASE array_size(split((LOWER(take_node.activity_node_uri)), ':'))
                                        WHEN 3
                                          THEN split_part(
                                                replace(split_part((LOWER(take_node.activity_node_uri)), ':', -1), '-', '/'),
                                                '/', -1)
                                        WHEN 4
                                          THEN NULL
                                      END
                                    ELSE split_part((LOWER(take_node.activity_node_uri)), ':', -1)
                                  END
                                WHEN (take_node.activity_node_uri) ILIKE 'cnow:item:/book%'
                                  OR (take_node.activity_node_uri) ILIKE 'ils://%'
                                  THEN split_part((LOWER(take_node.activity_node_uri)), '/', -1)
                                WHEN (take_node.activity_node_uri) ILIKE 'mindtap:item:/book%'
                                  --or (LOWER(take_node.ACTIVITY_NODE_URI)) like 'cnow:alsnode:/book%' --section id
                                  THEN split_part((LOWER(take_node.activity_node_uri)), '/', 5)
                         --when (LOWER(take_node.ACTIVITY_NODE_URI)) like 'imilac:%'
                         --  then split_part((LOWER(take_node.ACTIVITY_NODE_URI)), ':', -1)
                              END::STRING AS activity_node_item_id
                            , split_part(take_node.assignable_content_uri, ':', -1)::STRING AS assignable_content_product_section_imilac
                            , CASE
                                WHEN take_node.assignable_content_uri ILIKE 'cnow:activity:als:%'
                                  THEN split_part(take_node.assignable_content_uri, '/', -3)
                                WHEN take_node.assignable_content_uri LIKE 'imilac:%'
                                  THEN split_part(assignable_content_product_section_imilac, '/', 1)
                              END ::STRING AS assignable_content_product_abbr
                            , CASE
                                WHEN take_node.assignable_content_uri ILIKE 'cnow:activity:als:%' OR
                                     take_node.assignable_content_uri ILIKE 'imilac:%'
                                  THEN split_part(take_node.assignable_content_uri, '/', -1)
                              END ::STRING AS assignable_content_uri_section_id
                            , coalesce(activity_node_product_code, assignable_content_product_abbr) AS product_code
                            , activity_node_item_id AS item_id
                            , assignable_content_uri_section_id AS section_id
                       FROM prod.realtime.take_item AS take_node
                     )
        SELECT
            data.*
            ,activity_type_map.activity_type_uri AS activity_type_uri_map
            ,data.final_grade:scored::BOOLEAN  AS final_grade_scored
            ,data.final_grade:taken::BOOLEAN  AS final_grade_taken
            ,data.final_grade:normalScore::FLOAT  AS final_grade_score
            ,data.final_grade:possibleScore::FLOAT  AS final_grade_possiblescore
            ,data.final_grade:scaledScore::FLOAT  AS final_grade_scaledscore
            ,data.interaction_grade:attempts::INT  AS attempts
            --cap time spent at 2 hrs
            ,iff(data.final_grade:timeSpent > 7200, NULL, NULLIF(data.final_grade:timeSpent::STRING, ''))::DECIMAL(18, 6) / 60 / 60 / 24 AS final_grade_timespent
        FROM latest
             INNER JOIN data ON (latest.h, latest.d) = (data.hash, data._ldts)
             LEFT JOIN ${activity_type_map.SQL_TABLE_NAME} AS activity_type_map
                  ON (LOWER(data.ACTIVITY_TYPE_URI)) = activity_type_map.activity_type_uri_source
        ORDER BY hash
        ;;

    sql_step:
      MERGE INTO take_item t
        USING take_item_incremental i ON t.hash = i.hash
        WHEN MATCHED THEN UPDATE
          SET
            t.business_key = i.business_key
            ,t._ldts = i._ldts,t._rsrc = i._rsrc
            ,t.activity_uri = i.activity_uri, t.activity_node_uri = i.activity_node_uri, t.external_take_uri = i.external_take_uri, t.course_uri = i.course_uri, t.user_identifier = i.user_identifier, t.submission_date = i.submission_date, t.possible_score = i.possible_score
            ,t.interaction_grade = i.interaction_grade, t.activity_grade = i.activity_grade, t.final_grade = i.final_grade
            ,t.activity = i.activity, t.mastery_item = i.mastery_item
            ,t.activity_type_uri = COALESCE(i.activity_type_uri_map, i.activity_type_uri), t.assignable_content_uri = i.assignable_content_uri
            ,t.hash = i.hash, t.last_update_date = i.last_update_date
            ,t.parent_path = i.parent_path, t.position_path = i.position_path
            ,t.external_properties = i.external_properties
            ,t.course_key = i.course_key, t.activity_node_product_code = i.activity_node_product_code, t.activity_node_item_id = i.activity_node_item_id
            ,t.assignable_content_product_section_imilac = i.assignable_content_product_section_imilac, t.assignable_content_product_abbr = i.assignable_content_product_abbr
            ,t.assignable_content_uri_section_id = i.assignable_content_uri_section_id
            ,t.product_code = i.product_code, t.item_id = i.item_id, t.section_id = i.section_id
            ,t.final_grade_scored = i.final_grade_scored
            ,t.final_grade_taken = i.final_grade_taken
            ,t.final_grade_score = i.final_grade_score
            ,t.final_grade_possiblescore = i.final_grade_possiblescore
            ,t.final_grade_scaledscore = i.final_grade_scaledscore
            ,t.attempts = i.attempts
            ,t.final_grade_timespent = i.final_grade_timespent
        WHEN NOT MATCHED THEN INSERT (
                                      business_key, _ldts, _rsrc, activity_uri, activity_node_uri, external_take_uri,
                                      course_uri, user_identifier, submission_date, possible_score, interaction_grade,
                                      activity_grade, final_grade, activity, mastery_item, activity_type_uri,
                                      assignable_content_uri, hash, last_update_date, parent_path, position_path,
                                      external_properties, course_key, activity_node_product_code, activity_node_item_id,
                                      assignable_content_product_section_imilac, assignable_content_product_abbr,
                                      assignable_content_uri_section_id, product_code, item_id, section_id,
                                      final_grade_scored, final_grade_taken, final_grade_score, final_grade_possiblescore, final_grade_scaledscore,
                                      attempts, final_grade_timespent
                                      )
          VALUES (
                   i.business_key
                 , i._ldts, i._rsrc
                 , i.activity_uri, i.activity_node_uri, i.external_take_uri, i.course_uri, i.user_identifier
                 , i.submission_date, i.possible_score
                 , i.interaction_grade, i.activity_grade, i.final_grade
                 , i.activity, i.mastery_item
                 , COALESCE(i.activity_type_uri_map, i.activity_type_uri), i.assignable_content_uri
                 , i.hash, i.last_update_date
                 , i.parent_path, i.position_path
                 , i.external_properties
                 , i.course_key, i.activity_node_product_code, i.activity_node_item_id
                 , i.assignable_content_product_section_imilac, i.assignable_content_product_abbr
                 , i.assignable_content_uri_section_id
                 , i.product_code, i.item_id, i.section_id
                 , i.final_grade_scored, i.final_grade_taken, i.final_grade_score, i.final_grade_possiblescore, i.final_grade_scaledscore
                 , i.attempts, i.final_grade_timespent
                )
      ;;

      sql_step:
        ALTER TABLE take_item RECLUSTER;;

      sql_step:
        CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME} CLONE take_item;;

      sql_step:
        CREATE TRANSIENT TABLE IF NOT EXISTS item_take_items LIKE take_item;;

      sql_step:
        DELETE FROM item_take_items WHERE hash IN (SELECT hash FROM take_item_incremental WHERE NOT activity AND NOT mastery_item);;

      sql_step:
        INSERT INTO item_take_items (
                                      business_key, _ldts, _rsrc, activity_uri, activity_node_uri, external_take_uri,
                                      course_uri, user_identifier, submission_date, possible_score, interaction_grade,
                                      activity_grade, final_grade, activity, mastery_item, activity_type_uri,
                                      assignable_content_uri, hash, last_update_date, parent_path, position_path,
                                      external_properties, course_key, activity_node_product_code, activity_node_item_id,
                                      assignable_content_product_section_imilac, assignable_content_product_abbr,
                                      assignable_content_uri_section_id, product_code, item_id, section_id,
                                      final_grade_scored, final_grade_taken, final_grade_score, final_grade_possiblescore, final_grade_scaledscore,
                                      attempts, final_grade_timespent
                                      )
        SELECT i.business_key
                 , i._ldts, i._rsrc
                 , i.activity_uri, i.activity_node_uri, i.external_take_uri, i.course_uri, i.user_identifier
                 , i.submission_date, i.possible_score
                 , i.interaction_grade, i.activity_grade, i.final_grade
                 , i.activity, i.mastery_item
                 , COALESCE(i.activity_type_uri_map, i.activity_type_uri), i.assignable_content_uri
                 , i.hash, i.last_update_date
                 , i.parent_path, i.position_path
                 , i.external_properties
                 , i.course_key, i.activity_node_product_code, i.activity_node_item_id
                 , i.assignable_content_product_section_imilac, i.assignable_content_product_abbr
                 , i.assignable_content_uri_section_id
                 , i.product_code, i.item_id, i.section_id
                 , i.final_grade_scored, i.final_grade_taken, i.final_grade_score, i.final_grade_possiblescore, i.final_grade_scaledscore
                 , i.attempts, i.final_grade_timespent
        FROM take_item_incremental i
        WHERE NOT i.activity AND NOT i.mastery_item
        ORDER BY i.submission_date
        ;;

      sql_step:
        ALTER TABLE item_take_items RECLUSTER;;

      sql_step:
        CREATE TRANSIENT TABLE IF NOT EXISTS item_take_activities LIKE take_item;;

      sql_step:
        DELETE FROM item_take_activities WHERE hash IN (SELECT hash FROM take_item_incremental WHERE activity);;

      sql_step:
        INSERT INTO item_take_activities (
                                      business_key, _ldts, _rsrc, activity_uri, activity_node_uri, external_take_uri,
                                      course_uri, user_identifier, submission_date, possible_score, interaction_grade,
                                      activity_grade, final_grade, activity, mastery_item, activity_type_uri,
                                      assignable_content_uri, hash, last_update_date, parent_path, position_path,
                                      external_properties, course_key, activity_node_product_code, activity_node_item_id,
                                      assignable_content_product_section_imilac, assignable_content_product_abbr,
                                      assignable_content_uri_section_id, product_code, item_id, section_id,
                                      final_grade_scored, final_grade_taken, final_grade_score, final_grade_possiblescore, final_grade_scaledscore,
                                      attempts, final_grade_timespent
                                      )
        SELECT i.business_key
                 , i._ldts, i._rsrc
                 , i.activity_uri, i.activity_node_uri, i.external_take_uri, i.course_uri, i.user_identifier
                 , i.submission_date, i.possible_score
                 , i.interaction_grade, i.activity_grade, i.final_grade
                 , i.activity, i.mastery_item
                 , COALESCE(i.activity_type_uri_map, i.activity_type_uri), i.assignable_content_uri
                 , i.hash, i.last_update_date
                 , i.parent_path, i.position_path
                 , i.external_properties
                 , i.course_key, i.activity_node_product_code, i.activity_node_item_id
                 , i.assignable_content_product_section_imilac, i.assignable_content_product_abbr
                 , i.assignable_content_uri_section_id
                 , i.product_code, i.item_id, i.section_id
                 , i.final_grade_scored, i.final_grade_taken, i.final_grade_score, i.final_grade_possiblescore, i.final_grade_scaledscore
                 , i.attempts, i.final_grade_timespent
        FROM take_item_incremental i
        WHERE i.activity
        ORDER BY i.submission_date
        ;;

      sql_step:
        ALTER TABLE item_take_activities RECLUSTER;;

    }

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

  dimension: final_grade {
    hidden: yes
    sql:  ${TABLE}.FINAL_GRADE ;;
    type: string
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
