def expect_user_input(input_string)
  expect(subject).to receive(:get_user_input).and_return(input_string)
end
