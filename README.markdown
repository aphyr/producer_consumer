    ProducerConsumer.produce 4 do |p|
      some_item or p.finish
    end.consume 10 do |item|
      puts item
    end.run
