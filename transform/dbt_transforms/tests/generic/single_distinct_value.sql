{% test single_distinct_value(model, column_name) %}

select
    count(distinct {{ column_name }}) as distinct_count
from {{ model }}
having count(distinct {{ column_name }}) > 1

{% endtest %}