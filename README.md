# Detection Lab

## Purpose
This lab was originally designed for a defender's lab, however, this has become a project for me to build out an Active Directory environment that can be used by penetration testers to test exploits and practice their skills. Its primary purpose is to allow the user to quickly build a Windows domain environment that comes fully configured. It can easily be modified to fit most needs or expanded to include additional hosts.

NOTE: As with any testing lab boxes, please do not connect or bridge it to any networks you care about. 
---

## Building AutoLab

1. `cd` to the Packer directory and build the Windows 10 and Windows Server 2016 boxes using the commands below. Each build will take about 1 hour. 

```
$ cd detectionlab/Packer
$ packer build --only=[vmware|virtualbox]-iso windows_10.json
$ packer build --only=[vmware|virtualbox]-iso windows_2016.json
```

2. Once both boxes have built successfully, move the resulting boxes (.box files) in the Packer folder to the Boxes folder:

    `mv *.box ../Boxes`

3. cd into the Vagrant directory: `cd ../Vagrant`
4. Install the Vagrant-Reload plugin: `vagrant plugin install vagrant-reload`

5. Ensure you are in the Vagrant folrder and run `vagrant up`. This command will do the following:
  * Provision the DC host and configure it as a Domain Controller.  Additionally, it will create some basic OUs and generic user/admin AD accounts.
  * Provision the backup DC and configure it as a Backup Domain Controller.
  * Provision the IIS server with a default website running on IIS.
  * (To-Do) Provision the MSSQL Server with dummy data
  * Provision the Win10 host and configure it as a computer in the Workstations OU

## Basic Vagrant Usage
Vagrant commands must be run from the "Vagrant" folder.

* Bring up all hosts: `vagrant up` (optional `--provider=[virtualbox|vmware_fusion|vmware_workstation]`)
* Bring up a specific host: `vagrant up <hostname>`
* Restart a specific host: `vagrant reload <hostname>`
* Restart a specific host and re-run the provision process: `vagrant reload <hostname> --provision`
* Destroy a specific host `vagrant destroy <hostname>`
* Destroy the entire Detection Lab environment: `vagrant destroy` (Adding `-f` forces it without a prompt)
* SSH into a host (only works with Logger): `vagrant ssh logger`
* Check the status of each host: `vagrant status`
* Suspend the lab environment: `vagrant suspend`
* Resume the lab environment: `vagrant resume`

---

## Lab Information
* Domain Name: vzlab.local
* Subnet Range:  10.10.6.0/24

## Lab Hosts
* DC - Primary Domain Controller - Windows Server 2016
* BDC - Backup Domain Controller - Windows Server 2016
* Server-IIS - IIS Web Server - Windows Server 2016
* (To-Do) Server-MSSQL - MSSQL Server - Windows Server 2016
* WIN10A - User Workstation - Windows 10


## Installed Tools on Windows
  * Sysmon
  * osquery
  * AutorunsToWinEventLog
  * Caldera Agent
  * Process Monitor
  * Process Explorer
  * PsExec
  * TCPView
  * Google Chrome
  * Atom editor
  * WinRar
  * Mimikatz

---

## Credits/Resources
A sizable percentage of this code was borrowed and adapted from Chris Long's Detection Lab (https://github.com/clong/DetectionLab).  It has been a huge help for me as I learn more about Packer/Vagrant and to have a great starting point to work off of.

# Acknowledgements
[DetectionLab](https://github.com/clong/DetectionLab)
