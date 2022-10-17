# dependencys for the Codedeploy agent
package 'ruby'
package 'gdebi-core'

remote_file '/tmp/codedeploy-installer' do
  source 'https://aws-codedeploy-eu-central-1.s3.amazonaws.com/latest/install'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'install-coddeploy' do
  command '/tmp/codedeploy-installer auto'
  action :run
end

replace_or_add "keep less codedeploy revisions" do
  path "/etc/codedeploy-agent/conf/codedeployagent.yml"
  pattern ":max_revisions:.*"
  line ":max_revisions: 1"
end

service 'codedeploy-agent' do
  action [:start, :enable]
end
