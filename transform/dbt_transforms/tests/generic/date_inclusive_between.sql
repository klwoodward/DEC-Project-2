{% test date_inclusive_between(model, column_name, start_date, end_date) %}

select *
from {{ model }}
where {{ column_name }} < cast('{{ start_date }}' as date)
   or {{ column_name }} > cast('{{ end_date }}' as date)

{% endtest %}