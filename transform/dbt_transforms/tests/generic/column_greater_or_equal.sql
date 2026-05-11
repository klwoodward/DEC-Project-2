{% test column_greater_or_equal(model, column_name, min_value) %}

select *
from {{ model }}
where {{ column_name }} < {{ min_value }}

{% endtest %}