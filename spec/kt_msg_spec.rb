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
    @multiple_set_packed = [0xB8, 0, 3]
    @get_bulk_reply = [0xBA, 3]
    @multiple_set_hsh.each_pair do |k,v|
      [@multiple_set_packed,@get_bulk_reply].each do |a|
        a << 0
        a << k.bytesize
        a << v.bytesize
        a << EM::Tycoon::Protocol::Message::NO_XT_HEX
        a << k
        a << v
      end
    end
    # XTs of "none" coming back in response are not 0x7FF...
    @get_bulk_reply.collect! {|x| (x == EM::Tycoon::Protocol::Message::NO_XT_HEX) ? "000000ffffffffff" : x}
    @multiple_set_packed = @multiple_set_packed.pack("CNN#{EM::Tycoon::Protocol::Message::KV_PACK_FMT*@multiple_set_hsh.keys.length}")
    @multiple_get_packed = [0xBA, 0, 3, 
                            0, "mykey1".bytesize, "mykey1",
                            0, "my_longer_key2".bytesize, "my_longer_key2",
                            0, "mykey3".bytesize, "mykey3"].pack("CNN"+("nNa*"*3))
    @single_set_packed = [0xB8, 0, 1, 0,
                          @single_set_keysize, @single_set_valuesize, "7#{'F'*15}",
                          @single_set_hsh.keys.first, @single_set_hsh.values.first].pack("CNNnNNH*a*a*")
    @single_get_packed = [0xBA, 0, 1, 0, "mykey".bytesize, "mykey"].pack("CNNnNa*")
    
    @single_remove_packed = [0xB9, 0, 1, 0, "mykey".bytesize, "mykey"].pack("CNNnNa*")
    @multiple_remove_packed = [0xB9, 0, 3,
                               0, "mykey1".bytesize, "mykey1",
                               0, "my_longer_key2".bytesize, "my_longer_key2",
                               0, "mykey3".bytesize, "mykey3"].pack("CNNnNa*nNa*nNa*")
    @get_bulk_reply = @get_bulk_reply.pack("CN#{EM::Tycoon::Protocol::Message::KV_PACK_FMT*@multiple_set_hsh.keys.length}")
    @set_bulk_reply = [0xB8, 2].pack("CN")
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
    msg = EM::Tycoon::Protocol::Message.message_for(@set_bulk_reply)
    bytes_parsed = msg.parse(@set_bulk_reply)
    bytes_parsed.should == @set_bulk_reply.bytesize
    msg.item_count.should be_kind_of(Integer)
    msg.item_count.should == 2
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
    msg = EM::Tycoon::Protocol::Message.message_for(@get_bulk_reply)
    bytes_parsed = msg.parse(@get_bulk_reply)
    bytes_parsed.should == @get_bulk_reply.bytesize
    msg.item_count.should be_kind_of(Integer)
    msg.item_count.should == 3
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
    msg = EM::Tycoon::Protocol::Message.message_for(@remove_bulk_reply)
    bytes_parsed = msg.parse(@remove_bulk_reply)
    bytes_parsed.should == @remove_bulk_reply.bytesize
    msg.item_count.should be_kind_of(Integer)
    msg.item_count.should == 4
  end
  
  it "Should parse an error reply properly" do
  end
  
end