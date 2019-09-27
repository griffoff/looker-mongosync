view: all_users {
  derived_table: {
    sql: select distinct(user_sso_guid),
            (case
            when UID like 'gw-%'
            then right(UID, charindex('-', reverse(uid)) - 1)
            else UID end)
            as LMS_ID
            from IAM.PROD.USER_MUTATION
 ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

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
