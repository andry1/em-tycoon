require 'spec_helper.rb'

describe "Kyoto Tycoon Messages" do
  before(:each) do
    @single_set_hsh = {
      "mykey" => "myvalue"
    }
    @multiple_set_hsh = {
      "mykey1" => "myvalue1",
      "my_longer_key2" => "myvalue2",
      "mykey3" => "my_longer_value3"
    }
    @get_key = @single_set_hsh.keys.first
    @multiple_get_keys = @multiple_set_hsh.keys
    @single_set_keysize = @single_set_hsh.keys.first.bytesize
    @single_set_valuesize = @single_set_hsh.values.first.bytesize
    @multiple_set_keysize = 0
    @multiple_set_valuesize = 0
    @multiple_set_hsh.each_pair do |k,v|
      @multiple_set_keysize += k.bytesize
      @multiple_set_valuesize += v.bytesize
    end
    @single_set_packed = [0xB8, 0, 1, 0,
                          @single_set_keysize, @single_set_valuesize, "7#{'F'*15}",
                          @single_set_hsh.keys.first, @single_set_hsh.values.first].pack("CNNnNNH*a*a*")
    @multiple_set_packed = [0xB8, 0, 3, 0, 0, 0,
                            @multiple_set_keysize, @multiple_set_valuesize, ["7#{'F'*15}"]*@multiple_set_hsh.length,
                            @multiple_set_hsh.keys, @multiple_set_hsh.values].flatten.pack("CNNnnnNNH*H*H*#{'a*'*(@multiple_set_hsh.length*2)}")
    @single_get_packed = [0xBA, 0, 1, 0, "mykey".bytesize, "mykey"].pack("CNNnNa*")
    @multiple_get_packed = [0xBA, 0, 3, [0]*3, "mykey1".bytesize, "my_longer_key2".bytesize, "mykey3".bytesize,
                            "mykey1", "my_longer_key2", "mykey3"].flatten.pack("CNNnnnNNNa*a*a*")
    @single_remove_packed = [0xB9, 0, 1, 0, "mykey".bytesize, "mykey"].pack("CNNnNa*")
    @multiple_remove_packed = [0xB9, 0, 3, [0]*3, "mykey1".bytesize, "my_longer_key2".bytesize, "mykey3".bytesize,
                            "mykey1", "my_longer_key2", "mykey3"].flatten.pack("CNNnnnNNNa*a*a*")
    @set_bulk_reply = [0xB8, 2].pack("CN")
    @get_bulk_reply = [0xBA, 3, 0, 0, 0, "mykey1".bytesize, "my_longer_key2".bytesize, "mykey3".bytesize,
                       @multiple_set_hsh["mykey1"].bytesize, @multiple_set_hsh["my_longer_key2"].bytesize, @multiple_set_hsh["mykey3"].bytesize,
                       ["7#{'F'*15}"]*3, "mykey1", "my_longer_key2", "mykey3",
                       @multiple_set_hsh["mykey1"], @multiple_set_hsh["my_longer_key2"], @multiple_set_hsh["mykey3"]].flatten.pack("CNnnnNNNNNNH*H*H*a*a*a*a*a*a*")
    @remove_bulk_reply = [0xB9, 4].pack("CN")
  end
  
  it "Should generate a set_bulk message properly with one key/value pair" do
    msg = EM::Tycoon::Protocol::Message.generate(:set, @single_set_hsh)
    msg.should == @single_set_packed
  end

  it "Should generate a set_bulk message properly with multiple key/value pairs" do
    msg = EM::Tycoon::Protocol::Message.generate(:set, @multiple_set_hsh)
    msg.should == @multiple_set_packed
  end

  
  it "Should parse a set_bulk reply properly" do
    count = EM::Tycoon::Protocol::Message.parse(@set_bulk_reply)
    count.should be_kind_of(Integer)
    count.should == 2
  end
  
  it "Should generate a get_bulk message properly with one key" do
    msg = EM::Tycoon::Protocol::Message.generate(:get, "mykey")
    msg.should == @single_get_packed
  end

  it "Should generate a get_bulk message properly with multiple keys" do
    msg = EM::Tycoon::Protocol::Message.generate(:get, ["mykey1","my_longer_key2","mykey3"])
    msg.should == @multiple_get_packed
  end
  
  it "Should parse a get_bulk reply properly" do
    msg = EM::Tycoon::Protocol::Message.parse(@get_bulk_reply)
    msg.should be_instance_of(Hash)
    msg.length.should == 3
    @multiple_set_hsh.each_pair do |k,v|
      msg[k].should be_kind_of(Hash)
      msg[k][:value].should == v
      msg[k][:xt].should == nil   
    end
  end
  
  it "Should generate a remove_bulk message properly with one key" do
    msg = EM::Tycoon::Protocol::Message.generate(:remove, "mykey")
    msg.should == @single_remove_packed
  end
  
  it "Should generate a remove_bulk message properly with multiple keys" do
    msg = EM::Tycoon::Protocol::Message.generate(:remove, ["mykey1","my_longer_key2","mykey3"])
    msg.should == @multiple_remove_packed
  end
  
  it "Should parse a remove_bulk reply properly" do
    count = EM::Tycoon::Protocol::Message.parse(@remove_bulk_reply)
    count.should be_kind_of(Integer)
    count.should == 4
  end
  
  it "Should parse an error reply properly" do
  end
  
end