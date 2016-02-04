# brocade-puppet
Puppet modules for Brocade NOS
# netdev_stdlib_nos

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What nos_netdev affects](#what-netdev_stdlib_nos-affects)
    * [Beginning with netdev_stdlib_nos](#beginning-with-netdev_stdlib_nos)
4. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This puppet module is derived from Netdev Standard library and modified in a way to configure Brocade NOS switches (Brocade VDX platform),

## Module Description

Brocade VDX switches running NOS firmware can be configured using this Puppet module. This module supports basic interface, L2 port configuration, LAG and VLAN configurations.  This module has been derived from Netdev_stdlib with a modification required to configure the VDX switches. This module requires NOS versions 6.0.1 or later. 


## Setup

### What netdev_stdlib_nos affects

These providers and types can be used to configure the basic network properties of NOS switches.

### Beginning with netdev_stdlib_nos

Puppet agent is not packaged with NOS software hence user is requested to install the puppet master and agent on a separate server. Agent nodes must have connectivity to both the Puppet Master and Brocade VDX switches.

### Reference

Refer Brocade Puppet user guide

### Limitations

Puppet Enterprise 3.7 +
NOS 6.0.1 or later
