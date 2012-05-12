guard 'minitest' do
  # with Minitest::Unit
  watch(%r|^test/(.*)\/?(.*)_test\.rb|)
  watch(%r|^lib/masq.*\.rb|)                { "test" }
  watch(%r|^test/test_helper\.rb|)          { "test" }

  # Rails
  watch(%r|^app/controllers/(.*)/application_controller\.rb|) { |m| "test/functional" }
  watch(%r|^app/controllers/(.*)/(.*)\.rb|) { |m| "test/functional/#{m[1]}/#{m[2]}_test.rb" }
  watch(%r|^app/helpers/(.*)/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}/#{m[2]}_test.rb" }
  watch(%r|^app/models/(.*)/(.*)\.rb|)      { |m| "test/unit/#{m[1]}/#{m[2]}_test.rb" }
  watch(%r|^app/mailers/(.*)/(.*)\.rb|)     { |m| "test/unit/#{m[1]}/#{m[2]}_test.rb" }
  watch(%r|^app/views/(.*)/(.*)|)           { |m| "test/integration" }
  watch(%r|^config/routes\.rb|)             { |m| "test/integration" }
end
