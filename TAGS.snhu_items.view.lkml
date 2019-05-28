view: snhu_items {
  sql_table_name: Uploads.LOTS.SNHU_ITEMS ;;

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
    hidden:  yes
  }

  dimension_group: _fivetran_synced {
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
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
    hidden:  yes
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    hidden:  yes
  }

  dimension: acbsp_taxonomy_code {
    type: number
    sql: ${TABLE}."ACBSP_TAXONOMY_CODE" ;;
  }

  dimension: acbsp_taxonomy_code_2 {
    type: number
    sql: ${TABLE}."ACBSP_TAXONOMY_CODE_2" ;;
  }

  dimension: acbsp_taxonomy_code_3 {
    type: number
    sql: ${TABLE}."ACBSP_TAXONOMY_CODE_3" ;;
  }

  dimension: acbsp_taxonomy_tag {
    type: string
    sql: ${TABLE}."ACBSP_TAXONOMY_TAG" ;;
  }

  dimension: acbsp_taxonomy_tag_2 {
    type: string
    sql: ${TABLE}."ACBSP_TAXONOMY_TAG_2" ;;
  }

  dimension: acbsp_taxonomy_tag_3 {
    type: string
    sql: ${TABLE}."ACBSP_TAXONOMY_TAG_3" ;;
  }

  dimension: bus_prog_taxonomy_aacsb_code {
    type: number
    sql: ${TABLE}."BUS_PROG_TAXONOMY_AACSB_CODE" ;;
  }

  dimension: bus_prog_taxonomy_aacsb_tag {
    type: string
    sql: ${TABLE}."BUS_PROG_TAXONOMY_AACSB_TAG" ;;
  }

  dimension: cnow_item_id {
    type: number
    sql: ${TABLE}."CNOW_ITEM_ID" ;;
  }

  dimension: display_name {
    type: string
    sql: ${TABLE}."DISPLAY_NAME" ;;
  }

  dimension: gaps_between_cengage_s_los_and_snhu_s_los {
    type: string
    sql: ${TABLE}."GAPS_BETWEEN_CENGAGE_S_LOS_AND_SNHU_S_LOS" ;;
    hidden:  yes
  }

  dimension: geyser_generic_taxonomy_tag {
    type: string
    sql: ${TABLE}."GEYSER_GENERIC_TAXONOMY_TAG" ;;
  }

  dimension: geyser_lo_tag {
    type: string
    sql: ${TABLE}."GEYSER_LO_TAG" ;;
    hidden:  yes
  }

  dimension: industry_standard_aicpa_code {
    type: number
    sql: ${TABLE}."INDUSTRY_STANDARD_AICPA_CODE" ;;
  }

  dimension: industry_standard_aicpa_tag {
    type: string
    sql: ${TABLE}."INDUSTRY_STANDARD_AICPA_TAG" ;;
  }

  dimension: item_cgid {
    type: string
    sql: ${TABLE}."ITEM_CGID" ;;
    hidden: yes
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}."ITEM_NAME" ;;
  }

  dimension: module {
    type: number
    sql: ${TABLE}."MODULE" ;;
  }

  dimension: difficulty {
    type: string
    sql: ${TABLE}."DIFFICULTY_RANKING" ;;
  }

  dimension: snhu_objective_id {
    type: string
    sql: ${TABLE}."SNHU_OBJECTIVE_ID" ;;
  }

  dimension: snhu_objective_id_formatted_for_lookup_ {
    type: string
    sql: ${TABLE}."SNHU_OBJECTIVE_ID_FORMATTED_FOR_LOOKUP_" ;;
  }

  dimension: snhu_objective_tag_first_lo_only_ {
    type: string
    sql: ${TABLE}."SNHU_OBJECTIVE_TAG_FIRST_LO_ONLY_" ;;
  }

  measure: count {
    type: count
    drill_fields: [display_name, item_name]
  }
}
