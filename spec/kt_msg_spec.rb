require 'spec_helper.rb'

describe "Kyoto Tycoon Messages" do
  before(:each) do
    @single_set_hsh = {
      "mykey" => "myvalue"
    }
    @multiple_set_hsh = {
      "mykey1" => "myvalue1",
      "mykey2" => "myvalue2",
      "mykey3" => "myvalue3"
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
    @multiple_get_packed = [0xBA, 0, 3, [0]*3, "mykey1".bytesize, "mykey2".bytesize, "mykey3".bytesize,
                            "mykey1", "mykey2", "mykey3"].flatten.pack("CNNnnnNNNa*a*a*")
  end
  
  it "Should generate a set_bulk message properly with one key/value pair" do
    msg = EM::Tycoon::Protocol::Message.generate(:set, @single_set_hsh)
    msg.should be_instance_of(EM::Tycoon::Protocol::Binary::SetMessage)
    msg.data.should == @single_set_packed
  end

  it "Should generate a set_bulk message properly with multiple key/value pairs" do
    msg = EM::Tycoon::Protocol::Message.generate(:set, @multiple_set_hsh)
    msg.should be_instance_of(EM::Tycoon::Protocol::Binary::SetMessage)
    msg.data.should == @multiple_set_packed
  end

  
  it "Should parse a set_bulk reply properly" do
  end
  
  it "Should generate a get_bulk message properly with one key" do
    msg = EM::Tycoon::Protocol::Message.generate(:get, "mykey")
    msg.should be_instance_of(EM::Tycoon::Protocol::Binary::GetMessage)
    msg.data.should == @single_get_packed
  end

  it "Should generate a get_bulk message properly with multiple keys" do
    msg = EM::Tycoon::Protocol::Message.generate(:get, ["mykey1","mykey2","mykey3"])
    msg.should be_instance_of(EM::Tycoon::Protocol::Binary::GetMessage)
    msg.data.should == @multiple_get_packed
  end

  
  it "Should parse a get_bulk reply properly" do
  end
  
  it "Should parse an error reply properly" do
  end
  
end