require "yodleeicious"

shared_examples 'sets_the_requests' do
  it 'sets the response data' do
    expect(subject.response).not_to be_nil
  end

  it 'sets the request_url' do
    expect(subject.request_url).not_to be_nil
  end

  it 'sets payload' do
    expect(subject.payload).not_to be_nil
  end

  it 'sets the status code' do
    expect(subject.status).not_to be_nil
  end
end


describe Yodleeicious::Response do
  let (:mock_env) { double("env", url: "http://example.com") }
  let (:response) { double("Response", body: response_json, env: mock_env, status: 200 ) }

  subject { Yodleeicious::Response.new response, { key: "val" } }

  context 'When the error_response is the errorOccured syntax' do
    let(:response_json) {
      {
        "errorOccurred"=>"true",
        "exceptionType"=>"com.yodlee.core.IllegalArgumentValueException",
        "referenceCode"=>"_3932d208-345a-400f-a273-83619b8b548b",
        "message"=>"Multiple exceptions encapsulated within: invoke getWrappedExceptions for details"
      }.to_json
    }

    include_examples "sets_the_requests"
    it { is_expected.not_to be_success }
    it { is_expected.to be_fail }
    it "is expected to return error of InvalidArgumentValueException" do
      expect(subject.error).to eq('com.yodlee.core.IllegalArgumentValueException')
    end
  end

  context 'When the error_response is the Error : ["errorDetail"] syntax' do
    let(:response_json) { { "Error" => [ {"errorDetail" => "Invalid User Credentials"} ] }.to_json }
    let (:mock_env) { double("env", url: "http://example.com") }
    let (:response) { double("Response", body: response_json, env: mock_env, status: 200 ) }

    subject { Yodleeicious::Response.new response, { key: "val" } }

    include_examples "sets_the_requests"
    it { is_expected.not_to be_success }
    it { is_expected.to be_fail }
    it "is expected to return error of Invalid User Credentials" do
      expect(subject.error).to eq('Invalid User Credentials')
    end
  end

  context 'When operation is a success and returns hash' do
    let(:response_json) { {}.to_json }

    subject { Yodleeicious::Response.new response, { key: "val" } }

    include_examples "sets_the_requests"
    it { is_expected.to be_success }
    it { is_expected.not_to be_fail }
    it 'is expected to return nil for error' do
      expect(subject.error).to be_nil
    end
  end

  context 'When operation is a success and return array' do
    let(:response_json) { [{}].to_json }

    subject { Yodleeicious::Response.new response, { key: "val" } }

    include_examples "sets_the_requests"
    it { is_expected.to be_success }
    it { is_expected.not_to be_fail }
    it 'is expected to return nil for error' do
      expect(subject.error).to be_nil
    end
  end

end
