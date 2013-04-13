# Torckapi — torrent tracker querying API

[![Gem Version](https://badge.fury.io/rb/torckapi.png)](http://badge.fury.io/rb/torckapi)
[![Code Climate](https://codeclimate.com/github/krupenik/torckapi.png)](https://codeclimate.com/github/krupenik/torckapi)
[![Dependency Status](https://gemnasium.com/krupenik/torckapi.png)](https://gemnasium.com/krupenik/torckapi)

## Description

Torckapi is a querying interface to torrent trackers.

## Synopsis

```
tracker = Torckapi.tracker("udp://generic.url:80/announce")
# => #<Torckapi::Tracker::UDP:0x007fb5941f6ef8
#      @url=#<URI::Generic:0x007fb5941f7038 URL:udp://generic.url:80/announce>,
#      @options={:timeout=>15, :tries=>3}>
```

### Queries
```
tracker.announce("0123456789ABCDEF0123456789ABCDEF01234567")
# => #<Torckapi::Response::Announce:0x007fa1bc0f11c0
#      @info_hash="0123456789ABCDEF0123456789ABCDEF01234567",
#      @leechers=1,
#      @seeders=1,
#      @peers=[["127.0.0.1", 54078], ["127.0.0.2", 43666]]>

tracker.scrape(["0123456789ABCDEF0123456789ABCDEF01234567", "123456789ABCDEF0123456789ABCDEF012345678"])
# => #<Torckapi::Response::Scrape:0x007fa1bc0fe320
#      @data={"0123456789ABCDEF0123456789ABCDEF01234567"=>{:seeders=>3, :completed=>0, :leechers=>13},
#             "123456789ABCDEF0123456789ABCDEF012345678"=>{:seeders=>4, :completed=>10, :leechers=>8}}>
```

## TODO

Add tests.

Document everything.