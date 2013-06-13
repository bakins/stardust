Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.omnibus.chef_version = :latest
  config.vm.provision :chef_apply, :path => "provision.rb"
  config.vm.provision :shell, :inline => <<-PROVE
    cd /vagrant
    su vagrant -c prove
  PROVE
end
