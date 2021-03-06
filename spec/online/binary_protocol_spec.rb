require File.expand_path('../../spec_helper.rb', __FILE__)

describe "Binary Protocol" do
  include EM::Spec
  
  before(:all) do
    ChildProcessManager.spawn({:cmd => "ktserver -host #{KT_OPTS[:host]} -port #{KT_OPTS[:port]} -scr #{File.dirname(__FILE__)}/../testscript.lua -log #{File.dirname(__FILE__)}/../log/ktserver.log -li ':#ktcapsiz=16m'",
                               :port => KT_OPTS[:port]})
    done
  end
  
  after(:all) do
    ChildProcessManager.reap_all
    done
  end
  
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

  it "Should support the play_script command" do
    client = EM::Tycoon.connect(KT_OPTS)
    client.should be
    args = {"arg1" => "value1", "arg2" => "value2", "arg3" => "value3"}
    client.play_script("testscript", args) { |result|
      result.should be_kind_of(Hash)
      args.each_pair do |k,v|
        result[k][:value].should == args[k]
      end
      done
    }
  end

end