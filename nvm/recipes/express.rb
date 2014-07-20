Encoding.default_external = Encoding::UTF_8

%w{ express express-generator}.each do |npm|
  npm_package npm do
    action :install
  end
end
