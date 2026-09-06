# SC8886S Linux Kernel Driver (Z96A RK3568)

Linux kernel module for SouthChip SC8886S battery charger IC, ported from ESP-IDF [drinktoomuchsax/sc8886s.c](https://github.com/drinktoomuchsax/sc8886s.c).

## Build (GitHub Actions)

`git push` triggers CI build for both legacy (5.10) and edge (6.1) Armbian kernels.

After CI passes, download `sc8886s_charger-edge-6.1.ko` artifact.

## Install on Z96A

```bash
# 1) Unbind bq25700_charger (it conflicts with sc8886 at 0x6b)
echo 0-006b > /sys/bus/i2c/drivers/bq25700-charger/unbind

# 2) Copy and load our driver
cp sc8886s_charger-edge-6.1.ko /tmp/
insmod /tmp/sc8886s_charger-edge-6.1.ko

# 3) Verify
dmesg | grep -i sc8886s
ls /sys/class/power_supply/sc8886s/

# 4) Read real battery (SC8886 internal ADC, bypasses SARADC misconfig)
cat /sys/class/power_supply/sc8886s/voltage_now
cat /sys/class/power_supply/sc8886s/current_now
cat /sys/class/power_supply/sc8886s/status
```

## Auto-load on boot

```bash
# Persistent
cp sc8886s_charger-edge-6.1.ko /lib/modules/$(uname -r)/extra/
depmod -a
echo "sc8886s_charger" > /etc/modules-load.d/sc8886s.conf
echo "blacklist bq25700_charger" > /etc/modprobe.d/blacklist-bq25700.conf
update-initramfs -u
```

## Driver config (auto-applied on probe)

- VSYSMIN = 6.0V (battery lower limit)
- ICHG = 1024 mA (charge current)
- VCHG = 8.0V (charge target, 2S Li-ion 80% SOC)
- WDTWR_ADJ = 3 (watchdog disabled)
- PROCHOT_BATOCP = 0 (disable OCP-triggered discharge)
- PROCHOT_BATOVP = 0 (disable OVP-triggered discharge)

## Known issues

- SC8886 VBAT pin is open-circuit on Z96A (hardware bug)
- Driver uses blind-charge: SC8886 charges by ICHG setting without VBAT feedback
- SARADC ch5 (used by rk817_battery) is misconfigured in DTB → still wrong sysfs `battery/voltage_now`
- Use our driver (`sc8886s/voltage_now`) for real battery readings

## License

GPL-2.0
