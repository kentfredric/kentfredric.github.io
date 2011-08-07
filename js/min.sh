curl \
  -d output_info=compiled_code \
  -d compilation_level=SIMPLE_OPTIMIZATIONS \
  -d output_format=text \
  --data-urlencode js_code="$( cat $1 )" \
  http://closure-compiler.appspot.com/compile

