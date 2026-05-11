{% test assert_datacenter_type(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} is not null
  and {{ column_name }} not in (
      'campus',
      'building',
      'point'
  )

{% endtest %}