# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/codecs/uri"
require "logstash/event"
require "uri"

describe LogStash::Codecs::URI do
  subject do
    LogStash::Codecs::URI.new
  end
  let(:test_data) {
    {
      "foo" => "bar",
      "list" => [ 0, '%&0' ],
      "hash" => { "a" => "b", "c" => "d" },
      "&" => " ",
    }
  }
  let(:uri_encoded_data) { URI.encode_www_form(test_data) }

  shared_examples :codec do
    context "#decode" do
      it "should return an event from URI encoded data" do
        sent_event = false
        subject.decode(uri_encoded_data) do |event|
          expect(event.get("foo")).to eq("bar")
          expect(event.get("list")).to be_instance_of(Array)
          expect(event.get("hash")).to be_instance_of(Hash)
          expect(event.get("&")).to eq(" ")
          sent_event = true
        end
        expect(sent_event).to eq(true)
      end
    end

    context "#encode" do
      it "should return URI encoded data" do
        event = LogStash::Event.new(test_data)
        got_event = false
        subject.on_event do |event, data|
          expect(URI.decode_www_form(data).assoc("foo").last).to eq("bar")
          expect(URI.decode_www_form(data).assoc("&").last).to eq(" ")
          expect(URI.decode_www_form(data).assoc("list").last).to eq("0")
          expect(URI.decode_www_form(data).assoc("hash").last).to eq('{"a"=>"b", "c"=>"d"}')
          got_event = true
        end
        subject.encode(event)
        expect(got_event).to eq(true)
      end
    end
  end

  include_examples(:codec)
end
