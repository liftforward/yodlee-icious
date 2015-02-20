require "yodlicious"

describe Yodlicious::Response do
  let(:error_response_1) {
    { 
      "errorOccurred"=>"true", 
      "exceptionType"=>"com.yodlee.core.IllegalArgumentValueException", 
      "referenceCode"=>"_3932d208-345a-400f-a273-83619b8b548b", 
      "message"=>"Multiple exceptions encapsulated within: invoke getWrappedExceptions for details"
    }
  }

  let(:error_response_2) {
    { "Error" => [ {"errorDetail" => "Invalid User Credentials"} ] }
  }

  let(:success_hash_response) {
    {}
  }

  let(:success_array_response) {
    [{}]
  }

  context 'When the error_response is the errorOccured syntax' do
    subject { Yodlicious::Response.new error_response_1 }
    it { is_expected.not_to be_success }
    it { is_expected.to be_fail }
    it "is expected to return error of InvalidArgumentValueException" do
      expect(subject.error).to eq('com.yodlee.core.IllegalArgumentValueException')
    end
  end

  context 'When the error_response is the Error : ["errorDetail"] syntax' do
    subject { Yodlicious::Response.new error_response_2 }
    it { is_expected.not_to be_success }
    it { is_expected.to be_fail }
    it "is expected to return error of Invalid User Credentials" do
      expect(subject.error).to eq('Invalid User Credentials')
    end
  end

  context 'When operation is a success and returns hash' do
    subject { Yodlicious::Response.new success_hash_response }
    it { is_expected.to be_success }
    it { is_expected.not_to be_fail }
    it 'is expected to return nil for error' do
      expect(subject.error).to be_nil
    end
  end

  context 'When operation is a success and return array' do
    subject { Yodlicious::Response.new success_array_response }
    it { is_expected.to be_success }
    it { is_expected.not_to be_fail }
    it 'is expected to return nil for error' do
      expect(subject.error).to be_nil
    end
  end

end
