source 'https://supermarket.chef.io'

source 'https://supermarket.chef.io'

def dependencies(path)
  berks = "#{path}/Berksfile.in"
  instance_eval(File.read(berks)) if File.exist?(berks)
end

Dir.glob('./cookbooks/*').each do |path|
  dependencies path
  cookbook File.basename(path), path: path
end
