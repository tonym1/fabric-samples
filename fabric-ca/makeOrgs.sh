#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

#
# This script builds the org yaml files.
#

SDIR=$(dirname "$0")
source $SDIR/scripts/env.sh

function main {
   initOrgArrays
   for ORG in $PEER_ORGS; do
       initOrgVars $ORG
       createYaml
   done
}

function createYaml {
    {
        writeHeader
        writeOrg
    } > $SDIR/$ORG.yaml
   log "$ORG.yaml"
}

function writeHeader {
   echo "---
name: \"solo\"
type: \"hl-fabric@^1.0.0\"
description: \"Simple network consisting of one organization.\"
version: 1.0.0

"
}

function writeOrg {
echo "client:"

echo "  organization: $ORG"

echo "  connection:"
echo "    timeout:"
echo "      peer:"
echo "        endorser: 120"
echo "        eventHub: 60"
echo "        eventReg: 3"
echo "      orderer: 30"

echo "  credentialStore:"
echo "    path: \"./tmp/keyValStore_v1/$ORG\""
echo "    cryptoStore:"
echo "      path: \"./tmp/keyValStore_v1/$ORG/keys\""
echo "    wallet: wallet-name"
}

main