require File.expand_path('../../spec_helper.rb', __FILE__)

describe "Binary Protocol" do
  include EM::Spec
  
  it "Should support get and set operations with single KV pairs" do
    client = EM::Tycoon.connect(KT_OPTS)
    client.should be
    client.set("key1" => "value1") { |result|
      result.should == 1
      client.get("key1") {|getresult|
        getresult["key1"][:value].should == "value1"
        client.remove("key1") {|removeresult|
          removeresult.should == 1
          done
        }
      }
    }
  end
  
  it "Should support get and set operations with multiple KV pairs" do
    client = EM::Tycoon.connect(KT_OPTS)
    client.should be
    xt = Time.now+86400
    kvs = {
      "key1" => {:value => "value1", :xt => xt},
      "key2" => {:value => "value2", :xt => xt} 
      }
    client.set(kvs) { |result|
        result.should == 2
        client.get(kvs.keys) {|getresult|
          kvs.each_pair do |k,v|
            getresult[k][:value].should == v[:value]
            getresult[k][:dbidx].should == 0
            getresult[k][:xt].should <= v[:xt]
          end
          client.remove(kvs.keys) {|removeresult|
            removeresult.should == 2
            done
          }
        }
      }
  end

end