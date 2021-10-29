#!/bin/bash

echo "********************** trying to config firewall for node with IP $1"
ufw allow from $1 