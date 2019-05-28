view: all_users {
  derived_table: {
    sql: select (
            case
            when UID like 'gw-%'
            then right(UID, charindex('-', reverse(uid)) - 1)
            else UID end)
            as LMS_ID, user_sso_guid, uid, first_name, last_name, email,
            linked_guid, marketing_opt_out, k12_user, TL_INSTITUTION_ID,
            TL_INSTITUTION_NAME, instructor, country from IAM.PROD.USER_MUTATION
 ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: uid {
    type: string
    sql: ${TABLE}."UID" ;;
  }

  dimension: lms_id {
    label: "LMS ID"
    type: string
    sql: ${TABLE}."LMS_ID" ;;
  }

  dimension: first_name {
    type: string
    sql:
    CASE WHEN '{{ _user_attributes["pii_visibility_enabled"] }}' = 'yes' THEN
    ${TABLE}."FIRST_NAME"
    ELSE
    MD5(${TABLE}."FIRST_NAME" || 'salt')
    END ;;
    html:
    {% if _user_attributes["pii_visibility_enabled"]  == 'yes' %}
    {{ value }}
    {% else %}
    [Masked]
    {% endif %}  ;;
  }

  dimension: last_name {
    type: string
    sql:
    CASE WHEN '{{ _user_attributes["pii_visibility_enabled"] }}' = 'yes' THEN
    ${TABLE}."LAST_NAME"
    ELSE
    MD5(${TABLE}."LAST_NAME" || 'salt')
    END ;;
    html:
    {% if _user_attributes["pii_visibility_enabled"]  == 'yes' %}
    {{ value }}
    {% else %}
    [Masked]
    {% endif %}  ;;
  }

  dimension: email {
    type: string
    sql:
    CASE WHEN '{{ _user_attributes["pii_visibility_enabled"] }}' = 'yes' THEN
    ${TABLE}."EMAIL"
    ELSE
    MD5(${TABLE}."EMAIL" || 'salt')
    END ;;
    html:
    {% if _user_attributes["pii_visibility_enabled"]  == 'yes' %}
    {{ value }}
    {% else %}
    [Masked]
    {% endif %}  ;;
  }

  dimension: linked_guid {
    type: string
    sql: ${TABLE}."LINKED_GUID" ;;
  }

  dimension: marketing_opt_out {
    type: string
    sql: ${TABLE}."MARKETING_OPT_OUT" ;;
  }

  dimension: k12_user {
    type: string
    sql: ${TABLE}."K12_USER" ;;
  }

  dimension: tl_institution_id {
    type: string
    sql: ${TABLE}."TL_INSTITUTION_ID" ;;
  }

  dimension: tl_institution_name {
    type: string
    sql: ${TABLE}."TL_INSTITUTION_NAME" ;;
  }

  dimension: instructor {
    type: string
    sql: ${TABLE}."INSTRUCTOR" ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      lms_id,
      user_sso_guid,
      uid,
      first_name,
      last_name,
      email,
      linked_guid,
      marketing_opt_out,
      k12_user,
      tl_institution_id,
      tl_institution_name,
      instructor,
      country
    ]
  }
}
