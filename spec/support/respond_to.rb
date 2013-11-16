def should_respond_to(method)
  respond_to = respond_to? method
  it "have access to the method #{method}" do
    expect(respond_to).to be_true
  end
end

def should_not_respond_to(method)
  respond_to = respond_to? method
  it "do not have access to the method #{method}" do
    expect(respond_to).to be_false
  end
end

def should_authorize_with(authorization)
  it { expect(example.metadata[:authorize_with]).to eq authorization }
end

def should_have_host(host)
  it { expect(example.metadata[:host]).to eq host }
end

def should_have_attributes(attributes)
  it { expect(example.metadata[:attributes]).to eq attributes }
end
