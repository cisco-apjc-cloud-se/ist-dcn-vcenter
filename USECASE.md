# Integrated DC Network, Infrastructure & Security Automation - Part 1

## Overview
When deploying applications to a data center, there are certain elements of common configuration that would be used differently by different operational teams.  Traditionally, each team would rely on this information being passed manually in ad-hoc manner.   In a modern Infrastructure-as-Code (IaC) approach, this configuration can be defined once but leveraged consistently across multiple domains such as networking, infrastructure and security automatically.
In this example, we are using a single Terraform plan to deploy a set of new DC networks, clone and configure virtual machines to use these networks and then create matching firewall objects and rules – all from the same simplified intent defined as a minimal set of variables.
Finally, we will use the Intersight Service for Terraform to provide Terraform Cloud with secure managed API access to traditionally isolated domain managers within the on-premises data center.  This will allow Terraform to reach both public and private infrastructure equally and build a consistent hybrid cloud infrastructure operating model.

## Requirements
The Infrastructure-as-Code environment will require the following:
* GitHub Repository for Terraform plans, modules and variables as JSON files
* Terraform Cloud for Business account with a workspace associated to the GitHub repository above
* Cisco Intersight (SaaS) platform account with sufficient Advantage licensing
* An Intersight Assist appliance VM connected to the Intersight account above

This example will then use the following on-premise domain managers. These will need to be fully commissioned and a suitable user account provided for Terraform to use for provisioning.
* Cisco Data Center Network Manager (DCNM)
* VMware vCenter
* Cisco Firepower Management Center (FMC)

**Note:** The FMC security automation component has been moved to a 2nd GitHub repository and will now be run from a 2nd, linked Terraform workspace. This was required to allow the vCenter component to clone any number (count) of VMs.  This prevented the FMC module from predicting the number of resources required until after the vCenter module has been executed.  Instead the FMC component is now run from a 2nd linked workspace.  Any updates to the main DCNM/vCenter workplace will trigger the FMC workplace to run and update as necessary.

![Overview](/images/overview.png)

The DC Networking module makes the following assumptions:
* An existing Nexus 9000 switch based VXLAN fabric has already been deployed and that it is actively managed through a DCNM instance.
* The DCNM server is accessible by HTTPS from the Intersight Assist VM.
* An existing VRF is available to use for new L3 VXLAN networks.  Any dynamic routing/peering to external devices (including firewalls) have already be configured as necessary.
* In this example, the firewalls will be used as an external edge device and all necessary static or dynamic routing is already present (i.e., BGP used to learn a default route from the firewall and to advertise L3 network subnets back to the firewall).   Alternatively, the firewall could be used in conjunction with policy-based redirect (PBR) or elastic service redirection (ESR) configuration.
* Suitable IP subnets (at least /29) are available to be assigned to each new L3 network.
* Suitable VLAN IDs are available to be assigned to each new L3 network.
* The following variables are defined within the Terraform Workspace.  These variables should not be configured within the public GitHub repository files.
  * DCNM account username (dcnm_user)
  * DCNM account password (dcnm_password)
  *	DCNM URL (dcnm_url)

The vCenter module makes the following assumptions:
* A group of VMware host servers are configured as a single VMware server cluster within a logical VMware Data Center, managed from an existing vCenter instance.  
* The vCenter server is accessible by HTTPS from the Intersight Assist VM.
* VMware host servers have commissioned and are physically patched to trunked switch ports (or VPCs) on the VXLAN fabric access (leaf) switches.
* A distributed virtual switch (DVS) has been configured across all servers in the cluster and their physical ethernet uplink ports.
* A suitable VMware datastore is available for use by new cloned VMs’ virtual hard drives.
* A suitable virtual machine template is available to clone as required.
* The following variables are defined within the Terraform Workspace.  These variables should not be configured within the public GitHub repository files.
  * vCenter account username (vcenter_user)
  * vCenter account password (vcenter_password)
  * vCenter server IP/FQDN (vcenter_server)

**Note:** The FMC security automation component has been moved to a 2nd GitHub repository and will now be run from a 2nd, linked Terraform workspace.

## Link to Github Repositories
https://github.com/cisco-apjc-cloud-se/ist-dcn-vcenter
https://github.com/cisco-apjc-cloud-se/ist-vm-fmc-sync


## Steps to Deploy Use Case
1.	In GitHub, create a new, or clone the example GitHub repository(s)
2.	Customize the examples Terraform files & JSON variables as required

![DCNM variables](/images/dcnm-vars.png)

3.	In Intersight, configure a Terraform Cloud target with suitable user account and token

![Intersight target](/images/intersight-target.png)

4.	In Intersight, configure a Terraform Agent target with suitable managed host URLs/IPs.  This list of managed hosts must include the IP addresses for the DCNM, FMC and vCenter servers as well as access to common GitHub domains in order to download hosted Terraform providers.

![Intersight agent](/images/intersight-agent.png)

5.	In Terraform Cloud for Business, create a new Terraform Workspace and associate to the GitHub repository.

![TFCB workspace](/images/tfcb-workspace.png)

6.	In Terraform Cloud for Business, configure the workspace to the use the Terraform Agent pool configured from Intersight.

![TFCB agent](/images/tfcb-agent.png)

7.	In Terraform Cloud for Business, configure the necessary user account variables for the DCNM and vCenter servers.

![TFCB variables](/images/tfcb-vars.png)

## Execute Deployment
In Terraform Cloud for Business, queue a new plan to trigger the initial deployment.  Any future changes to pushed to the GitHub repository will automatically trigger a new plan deployment.

## Results
If successfully executed, the Terraform plan will result in the following configuration for each domain manager.

### DCNM Module
* New Layer 3 VXLAN networks, as defined in the “dc_networks” JSON object, within the existing VRF, each with the following configuration:
  * Name
  * Anycast Gateway IPv4 Address/Mask
  * VXLAN VNI ID
  * Layer 2 VLAN ID

![DCNM networks](/images/dcnm-networks.png)

![DCNM diagram](/images/dcnm-diagram.png)

* The new VXLAN networks trunked to the switches and ports defined in the “svr_cluster” JSON object

![DCNM interface](/images/dcnm-interface.png)

### vCenter Module
* New distributed port groups, within the existing distributed virtual switch for each new network defined in the DCNM module.
  * Each new distributed port group will use the same name and VLAN ID as the DCNM L3 Network

![vCenter network](/images/vcenter-network.png)

* A number of cloned VMs as defined in the “vm_group_a” and “vm_group_b” JSON objects. These use the existing vCenter cluster, datastore and template details provided.
  * Each VM will be assigned a unique name and suffix combination based on the number of VMs defined (i.e. xxx-1, xxx-2).
  * Each VM will have a single virtual NIC (vNIC) connected to a specific new L3 Networks and associated new distributed port group above.
  * Each VM’s operating system will be configured with a unique hostname and suffix combination based on the number of VMs defined (i.e. xxx-1, xxx-2).
  * Each VM’s operating system will be configured with a unique static IP address automatically defined by the attached L3 Network’s IP subnet and an offset based on the number of VMs defined (i.e. .2, .3, .4 etc.)

![vCenter list](/images/vcenter-list.png)

![vCenter details](/images/vcenter-details.png)

## Expected Day 2 Changes
Changes to the variables defined in the JSON files will result in dynamic, stateful updates across all domains. For example,

* Increasing the number of servers in group will result in a newly clone VM, and a matching host object in FMC and that object added to the existing server network group object.  This means the new server would automatically inherit any existing security policies on the firewall(s) that reference this group object.

```
  "vm_group_a": {
    "group_size": 4,
    "name": "ist-svr-a",
    "host_name": "ist-svr-a",
    "num_cpus": 2,
    "memory": 1024,
    "network_id": "ist-network-a",
    "domain": "mel.ciscolabs.com",
    "dns_list": [
      "64.104.123.245",
      "171.70.168.183"
    ]
  },
```

* If a new server is added the VMware cluster, the DC networking configuration would need to be updated to ensure a consistent configuration across all members of the cluster.  With this IaC lead approach, this can be achieved be allocating new switch ports on the N9Ks and adding these to the existing configuration and the Terraform plan executed.

```
  "svr_cluster": {
    "DC3-N9K1": {
      "name": "DC3-N9K1",
      "attach": true,
      "switch_ports": [
        "Ethernet1/1",  # Host 1 Uplink Port 1
        "Ethernet1/2"   # Host 2 Uplink Port 1
      ]
    },
    "DC3-N9K2": {
      "name": "DC3-N9K2",
      "attach": true,
      "switch_ports": [
        "Ethernet1/1",  # Host 1 Uplink Port 2
        "Ethernet1/2"   # Host 2 Uplink Port 2
      ]
    }
  },
```

* If a new server is added to the cluster, but is located in new rack (with its own switches) the existing configuration would be extended as follows:

```
  "svr_cluster": {
    "DC3-N9K1": {
      "name": "DC3-N9K1",
      "attach": true,
      "switch_ports": [
        "Ethernet1/1"  # Host 1 Uplink Port 1
      ]
    },
    "DC3-N9K2": {
      "name": "DC3-N9K2",
      "attach": true,
      "switch_ports": [
        "Ethernet1/1"  # Host 1 Uplink Port 2
      ]
    },
    "DC3-N9K3": {
      "name": "DC3-N9K3",
      "attach": true,
      "switch_ports": [
        "Ethernet1/1"  # Host 2 Uplink Port 1
      ]
    },
    "DC3-N9K4": {
      "name": "DC3-N9K2",
      "attach": true,
      "switch_ports": [
        "Ethernet1/1"  # Host 2 Uplink Port 2
      ]
    }
  },
```
