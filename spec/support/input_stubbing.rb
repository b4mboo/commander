def expect_user_input(input)
  expect(subject).to receive(:get_user_input).and_return(input)
end
