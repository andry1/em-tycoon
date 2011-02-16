require File.expand_path('../../spec_helper.rb', __FILE__)

describe "Binary Protocol" do
  include EM::Spec
  
  it "Should support get and set operations with single KV pairs" do
    client = EM::Tycoon.connect(KT_OPTS)
    client.should be
    client.set("key1" => "value1") { |result|
      result.should == 1
      done
    }
  end
  
  pending "Should support get and set operations with multiple KV pairs" do
    client = EM::Tycoon.connect(KT_OPTS)
    client.should be
    client.set({
      "key1" => "value1",
      "key2" => "value2" }) { |result|
        result.should == 2
        done
      }
  end

end