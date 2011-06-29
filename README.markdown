Install
===

    gem install producer_consumer

Use
===

    ProducerConsumer.produce 4 do |p|
      # 4 threads will produce items. When they're done, they call p.finish.
      some_item or p.finish
    end.consume 10 do |item|
      # 10 threads will consume items produced by the above block.
      puts item
    end.run
