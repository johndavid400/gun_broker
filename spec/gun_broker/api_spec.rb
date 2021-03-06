require 'spec_helper'

describe GunBroker::API do

  let(:token) { 'test-user-access-token' }

  let(:path)     { '/some/resource' }
  let(:endpoint) { [GunBroker::API::ROOT_URL, path].join }

  let(:test_response) { JSON.parse(response_fixture('test')) }

  before(:all) do
    GunBroker.dev_key = 'test-dev-key'
    GunBroker.timeout = 1
  end

  it 'has a ROOT_URL constant' do
    expect(GunBroker::API::ROOT_URL).not_to be_nil
  end

  it "raises GunBroker::Error if path does not start with '/'" do
    expect { GunBroker::API.new('foo/bar') }.to raise_error(GunBroker::Error)
  end

  context 'response' do
    it 'should return an instance of GunBroker::Response' do
      stub_request(:get, endpoint)
        .to_return(body: response_fixture('test'))

      response = GunBroker::API.get(path)
      expect(response).to be_a(GunBroker::Response)
    end
  end

  context '.delete' do
    context 'on success' do
      it 'returns JSON parsed response' do
        stub_request(:delete, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('test'))

        response = GunBroker::API.delete(path, {}, headers('X-AccessToken' => token))
        expect(response['test']).to eq(test_response['test'])
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:delete, endpoint)
          .with(headers: headers('X-AccessToken' => token))
          .to_return(body: response_fixture('empty'), status: 500)

        api = GunBroker::API.new(path, {}, headers('X-AccessToken' => token))
        expect { api.delete! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  context '.get' do
    context 'on success' do
      it 'returns JSON parsed response' do
        stub_request(:get, endpoint)
          .with(query: { 'SellerName' => 'test-user' })
          .to_return(body: response_fixture('test'))

        response = GunBroker::API.get(path, { 'SellerName' => 'test-user' })
        expect(response['test']).to eq(test_response['test'])
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:get, endpoint)
          .to_return(body: response_fixture('empty'), status: 500)

        api = GunBroker::API.new(path)
        expect { api.get! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  context '.post' do
    context 'on success' do
      it 'returns JSON parsed response' do
        stub_request(:post, endpoint)
          .with(
            headers: headers,
            body: { username: 'test-user' }
          )
          .to_return(body: response_fixture('test'))

        response = GunBroker::API.post(path, { username: 'test-user' }, headers)

        expect(response).to be_a(GunBroker::Response)
        expect(response['test']).to eq(test_response['test'])
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:post, endpoint)
          .to_return(body: response_fixture('empty'), status: 500)

        api = GunBroker::API.new(path)
        expect { api.post! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  context '.multipart_post' do
    context 'on success' do
      it 'returns JSON parsed response' do
        stub_request(:post, endpoint).to_return(body: response_fixture('test'))

        response = GunBroker::API.multipart_post(path, { username: 'test-user' })

        expect(response).to be_a(GunBroker::Response)
        expect(response['test']).to eq(test_response['test'])
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:post, endpoint)
          .to_return(body: response_fixture('empty'), status: 500)

        api = GunBroker::API.new(path)
        expect { api.multipart_post! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  context '.put' do
    context 'on success' do
      it 'returns JSON parsed response' do
        stub_request(:put, endpoint)
          .with(
            headers: headers,
            body: { username: 'test-user' }
          )
          .to_return(body: response_fixture('test'))

        response = GunBroker::API.put(path, { username: 'test-user' }, headers)

        expect(response).to be_a(GunBroker::Response)
        expect(response['test']).to eq(test_response['test'])
      end
    end

    context 'on failure' do
      it 'raises an exception' do
        stub_request(:put, endpoint)
          .to_return(body: response_fixture('empty'), status: 500)

        api = GunBroker::API.new(path)
        expect { api.put! }.to raise_error(GunBroker::Error::RequestError)
      end
    end
  end

  it 'uses ROOT_URL_SANDBOX if GunBroker.sandbox_mode is true' do
    expect(GunBroker).to receive(:sandbox).and_return(true)
    api = GunBroker::API.new(path)
    expect(api.instance_variable_get(:@base_api_url)).to eq(GunBroker::API::ROOT_URL_SANDBOX)
  end

end
