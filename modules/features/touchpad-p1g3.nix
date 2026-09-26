{
  flake.nixosModules.touchpad-p1g3 = {
    # P1's Synaptics touchpad: keep it in PS/2 mode instead of SMBus/RMI4
    # (commit 0bebb83, "Improve p1g3 trackpad and scroll behavior"). Only
    # affects Synaptics PS/2 pads; the t14s Elan pad is on I2C and unaffected.
    boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  };
}
