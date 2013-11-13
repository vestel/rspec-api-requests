RSpec::Matchers.define :pass do
  match do |example_group|
    example_group.run
    example_group.examples.all?{|e| e.execution_result[:status] == 'passed'}
  end
end