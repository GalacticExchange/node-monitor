# Test gexcloud servers in Docker

# Prepare tests

* run docker container from which to test
* see gexcloud-docker/readme_tests.md


## Dockerhub

```
gex_env=main rake serverspec:swarm_host_dockerhub
```


## Test host with swarm manager

```
gex_env=main rake serverspec:swarm_host_swarm
```

* services - general
```
gex_env=main rake serverspec:swarm_host_services
```

# Services

* test from test-tc container


## redis

```
gex_env=main rake serverspec:gexcloud_docker_redis
```
