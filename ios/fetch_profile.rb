require 'fastlane'

begin
  key = Fastlane::Actions::AppStoreConnectApiKeyAction.run(
    key_id: "98RV2Q9AF2",
    issuer_id: "bbcee470-032e-40c8-87fd-9c64a4abded8",
    key_filepath: "/Users/xy/.private_keys/AuthKey_98RV2Q9AF2.p8",
    in_house: false
  )

  result = Fastlane::Actions::SighAction.run(
    api_key: key,
    app_identifier: "com.youaiyj.girl",
    development: true,
    force: true,
    readonly: false
  )
  puts "Sigh result: #{result}"
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace
end
