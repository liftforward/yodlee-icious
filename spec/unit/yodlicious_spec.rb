require "yodlicious"

describe Yodlicious::YodleeApi do
  let(:config) { { 'base_url' => "https://rest.developer.yodlee.com/services/srest/restserver/v1.0",
                   'username' => "sbCobandrewnichols",
                   'password' => "d02aeac7-0ead-432e-a187-f8ff8a24e0cd" } }

  context 'creating a new YodleeApi instance with a config' do
    let(:api) { Yodlicious::YodleeApi.new(config) }

    it 'allows for the provided config' do
      expect(api).not_to be_nil
      expect(api.base_url).to eq(config['base_url'])
      expect(api.username).to eq(config['username'])
      expect(api.password).to eq(config['password'])
    end
  end

end