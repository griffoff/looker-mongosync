view: product_item_metadata {
#   sql_table_name: REALTIME.PRODUCT_ITEM_METADATA ;;
  derived_table: {
    sql:
      with data as (
        select
          _hash as business_key
          ,case when lead(last_update_date) over(partition by business_key order by last_update_date) is null then 1 end as latest
          ,*
        from REALTIME.PRODUCT_ITEM_METADATA
      )
      select *
      from data
      where latest = 1
      order by item_id, item_uri
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

  dimension: ancestor_ids {
    type: string
    sql: ${TABLE}.ANCESTOR_IDS ;;
  }

  dimension: cgid {
    type: string
    sql: ${TABLE}.CGID ;;
  }

  dimension: handler {
    type: string
    sql: ${TABLE}.HANDLER ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}.ITEM_ID ;;
    link: {
      label: "Geyser: PreProd"
      url: "https://preprod.geyser.cl-cms.com/nav-item.xqy?item=%2Fgeyser%2F{{ product_toc_metadata.discipline._value }}%2Fitems%2F {{ product_code._value }} %2F{{ name._value }}.xml&modal=1&reload=0"
    }
    link: {
      label: "Geyser: Prod"
      url: "https://prod.geyser.cl-cms.com/nav-item.xqy?item=%2Fgeyser%2F{{ product_toc_metadata.discipline._value }}%2Fitems%2F {{ product_code._value }} %2F{{ name._value }}.xml&modal=1&reload=0"
    }
  }

  dimension: item_uri {
    type: string
    sql: ${TABLE}.ITEM_URI ;;
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

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
    link: {
      label: "Geyser: PreProd"
      url: "https://preprod.geyser.cl-cms.com/nav-item.xqy?item=%2Fgeyser%2F{{ product_toc_metadata.discipline._value }}%2Fitems%2F {{ product_code._value }} %2F{{ name._value }}.xml&modal=1&reload=0"
    }
    link: {
      label: "Geyser: Prod"
      url: "https://prod.geyser.cl-cms.com/nav-item.xqy?item=%2Fgeyser%2F{{ product_toc_metadata.discipline._value }}%2Fitems%2F {{ product_code._value }} %2F{{ name._value }}.xml&modal=1&reload=0"
    }
  }

  dimension: parent_id {
    type: string
    sql: ${TABLE}.PARENT_ID ;;
  }

  dimension: product_code {
    type: string
    sql: ${TABLE}.PRODUCT_CODE ;;
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
