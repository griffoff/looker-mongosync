view: all_users {
  derived_table: {
    sql:
    select distinct(t.user_sso_guid)
    ,(case
        when t.UID like 'gw-%'
        then right(t.UID, charindex('-', reverse(t.uid)) - 1)
        else t.UID end)
      as LMS_ID
    , t.first_name, t.last_name, t.email
    from IAM.PROD.USER_MUTATION t
    inner join (
        select distinct(user_sso_guid), max(event_time) as MaxDate
        from IAM.PROD.USER_MUTATION
        group by user_sso_guid
    ) tm on t.user_sso_guid = tm.user_sso_guid and t.event_time = tm.MaxDate
 ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: first_name {}
  dimension: last_name {}
  dimension: email {}

  dimension: lms_id {
    label: "LMS ID"
    type: string
    sql: ${TABLE}."LMS_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      lms_id,
      user_sso_guid,
    ]
  }
}
