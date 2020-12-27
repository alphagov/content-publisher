#!/usr/bin/env ruby

require("webrick")

server = WEBrick::HTTPServer.new(Port: 9999)

server.mount_proc("/v2/expanded-links") do |request, response|
  response.body = <<RESPONSE
{
  "expanded_links": {
    "level_one_taxons": [
      {
        "content_id": "20583132-1619-4c68-af24-77583172c070",
        "links": []
      }
    ]
  }
}
RESPONSE
end

server.mount_proc("/v2/links") do |request, response|
  response.body = <<RESPONSE
{
  "links": {
    "organisations": [
      "20583132-1619-4c68-af24-77583172c070"
    ]
  }
}
RESPONSE
end

server.mount_proc("/v2/linkables") do |request, response|
  response.body = <<RESPONSE
[
  {
    "title": "Content Item A",
    "internal_name": "an internal name",
    "content_id": "aaaaaaaa-aaaa-1aaa-aaaa-aaaaaaaaaaaa",
    "publication_state": "draft",
    "base_path": "/a-base-path"
  },
  {
    "title": "Content Item B",
    "internal_name": "Content Item B",
    "content_id": "bbbbbbbb-bbbb-2bbb-bbbb-bbbbbbbbbbbb",
    "publication_state": "published",
    "base_path": "/another-base-path"
  }
]
RESPONSE
end

server.start

