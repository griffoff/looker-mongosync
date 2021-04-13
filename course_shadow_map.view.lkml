explore: course_shadow_map {hidden:yes}
view: course_shadow_map {
  derived_table: {
    sql:
    with shadow as (
      select split_part(short_label, '.', 3) as id, course_uri
      from prod.realtime.course
      where course_uri like 'cnow:course:%'
        and id != ''
    )
    select DISTINCT c.course_uri as parent_course_uri, shadow.course_uri as shadow_course_uri
    from realtime.course c
    inner join shadow on c.external_properties:"mindtap:property:snapshot-id":value = shadow.id
    ;;

    datagroup_trigger: daily_refresh
  }

  dimension: parent_course_uri {}
  dimension: shadow_course_uri {}
}
