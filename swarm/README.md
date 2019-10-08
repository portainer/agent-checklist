docker build -t portainer/swarminfo -f Dockerfile .

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock portainer/swarminfo:latest
