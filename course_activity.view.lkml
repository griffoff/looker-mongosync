view: course_activity {
  #sql_table_name: realtime.course_activity ;;
  derived_table: {

    create_process: {

      sql_step:
        USE SCHEMA looker_scratch
      ;;

      sql_step:
        CREATE TRANSIENT TABLE IF NOT EXISTS course_activity
        (
          _hash                       STRING,
          _ldts                       TIMESTAMP,
          _rsrc                       STRING,
          course_uri                  STRING,
          activity_uri                STRING,
          activity_group_uris         ARRAY,
          assignable_content_uri      STRING,
          label                       STRING,
          excluded                    BOOLEAN,
          default_aggregation_spec    VARIANT,
          external_properties         VARIANT,
          last_update_date            TIMESTAMP,
          best_label                  STRING,
          initial_external_properties VARIANT,
          prev_external_properties    VARIANT
        ) CLUSTER BY (course_uri, activity_uri)
      ;;

      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE course_activity_incremental
        AS
        WITH latest AS
          (
            SELECT _hash AS h, max(_ldts) AS d
            FROM prod.realtime.course_activity a
            WHERE _ldts > (
                            SELECT COALESCE(max(_ldts), '1970-01-01')
                            FROM course_activity
                          )
            GROUP BY 1
          )
           , data AS (
                       SELECT _hash
                            , _ldts
                            , _rsrc
                            , course_uri
                            , activity_uri
                            , activity_group_uris
                            , assignable_content_uri
                            , label
                            , excluded
                            , default_aggregation_spec
                            , external_properties
                            , last_update_date
                       FROM prod.realtime.course_activity
                     )
        SELECT d.*
        FROM latest l
             INNER JOIN data d ON (l.h, l.d) = (d._hash, d._ldts)
        ORDER BY _hash
        ;;

      sql_step:
        MERGE INTO course_activity t
          USING course_activity_incremental i ON t._hash = i._hash
          WHEN MATCHED THEN UPDATE
            SET
              t._hash = i._hash
              ,t._ldts = i._ldts
              ,t._rsrc = i._rsrc
              ,t.course_uri = i.course_uri
              ,t.activity_uri = i.activity_uri
              ,t.activity_group_uris = i.activity_group_uris
              ,t.assignable_content_uri = i.assignable_content_uri
              ,t.label = i.label
              ,t.excluded = i.excluded
              ,t.default_aggregation_spec = i.default_aggregation_spec
              ,t.prev_external_properties = t.external_properties
              ,t.external_properties = i.external_properties
              ,t.last_update_date = i.last_update_date
          WHEN NOT MATCHED THEN INSERT (
                                        _hash, _ldts, _rsrc, course_uri, activity_uri, activity_group_uris,
                                        assignable_content_uri, label, excluded, default_aggregation_spec, external_properties,
                                        last_update_date, initial_external_properties
            )
            VALUES ( i._hash
                   , i._ldts
                   , i._rsrc
                   , i.course_uri
                   , i.activity_uri
                   , i.activity_group_uris
                   , i.assignable_content_uri
                   , i.label
                   , i.excluded
                   , i.default_aggregation_spec
                   , i.external_properties
                   , i.last_update_date
                   , i.external_properties)
        ;;

      sql_step:
        ALTER TABLE course_activity RECLUSTER
        ;;

      sql_step:
        UPDATE course_activity
        SET best_label = l.label
        FROM (
        SELECT label
        , activity_uri
        , count(*) AS popularity
        , row_number() OVER (PARTITION BY activity_uri ORDER BY popularity DESC) AS pop_rank
        FROM course_activity
        WHERE label IS NOT NULL
        GROUP BY 1, 2
        ) l
        WHERE course_activity.activity_uri = l.activity_uri
        AND l.pop_rank = 1
      ;;

      sql_step:
        CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME} CLONE course_activity
        ;;

    }

    datagroup_trigger: realtime_default_datagroup
  }

  dimension: business_key {
    type: string
    hidden: yes
    primary_key: yes
    sql: ${TABLE}._hash ;;
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

  dimension: activity_group_uris {
    type: string
    sql: ${TABLE}.ACTIVITY_GROUP_URIS ;;
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

  dimension: default_aggregation_spec {
    type: string
    sql: ${TABLE}.DEFAULT_AGGREGATION_SPEC ;;
  }

  dimension: excluded {
    type: yesno
    sql: ${TABLE}.EXCLUDED ;;
  }

  dimension: external_properties {
    group_label: "Current Settings"
    type: string
    sql: ${TABLE}.EXTERNAL_PROPERTIES ;;
  }

  dimension: prev_external_properties {
    group_label: "Previous Settings"
    type: string
    sql: ${TABLE}.PREV_EXTERNAL_PROPERTIES ;;
  }

  dimension: initial_external_properties {
    group_label: "Initial Settings"
    type: string
    sql: ${TABLE}.INITIAL_EXTERNAL_PROPERTIES ;;
  }

  dimension: max_takes {
    group_label: "Current Settings"
    description: "external_properties.soa:property:maxTakes"
    type: number
    sql:  TRY_CAST(COALESCE(
                  ${external_properties}:"soa:property:maxTakes":value:"$numberLong"
                  ,${external_properties}:"cnow:property:allowed-take-count":value:"$numberLong"
          )::STRING as DECIMAL(3, 0)) ;;
  }

  dimension: prev_max_takes {
    group_label: "Previous Settings"
    description: "previous external_properties.soa:property:maxTakes"
    type: number
    sql:  TRY_CAST(COALESCE(
                  ${prev_external_properties}:"soa:property:maxTakes":value:"$numberLong"
                  ,${prev_external_properties}:"cnow:property:allowed-take-count":value:"$numberLong"
          )::STRING as DECIMAL(3, 0)) ;;
  }

  dimension: initial_max_takes {
    group_label: "Initial Settings"
    description: "previous external_properties.soa:property:maxTakes"
    type: number
    sql:  TRY_CAST(COALESCE(
                  ${initial_external_properties}:"soa:property:maxTakes":value:"$numberLong"
                  ,${initial_external_properties}:"cnow:property:allowed-take-count":value:"$numberLong"
          )::STRING as DECIMAL(3, 0)) ;;
  }

  dimension: label {
    type: string
    sql: ${TABLE}.best_label ;;
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

  measure: count {
    type: count
    drill_fields: [course_uri, activity_uri, label, activity_group_uris, external_properties]
  }
}
