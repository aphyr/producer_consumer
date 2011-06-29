Install
===

    gem install producer_consumer

Use
===

ProducerConsumer is a model for distributing work concurrently. A producer runs
a block over and over again, yielding a list of objects. Those objects are
handed to consumers. Producers run in n distinct threads, and consumers run in
m distinct threads. When a producer is done, it may optionally call .finish on
its block argument to signal that it has completed its work. #run will wait for
all producers to finish, and terminate the consumers when all items have been
processed.
    
    ProducerConsumer.produce 4 do |p|
      # 4 threads will produce items. When they're done, they call p.finish.
      some_item or p.finish
    end.consume 10 do |item|
      # 10 threads will consume items produced by the above block.
      puts item
    end.run

Here's an example which reads keys from a file and performs deletes against
Riak, across 40 concurrent connections, including status messages.

    #!/usr/bin/env ruby

    require 'rubygems'
    require 'riak'
    require 'producer_consumer'

    f = File.open(ARGV.first)
    c = 0

    ProducerConsumer.produce do |p|
      begin
        key = f.readline.chomp

        puts "<- #{c}" if c % 100 == 0
        [c += 1, k.chomp]
      rescue
        p.finish
      end
    end.consume(40) do |c, key|
      puts "-> #{c}" if c % 100 == 0
      
      r = (Thread.current['riak'] ||= Riak::Client.new(:host => '127.0.0.1', :protocol => 'pbc'))
      
      begin
        r['my_bucket'].delete key, :w => 1, :dw => 0
      rescue Riak::ProtobuffsFailedRequest
      end
    end.run
