##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=true


# Set what you want to display when installing your module

print_modname() {
  ui_print " "
  ui_print "    ********************************************"
  ui_print "    *               ida server                 *"
  ui_print "    ********************************************"
  ui_print " "
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  case $ARCH in
    arm64) F_ARCH=$ARCH;;
    arm)   F_ARCH=$ARCH;;
    x64)   F_ARCH=x86_64;;
    x86)   F_ARCH=$ARCH;;
    *)     ui_print "Unsupported architecture: $ARCH"; abort;;
  esac

  ui_print "- Detected architecture: $F_ARCH"
  ui_print "- Extracting module files"

  F_TARGETDIR="$MODPATH/system/bin"
  # Check if the KSU environment variable is set
if [ "$KSU" = "true" ]; then
    # Running in KernelSU
    echo "Running in KernelSU environment."
    UNZIP="/data/adb/ksu/bin/busybox unzip"
    # Add your KernelSU-specific actions here 
else
    # Running in Magisk
    echo "Running in Magisk environment."
    UNZIP="/data/adb/magisk/busybox unzip"
    # Add your Magisk-specific actions here
fi
  

  mkdir -p "$F_TARGETDIR"
  $UNZIP -qq -o "$ZIPFILE" "files/android_server-$F_ARCH" -j -d "$F_TARGETDIR"

  mv "$F_TARGETDIR/android_server-$F_ARCH" "$F_TARGETDIR/idserver"
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Custom permissions
  set_perm $MODPATH/system/bin/idserver 0 2000 0755 u:object_r:system_file:s0
}

# You can add more functions to assist your custom script code
