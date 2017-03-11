import docker
import pytest

testinfra_hosts = ['test_container']

@pytest.fixture(scope="module", autouse=True)
def container(client, image):
    container = client.containers.run(image.id, name="test_container", detach=True)
    yield container
    container.remove(force=True)

def test_scripts_exist(File):
    assert File("/bin/backup").is_file
    assert File("/bin/restore").is_file

def test_installed_packages(Package):
    assert Package("cron").is_installed
    assert Package("bzip2").is_installed
    assert Package("mysql-client").is_installed
