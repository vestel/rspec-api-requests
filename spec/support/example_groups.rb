RSpec::Matchers.define :pass do
  match do |example_group|
    # TODO: find a recursive way
    example_group.run
    examples = example_group.examples + example_group.children.map(&:examples).flatten
    examples.all?{|e| e.execution_result[:status] == 'passed'}
  end
end

RSpec::Matchers.define :be_pending_with do |message|
  match do |example_group|
    example_group.run
    examples = example_group.examples + example_group.children.map(&:examples).flatten
    examples.all?{|e| e.pending? && e.execution_result[:pending_message].match(message)}
  end
end

RSpec::Matchers.define :be_pending do |message|
  match do |example_group|
    example_group.run
    examples = example_group.examples + example_group.children.map(&:examples).flatten
    examples.all?{|e| e.pending?}
  end
end
