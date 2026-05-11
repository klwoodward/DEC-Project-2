{% test assert_differing_col_values(model, column_a, column_b) %}

select *
from {{ model }}
where {{ column_a }} is not null
  and {{ column_b }} is not null
  and {{ column_a }} = {{ column_b }}

{% endtest %}