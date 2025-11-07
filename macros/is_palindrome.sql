{% macro is_palindrome(column) %}
  
  num_str = str(column) 
  return num_str == num_str[::-1]

{% endmacro %}
