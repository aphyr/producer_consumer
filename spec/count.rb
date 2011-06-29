#!/usr/bin/env ruby

require 'rubygems'
require 'bacon'
require 'set'

require File.expand_path("#{File.dirname(__FILE__)}/../lib/producer_consumer")

Bacon.summary_on_exit

describe 'ProducerConsumer' do
  it 'should produce and consume integers' do
    n = 1000
    q = (0...n).inject(Queue.new) do |q, i|
      q << i
      q
    end

    out = Queue.new

    ProducerConsumer.produce do |p|
      begin
        x = q.pop true
        x
      rescue
        p.finish
      end
    end.consume do |i|
      out << i
    end.run

    out_array = []
    while x = (out.pop(true) rescue nil)
      out_array << x
    end

    # Verify
    (0...n).to_a.should == out_array.sort
  end
end
