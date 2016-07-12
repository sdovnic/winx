# Windows 10 Deployment Suite

## Applications

* Removes unnecessary Windows Applications

You will be asked to continue before every step. Please Review the `Applications.ps1` before you execute the Script. You can remove or add your custom actions that fits your need.

To execute run:

    Applications.cmd

## Deployment

* Removes unnecessary Windows Applications
* Disables unnecessary Firewall Rules
* Removes unnecessary Optional Windows Features
* Disables Windows Home Groups
* Removes Windows OnDrive
* Disables unnecessary Windows Services
* Disables Windows Telemetry
* Sets Alternative Network Time Servers

You will be asked to continue before every step. Please Review the `Deployment.ps1` before you execute the Script. You can remove or add your custom actions that fits your need.

To execute run:

    Deployment.cmd

## PhotoViewer

Activates the Windows PhotoViewer known from older Windows Opreating System Versions.

To execute run:

    PhotoViewer.cmd

## Firewall

Adds some Essential Rules to your Windows Advanced Firewall.

You will be asked before every Rule, if you like to apply it.

* Allow all outgoing Secure Shell Traffic
* Allow Advanced TCP/IP Network Printing
* Allow the Service W32Time to contact a Network Time Server

To execute run:

    Firewall.cmd

## Flash

Removes the integrated Flash from your Windows 10 Installation. Please use this carefully you also may need to restore Flash in order to run Windows Update correctly.

The Script will make Backups from your installed Flash. Please keep them save to the script you may need them later.

To execute run:

    Flash.cmd
