include: "//cengage_unlimited/views/cu_user_analysis/product_info.view"
include: "/product_item_metadata.view"
include: "/product_activity_metadata.view"
include: "/product_mastery_group.view"

explore: product_toc_metadata {
  view_name: product_toc_metadata
  from: product_toc_metadata
  label: "CXP Content Service"
  hidden: yes
  extends: [product_item_metadata, product_info]

  join: product_item_metadata {
    sql_on: (${product_toc_metadata.source_system}, ${product_toc_metadata.product_code})
        = (${product_item_metadata.source_system}, ${product_item_metadata.product_code})
          ;;
    relationship: one_to_many
  }
  join: product_info {
    sql_on: ${product_toc_metadata.isbn} = ${product_info.isbn13} ;;
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

view: product_toc_metadata {
#   sql_table_name: REALTIME.PRODUCT_TOC_METADATA ;;
    derived_table: {
      sql:
        with data as (
          select
            _hash as business_key
            ,case when lead(_ldts) over(partition by business_key order by _ldts) is null then 1 end as latest
            ,DATE_PROCESSED
            ,_HASH
            ,NAME
            ,SIBLING_ORDER
            ,FORMAT
            ,PRODUCT
            ,_LDTS
            ,PRODUCT_CODE
            ,ABBR
            ,LINK
            ,PARENT_ID
            ,CGID
            ,ISBN
            ,NODE_ID
            ,SOURCE_SYSTEM
            ,max(DISCIPLINE) over (partition by PRODUCT_CODE) as DISCIPLINE
            ,ANCESTOR_IDS
            ,_RSRC
          from REALTIME.PRODUCT_TOC_METADATA
      )
      select *
      from data
      where latest = 1
      order by product_code, node_id
      ;;

      datagroup_trigger: realtime_default_datagroup
    }
#   derived_table: {
#     sql:
#       with data as (
#         select
#           _hash as business_key
#           ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
#           ,*
#         from REALTIME.PRODUCT_TOC_METADATA
#       )
#       select *
#       from data
#       where latest = 1
#       order by source_system, product_code
#       ;;
#
#       datagroup_trigger: realtime_default_datagroup
#   }

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

  dimension: abbr {
    type: string
    sql: ${TABLE}.ABBR ;;
  }

  dimension: ancestor_ids {
    type: string
    sql: ${TABLE}.ANCESTOR_IDS ;;
  }

  dimension: cgid {
    type: string
    sql: ${TABLE}.CGID ;;
  }

  dimension_group: date_processed {
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
    sql: ${TABLE}.DATE_PROCESSED ;;
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}.DISCIPLINE ;;
  }

  dimension: format {
    type: string
    sql: ${TABLE}.FORMAT ;;
  }

  dimension: isbn {
    type: string
    sql: split_part(${TABLE}.ISBN, ';', 1)::string ;;
  }

  dimension: link {
    type: string
    sql: ${TABLE}.LINK ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: node_id {
    type: string
    sql: ${TABLE}.NODE_ID ;;
  }

  dimension: parent_id {
    type: string
    sql: ${TABLE}.PARENT_ID ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}.PRODUCT ;;
  }

  dimension: product_code {
    type: string
    sql: ${TABLE}.PRODUCT_CODE ;;
    link: {
      label: "Geyser: PreProd"
      url: "https://preprod.geyser.cl-cms.com/nav-toc.xqy/{{ value }}"
    }
    link: {
      label: "Geyser: Prod"
      url: "https://prod.geyser.cl-cms.com/nav-toc.xqy/{{ value }}"
    }
  }

  dimension: sibling_order {
    type: string
    sql: ${TABLE}.SIBLING_ORDER ;;
  }

  dimension: source_system {
    type: string
    sql: ${TABLE}.SOURCE_SYSTEM ;;
  }

  measure: count {
    type: count
    drill_fields: [name]
  }
}
