#!/usr/bin/env bash

set -e

#export  IPMONITOR_APP_TAG="${IPMONITOR_APP_TAG:-latest}"
##export SENTRY_DSN="${SENTRY_DSN:-'https://public@sentry.example.com/1'}"
#
#IPMONITOR_SECRET=$(head -c 28 /dev/urandom | sha224sum -b | head -c 56)
#export IPMONITOR_SECRET
#
## Talk to the user
#echo "Welcome to the single instance IPMonitor installer"
#echo ""
#echo "You need at leasr 4Gb RAM to run this stack"
#echo ""
#echo "Power user or aspiring power user?"
#echo "Check out our docs on deploying IPMonitor! https://linkhere/"
#echo ""
#
#
##Download specified release or use latest
#if ! [ -z "$1" ]
#then
#export IPMONITOR_APP_TAG=$1
#else
#echo "What version of IPMonitor would you like to install? (We default to 'latest')"
#echo "You can check out available versions here: https://hub.docker.com/r/ipmonitor/ipmonitor-app/tags"
#read -r IPMONITOR_APP_TAG_READ
#if [ -z "$IPMONITOR_APP_TAG_READ" ]
#then
#    echo "Using default and installing $IPMONITOR_APP_TAG"
#else
#    export IPMONITOR_APP_TAG=$IPMONITOR_APP_TAG_READ
#    echo "Using provided tag: $IPMONITOR_APP_TAG"
#fi
#fi
#echo ""
#
#
###Read domain name from user, which user  set for instance and start certificate installation for this domain
##if ! [ -z "$2" ]
##then
##export DOMAIN=$2
##else
##echo "Let's get the exact domain IPMonitor will be installed on"
##echo "Make sure that you have a Host A DNS record pointing to this instance!"
##echo "This will be used for TLS 🔐"
##echo "ie: test.IPMONITOR.net (NOT an IP address)"
##read -r DOMAIN
##export DOMAIN=$DOMAIN
##
##
##
##
##fi
##echo "Ok we'll set up certs for https://$DOMAIN"
##echo ""
##echo "We will need sudo access so the next question is for you to give us superuser access"
##echo "Please enter your sudo password now:"
##sudo echo ""
##echo "Thanks! 🙏"
##echo ""
##echo "Ok! We'll take it from here 🚀"
##
##echo "Making sure any stack that might exist is stopped"
##sudo -E docker compose -f docker-compose.yml stop &> /dev/null || true

echo "Preparing working dir"

echo "Update apt cache and install tools:"
sudo apt update
sudo apt install make git -y

sudo git clone git@github.com:givqer/ipmonitor-install.git /opt/ipmonitor
sudo chown $(id -u):$(id -g) /opt/ipmonitor
cd /opt/ipmonitor
cp .env.install .env
sudo make dc-init-app


