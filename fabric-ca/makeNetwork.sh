#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

#
# This script builds the Network yaml.
#

SDIR=$(dirname "$0")
source $SDIR/scripts/env.sh

function main {
   {
   initOrgArrays  
   writeHeader
   writeChannel
   writeOrgs
   writeOrderers
   writePeers
   writeCertAuth 
   } > $SDIR/network.yaml
   log "network.yaml"
}

function writeChannel {
  echo "channels:"
  echo "  $CHANNEL_NAME:"
  echo "    orderers:"
     for ORG in $ORDERER_ORGS; do
      COUNT=1
      while [[ "$COUNT" -le $NUM_ORDERERS ]]; do
         initOrdererVars $ORG $COUNT
         echo "      - $ORDERER_NAME"
         COUNT=$((COUNT+1))
      done
   done  
  echo "    peers:"
     for ORG in $PEER_ORGS; do
      COUNT=1
      initOrgVars $ORG
      while [[ "$COUNT" -le $NUM_PEERS ]]; do
         initPeerVars $ORG $COUNT
         echo "      $PEER_NAME:
        endorsingPeer: true
        chaincodeQuery: true
        ledgerQuery: true
        eventSource: true"
         COUNT=$((COUNT+1))
      done
   done
  echo "    chaincodes:"
  echo "      - dbi:v1.0.0"
  echo "      - poe:v1.0.0"   
}

function writeOrgs {
  echo ""
  echo "organizations:"
     for ORG in $PEER_ORGS; do
      initOrgVars $ORG
      COUNT=1
      echo "  $ORG:"
      echo "    mspid: $ORG_MSP_ID"
      echo ""
      echo "    peers:"
      while [[ "$COUNT" -le $NUM_PEERS ]]; do
        initPeerVars $ORG $COUNT
        echo "       - $PEER_NAME"
        COUNT=$((COUNT+1))
      done
      echo "    certificateAuthorities:"
      echo "      - $INT_CA_HOST"
      echo "    adminPrivateKey:"
# FIXED THIS PATH!!!!!!!!!!!!!!!!!!
      PRIV_KEY=$(basename `ls data/orgs/$ORG/admin/msp/keystore/*_sk`)
      echo "      path: data/orgs/$ORG/admin/msp/keystore/$PRIV_KEY"
      echo "    signedCert:"
      echo "      path: data/orgs/$ORG/admin/msp/signcerts/cert.pem"
    done
}


function writeOrderers {
  echo ""
  echo "orderers:"
    for ORG in $ORDERER_ORGS; do
      COUNT=1
      while [[ "$COUNT" -le $NUM_ORDERERS ]]; do
         initOrdererVars $ORG $COUNT
      echo "  $ORDERER_NAME:"
# NEED TO HAVE MORE PORTS FOR MULTIPLE ORDERERS!!!!!!!!!!!!!!!!!!!!!!!!
      echo "    url: grpcs://localhost:60$ORG_INDEX$COUNT"   
      echo "    grpcOptions:"
      echo "      ssl-target-name-override: $ORDERER_NAME"
      echo "      grpc-max-send-message-length: 15"
      echo "    tlsCACerts:"
      echo "      path: data/$ORG-ca-chain.pem"
      COUNT=$((COUNT+1))
      done
   done  
}

function writePeers {
  echo""
  echo "peers:"
     for ORG in $PEER_ORGS; do
      initOrgVars $ORG
      COUNT=1
      while [[ "$COUNT" -le $NUM_PEERS ]]; do
         initPeerVars $ORG $COUNT
         echo "  $PEER_NAME:"
         echo "    url: grpcs://localhost:80$ORG_INDEX$COUNT"
         echo "    eventUrl: grpcs://localhost:90$ORG_INDEX$COUNT"
         echo "    grpcOptions:"
         echo "      ssl-target-name-override: $PEER_NAME"
         echo "      grpc.http2.keepalive_time: 15"
         echo "    tlsCACerts:"
         echo "      path: data/$ORG-ca-chain.pem"
         COUNT=$((COUNT+1))
       done
     done  
}

function writeCertAuth {
  echo ""
  echo "certificateAuthorities:"
  for ORG in $PEER_ORGS; do
    initOrgVars $ORG
    echo "  $ROOT_CA_INT_USER:"
    # NEED TO HAVE MORE PORTS FOR MULTIPLE PEER ORGS!!!!!!!!!!!!!!!!!!!!!!!!
    echo "    url: https://localhost:81${ORG_INDEX}4"
    echo "    httpOptions:"
    echo "      verify: false"
    echo "    tlsCACerts:"
    echo "      path: data/orgs/$ORG/msp/tlscacerts/tls-ica-$ORG-7054.pem"
    echo "    registrar:"
    echo "      - enrollId: $INT_CA_ADMIN_USER"
    echo "        enrollSecret: $INT_CA_ADMIN_PASS"
  done
}

function writeHeader {
   echo "---
name: \"solo\"
x-type: \"hlfv1\"
description: \"Simple network consisting of one organization.\"
version: \"1.0\"

"
}

main
