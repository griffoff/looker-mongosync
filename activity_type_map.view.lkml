view: activity_type_map {
    derived_table: {
      sql:
      select
        column1 as activity_type_uri_source
        ,column2 as activity_type_uri
        ,split_part(activity_type_uri, ':', 1) as activity_type_system
        ,InitCap(replace(split_part(activity_type_uri, ':', 2), '-', ' ')) as activity_type_clean
        ,coalesce(nullif(column3, ''), activity_type_clean) as activity_type
        ,column4 as is_survey
        ,column5 as has_intermediate_nodes
        ,column6 as not_always_course_based
      from values ('imilac:als-quiz', 'imilac:als-quiz','', false, false, false)
          ,('imilac:als-exam', 'imilac:als-exam','', false, false, true)
          ,('imilac:als-mtqr', 'imilac:als-mtqr','', false, true, false)
          ,('imilac:als-saa', 'imilac:als-saa','', true, false, false)
          ,('cas:assignment', 'cas:assignment','', false, false, false)
          ,('imilac:als-asp', 'imilac:als-asp','', false, true, true)
          ,('imilac:als-csfi', 'imilac:als-csfi','', true, false, false)
          ,('imilac:als-ds', 'imilac:als-ds','', true, false, false)
          ,('imilac:als-pete', 'imilac:als-pete','', false, false, false)
          ,('imilac:als-psp', 'imilac:als-psp','', false, true, true)
          ,('imilac:unknownapplication', 'imilac:unknownapplication','', null, null, null)
          ,('imilac:als-sbs', 'imilac:als-sbs','', false, false, false)
          ,('imilac:alscsfi', 'imilac:als-csfi','', true, false, false)
          ,('imilac:quick-prep-chemv1', 'imilac:quick-prep','', false, true, true)
          ,('imilac:alspete', 'imilac:als-pete','', false, false, false)
          ,('imilac:alspsp', 'imilac:als-psp','', false, true, true)
          ,('imilac:alsquiz', 'imilac:als-quiz','', false, false, false)
          ,('imilac:alssaa', 'imilac:als-saa','', true, false, false)
          ,('imilac:quick-prep-chem', 'imilac:quick-prep','', false, true, true)
          ,('imilac:quickprep', 'imilac:quick-prep','', false, true, true)
          ,('imilac:quickprep2', 'imilac:quick-prep','', false, true, true)
          ,('imilac:alsexam', 'imilac:als-exam','', false, false, true)
          ;;
    }

    dimension: activity_type_uri_source {type:string primary_key:yes}
    dimension: activity_type_uri {type:string}
    dimension: activity_type_system {}
    dimension: activity_type {type:string}
    dimension: is_survey {type:yesno}
    dimension: has_intermediate_nodes {type:yesno}
    dimension: not_always_course_based {type:yesno}
  }
