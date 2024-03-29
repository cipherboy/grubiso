#!/bin/bash

# install.sh -- installer for grubiso
# Copyright (C) 2012 Alex Scheel
# Licensed under the terms of the GNU GPL v3.

## Installation locations
grubiso='/etc/grub.d/50_grubiso'
iso='/iso'
config='/etc/grubiso.conf'
docs='/usr/share/doc/grubiso'

# Check for root

if [ $(id -u) == 0 ]; then
    # root, tread lightly now.
    #
    # Required for this to work:
    # GRUB v1.99 or later
    
    echo -n "Checking for grub...                 "
    
    grub=$(which update-grub)
    if [ -e $grub ]; then
        # GRUB exists, check version
        echo "Pass"
        
        # Check version
        echo -n "Checking version...                  "
        version=$($grub --version | grep -o '[0-9a-z\.\-]\{1,\}$')
        echo $version
        
        # Check for required directories
        echo -n "Checking for /etc/grub.d...          "
        if [ -d /etc/grub.d ]; then
            # /etc/grub.d found.
            echo "Pass"
            
            # Begin installation
            echo ""
            echo "Begining installation..."
            
            # Check for previous versions, and remove
            echo -n "Checking for previous versions...    "
            if [ -e $grubiso ]; then
                echo "Found"
                # Remove grubiso
                rm $grubiso -f
            else
                echo "None"
            fi
            
            # Install 50_grubiso
            echo "Installing grubiso..."
            working=$(dirname $0)/files/50_grubiso
            cp $working $grubiso 2>&1 >/dev/null
            
            # Check for /iso...
            echo -n "Checking for /iso directory...       "
            if [ -d /iso ]; then
                echo "Found"
            else
                echo "None"
                mkdir $iso 2>&1 >/dev/null
            fi
            
            # Check for previous config
            echo -n "Checking for previous config...      "
            if [ -e $config ]; then
                echo "Found"
            else
                echo "None"
                
                # Create new config 
                
                echo -n "Creating config...                   "
                cat <<EOF >$config
iso: $iso
EOF
                echo "Done"
            fi
            
            # Check for and install documentation
            echo -n "Checking for docs...                 "
            if [ -d $docs ]; then
                echo "Found"
            else
                echo "None"
                
                # Install documentation 
                echo -n "Installing documentation...          "
                cp $(dirname $0)/docs $docs -r 2>&1 1>/dev/null
                echo "Done"
            fi
            
            
            # Almost done. All that is left is to update-grub, inform the user
            # on how to use grubiso, then exit.
            
            # Update grub2's menu.
            echo -n "Running update-grub...               "
            echo $($grub 2>&1 1>/dev/null) >/dev/null
            echo "Done"
            
            # Display text
            echo ""
            cat $(dirname $0)/docs/post_install
        else
            # /etc/grub.d not found, exiting
            echo "Fail"
            echo "Error: Must have the /etc/grub.d directory" 1>&2
        fi
    else
        # No GRUB, grubiso will not work.
        echo "Fail"
        echo "Error: Must have grub installed on this system" 1>&2
        exit 1
    fi
else
    # Not root user, exit with error
    echo "Error: must be root to run this installer" 1>&2
    exit 1
fi
