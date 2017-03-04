
require "serverspec"
require "docker"

describe "container with minimal and default settings" do
  before(:all) do
    @image = Docker::Image.build_from_dir('../src')

    @container = Docker::Container.create(
      'name' => 'my-new-container',
      'Image' => @image.id,
      'Env' => [
        'MYSQL_ENV_MYSQL_USER=test_user',
        'MYSQL_ENV_MYSQL_DATABASE=test_db',
        'MYSQL_ENV_MYSQL_PASSWORD=test_password'
      ]
    )
    @container.start

    set :os, family: :debian
    set :backend, :docker
    set :docker_container, @container.id
  end

  describe command('env') do
   its(:stdout) { should match /MYSQL_ENV_MYSQL_USER=test_user/ }
   its(:stdout) { should match /MYSQL_ENV_MYSQL_DATABASE=test_db/ }
   its(:stdout) { should match /MYSQL_ENV_MYSQL_PASSWORD=test_password/ }
   its(:stdout) { should match /BACKUP_TIME=0 3 \* \* \*/ }
  end

  describe command('crontab -l') do
   its(:stdout) { should eq %(MYSQL_ENV_MYSQL_USER=test_user
MYSQL_ENV_MYSQL_DATABASE=test_db
MYSQL_ENV_MYSQL_PASSWORD=test_password
0 3 * * * backup > /backup.log
) }
  end

  after(:all) do
    @container.kill
    @container.delete(:force => true)
  end

end
