import docker
import pytest

@pytest.fixture(scope="session")
def client():
    return docker.from_env()

@pytest.fixture(scope="session")
def image(client):
    return client.images.build(path='./src')
