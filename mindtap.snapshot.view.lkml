view: mindtap_snapshot {

    derived_table: {
      sql:select s.id as snapshotid, o.external_id as coursekey
            from mindtap.prod_nb.snapshot s
            inner join mindtap.prod_nb.org o on s.org_id = o.id;;

      datagroup_trigger: mindtap_snapshot
        }

  dimension: snapshotid  {}

  dimension: coursekey {}

}
