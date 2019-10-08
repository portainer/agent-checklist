#!/usr/bin/env bash

# Requires:
# curl
# jq

### COLOR OUTPUT ###

ESeq="\x1b["
RCol="$ESeq"'0m'    # Text Reset

# Regular               Bold                    Underline               High Intensity          BoldHigh Intens         Background              High Intensity Backgrounds
Bla="$ESeq"'0;30m';     BBla="$ESeq"'1;30m';    UBla="$ESeq"'4;30m';    IBla="$ESeq"'0;90m';    BIBla="$ESeq"'1;90m';   On_Bla="$ESeq"'40m';    On_IBla="$ESeq"'0;100m';
Red="$ESeq"'0;31m';     BRed="$ESeq"'1;31m';    URed="$ESeq"'4;31m';    IRed="$ESeq"'0;91m';    BIRed="$ESeq"'1;91m';   On_Red="$ESeq"'41m';    On_IRed="$ESeq"'0;101m';
Gre="$ESeq"'0;32m';     BGre="$ESeq"'1;32m';    UGre="$ESeq"'4;32m';    IGre="$ESeq"'0;92m';    BIGre="$ESeq"'1;92m';   On_Gre="$ESeq"'42m';    On_IGre="$ESeq"'0;102m';
Yel="$ESeq"'0;33m';     BYel="$ESeq"'1;33m';    UYel="$ESeq"'4;33m';    IYel="$ESeq"'0;93m';    BIYel="$ESeq"'1;93m';   On_Yel="$ESeq"'43m';    On_IYel="$ESeq"'0;103m';
Blu="$ESeq"'0;34m';     BBlu="$ESeq"'1;34m';    UBlu="$ESeq"'4;34m';    IBlu="$ESeq"'0;94m';    BIBlu="$ESeq"'1;94m';   On_Blu="$ESeq"'44m';    On_IBlu="$ESeq"'0;104m';
Pur="$ESeq"'0;35m';     BPur="$ESeq"'1;35m';    UPur="$ESeq"'4;35m';    IPur="$ESeq"'0;95m';    BIPur="$ESeq"'1;95m';   On_Pur="$ESeq"'45m';    On_IPur="$ESeq"'0;105m';
Cya="$ESeq"'0;36m';     BCya="$ESeq"'1;36m';    UCya="$ESeq"'4;36m';    ICya="$ESeq"'0;96m';    BICya="$ESeq"'1;96m';   On_Cya="$ESeq"'46m';    On_ICya="$ESeq"'0;106m';
Whi="$ESeq"'0;37m';     BWhi="$ESeq"'1;37m';    UWhi="$ESeq"'4;37m';    IWhi="$ESeq"'0;97m';    BIWhi="$ESeq"'1;97m';   On_Whi="$ESeq"'47m';    On_IWhi="$ESeq"'0;107m';

printSection() {
  echo -e "${BIYel}>>>> ${BIWhi}${1}${RCol}"
}

info() {
  echo -e "${BIWhi}${1}${RCol}"
}

success() {
  echo -e "${BIGre}${1}${RCol}"
}

error() {
  echo -e "${BIRed}${1}${RCol}"
}

### !COLOR OUTPUT ###

### PORT CHECKING ###

test_tcp_port() {
  ip_addr=$1
  port=$2

  nc -z -v -w 1 "${ip_addr}" "${port}"

  retVal=$?
  if [ $retVal -ne 0 ]; then
    error "Connection to port ${port} over TCP: failure"
  else
    success "Connection to port ${port} over TCP: success"
  fi
}

test_udp_port() {
  ip_addr=$1
  port=$2

  nc -u -z -v -w 1 "${ip_addr}" "${port}"

  retVal=$?
  if [ $retVal -ne 0 ]; then
    error "Connection to port ${port} over UDP: failure"
  else
    success "Connection to port ${port} over UDP: success"
  fi
}

check_worker_ports() {
  ip_addr=$1
  test_tcp_port "${ip_addr}" "7946"
  test_udp_port "${ip_addr}" "7946"
  test_udp_port "${ip_addr}" "4789"
}

check_manager_ports() {
  ip_addr=$1
  test_tcp_port "${ip_addr}" "2377"
  check_worker_ports "${ip_addr}"
}

check_ports() {
  nodes_info=$1

  echo "${nodes_info}" | jq -rc '.hostname + " " + .addr + " " + .role' | while IFS=' ' read -r hostname addr role; do
    info "Node: ${hostname} (${addr})"
    if [ "${role}" == "manager" ]; then
      check_manager_ports "${addr}"
    else
      check_worker_ports "${addr}"
    fi
  done
}

### !PORT CHECKING ###

### CLUSTER INFO ###

cluster_info() {
  nodes_info=$1

  echo "${nodes_info}" | jq -rc '.hostname + " " + .addr + " " + .role + " " + .version' | while IFS=' ' read -r hostname addr role version; do
    info "Node: ${hostname}"
    echo "Role: ${role}"
    echo "IP Address: ${addr}"
    echo "Docker version: ${version}"
  done
}

### !CLUSTER INFO ###

main() {
  nodes_info=`curl -s --unix-socket /var/run/docker.sock http://localhost/nodes | jq '.[] | {hostname: .Description.Hostname, addr: .Status.Addr, role: .Spec.Role, version: .Description.Engine.EngineVersion}'`

  printSection "Cluster details"
  cluster_info "${nodes_info}"

  printSection "Checking nodes ports"
  check_ports "${nodes_info}"

  exit 0
}


main
