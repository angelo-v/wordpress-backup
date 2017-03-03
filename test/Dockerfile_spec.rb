
require "serverspec"
require "docker"

describe "Dockerfile" do
  before(:all) do
    @image = Docker::Image.build_from_dir('../src')

    @container = Docker::Container.create(
      'Image' => @image.id,
      'Name' => '/wordpress-backup-test',
      'Env' => [
        'MYSQL_ENV_MYSQL_USER=test_user',
        'MYSQL_ENV_MYSQL_DATABASE=test_db',
        'MYSQL_ENV_MYSQL_PASSWORD=test_password',
        'CLEANUP_OLDER_THAN=300'
      ]
    )
    @container.start
    set :docker_container, @container.id

    set :os, family: :debian
    set :backend, :docker
    set :docker_container, @container.id
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

  describe command('env') do
   its(:stdout) { should match /MYSQL_ENV_MYSQL_USER=test_user/ }
   its(:stdout) { should match /MYSQL_ENV_MYSQL_DATABASE=test_db/ }
   its(:stdout) { should match /MYSQL_ENV_MYSQL_PASSWORD=test_password/ }
   its(:stdout) { should match /CLEANUP_OLDER_THAN=300/ }
   its(:stdout) { should match /BACKUP_TIME=0 3 \* \* \*/ }
  end

  it "contains cron file" do
    expect(file('/backup-cron')).to be_file
  end

  describe command('crontab -l') do
   its(:stdout) { should eq %(MYSQL_ENV_MYSQL_USER=test_user
MYSQL_ENV_MYSQL_DATABASE=test_db
MYSQL_ENV_MYSQL_PASSWORD=test_password
CLEANUP_OLDER_THAN=300
0 3 * * * backup > /backup.log
) }
  end

end
