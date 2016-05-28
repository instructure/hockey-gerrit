```ruby
# ArgumentError: WebMock does not support matching body for multipart/form-data requests yet :(
# https://github.com/bblimke/webmock/issues/623
# expect(WebMock).to have_requested(http_method, http_uri).
#    with(body: http_body, headers: http_headers)
````
