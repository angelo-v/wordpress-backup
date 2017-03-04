
require "serverspec"
require "docker"

describe "docker image" do
  before(:all) do
    @image = Docker::Image.build_from_dir('../src')

    set :os, family: :debian
    set :backend, :docker
    set :docker_image, @image.id
  end

  it "installs required packages" do
    expect(package("mysql-client")).to be_installed
    expect(package("cron")).to be_installed
    expect(package("bzip2")).to be_installed
  end

  it "contains the backup and restore commands" do
    expect(file('/bin/backup')).to be_file
    expect(file('/bin/restore')).to be_file
  end

end
