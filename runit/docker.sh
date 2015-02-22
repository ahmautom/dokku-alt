#!/bin/bash
cgroups-mount; exec docker -d >> /var/log/docker.log 2>&1
