class ProducerConsumer
  require 'thread'

  class Finished < Exception
  end

  class NoConsumer < RuntimeError
  end

  class NoProducer < RuntimeError
  end

  class Producer
    def finish
      raise ProducerConsumer::Finished
    end 
  end

  def self.consume(*a, &b)
    new.consume(*a, &b)
  end

  def self.produce(*a, &b)
    new.produce(*a, &b)
  end

  # Oh god. It's a PATTERN.
  def initialize
    @queue = Queue.new 
    @state = :free
    @producers = []
    @consumers = []
  end

  # Registers n producers
  def produce(n = 1, &block)
    @producers += (0...n).map do |i|
      block
    end

    self
  end

  def producer(block)
    Thread.new do
      p = Producer.new
      begin
        loop do
          @queue << block.call(p)
        end
      rescue Finished
      end
    end
  end

  # Registers n consumers
  def consume(n = 1, &block)
    @consumers += (0...n).map do |c|
      block
    end

    self
  end

  def consumer(block)
    Thread.new do
      begin
        loop do
          x = @queue.pop

          if x == Finished
            raise Finished
          end

          block.call x
        end
      rescue Finished
      end
    end
  end

  # Run!
  def run
    # Can't run this more than once.
    unless @state == :free
      raise RuntimeError, "Already running"
    end

    # Validate we will actually do something.
    raise NoConsumer if @consumers.empty?
    raise NoProducer if @producers.empty?

    # Start producers and consumers
    @state = :starting
    consumers = @consumers.map do |block|
      consumer block
    end
    producers = @producers.map do |block|
      producer block
    end

    # Wait for producers to finish
    @state = :waiting_for_producers
    producers.each { |t| t.join }

    # Signal consumers to finish...
    @state = :waiting_for_consumers
    consumers.size.times do
      @queue << Finished
    end
    consumers.each { |t| t.join }

    @state = :free
  end
end
