import docker
import pytest

testinfra_hosts = ['docker://test_container']

@pytest.fixture(scope="module", autouse=True)
def container(client, image):
    container = client.containers.run(image.id, name="test_container", detach=True)
    yield container
    container.remove(force=True)

def test_scripts_exist(host):
    assert host.file("/bin/backup").is_file
    assert host.file("/bin/restore").is_file

def test_installed_packages(host):
    assert host.package("cron").is_installed
    assert host.package("bzip2").is_installed
    assert host.package("mysql-client").is_installed
