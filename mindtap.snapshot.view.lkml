view: mindtap_snapshot {

    derived_table: {
      sql:select snap.id as snapshotid, o.external_id as coursekey
            from mindtap.prod_nb.snapshot snap
            inner join mindtap.prod_nb.org o on snap.org_id = o.id;;

      datagroup_trigger: mindtap_snapshot
        }

  dimension: snapshotid  {}

  dimension: coursekey {}

}
