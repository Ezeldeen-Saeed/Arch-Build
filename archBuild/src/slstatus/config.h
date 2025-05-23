/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

const unsigned int cpu_interval = 2000;  // Update every 1000 milliseconds (1 second)
const unsigned int ram_interval = 2000;  // Update every 1000 milliseconds (1 second)

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048
#define PADDING "                           "


/*
 * function            description                     argument (example)
 *
 * battery_perc        battery percentage              battery name (BAT0)
 *                                                     NULL on OpenBSD/FreeBSD
 * battery_remaining   battery remaining HH:MM         battery name (BAT0)
 *                                                     NULL on OpenBSD/FreeBSD
 * battery_state       battery charging state          battery name (BAT0)
 *                                                     NULL on OpenBSD/FreeBSD
 * cat                 read arbitrary file             path
 * cpu_freq            cpu frequency in MHz            NULL
 * cpu_perc            cpu usage in percent            NULL
 * datetime            date and time                   format string (%F %T)
 * disk_free           free disk space in GB           mountpoint path (/)
 * disk_perc           disk usage in percent           mountpoint path (/)
 * disk_total          total disk space in GB          mountpoint path (/)
 * disk_used           used disk space in GB           mountpoint path (/)
 * entropy             available entropy               NULL
 * gid                 GID of current user             NULL
 * hostname            hostname                        NULL
 * ipv4                IPv4 address                    interface name (eth0)
 * ipv6                IPv6 address                    interface name (eth0)
 * kernel_release      `uname -r`                      NULL
 * keyboard_indicators caps/num lock indicators        format string (c?n?)
 *                                                     see keyboard_indicators.c
 * keymap              layout (variant) of current     NULL
 *                     keymap
 * load_avg            load average                    NULL
 * netspeed_rx         receive network speed           interface name (wlan0)
 * netspeed_tx         transfer network speed          interface name (wlan0)
 * num_files           number of files in a directory  path
 *                                                     (/home/foo/Inbox/cur)
 * ram_free            free memory in GB               NULL
 * ram_perc            memory usage in percent         NULL
 * ram_total           total memory size in GB         NULL
 * ram_used            used memory in GB               NULL
 * run_command         custom shell command            command (echo foo)
 * swap_free           free swap in GB                 NULL
 * swap_perc           swap usage in percent           NULL
 * swap_total          total swap size in GB           NULL
 * swap_used           used swap in GB                 NULL
 * temp                temperature in degree celsius   sensor file
 *                                                     (/sys/class/thermal/...)
 *                                                     NULL on OpenBSD
 *                                                     thermal zone on FreeBSD
 *                                                     (tz0, tz1, etc.)
 * uid                 UID of current user             NULL
 * uptime              system uptime                   NULL
 * username            username of current user        NULL
 * vol_perc            OSS/ALSA volume in percent      mixer file (/dev/mixer)
 *                                                     NULL on OpenBSD/FreeBSD
 * wifi_essid          WiFi ESSID                      interface name (wlan0)
 * wifi_perc           WiFi signal in percent          interface name (wlan0)
 */



static const struct arg args[] = {
    /* function format               argument */
    { run_command, "%s | ", "perc=$(cat /sys/class/power_supply/BAT0/capacity); \
      status=$(cat /sys/class/power_supply/BAT0/status); \
      if [ \"$status\" = 'Charging' ]; then icon=' '; \
      elif [ \"$perc\" -ge 90 ]; then icon=' '; \
      elif [ \"$perc\" -ge 70 ]; then icon=' '; \
      elif [ \"$perc\" -ge 50 ]; then icon=' '; \
      elif [ \"$perc\" -ge 25 ]; then icon=' '; \
      else icon=' '; fi; echo \"$icon $perc%\"" },

    { run_command, "%s | ", "vol=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n 1 | tr -d '%'); \
      if [ \"$vol\" -ge 70 ]; then icon=' '; \
      elif [ \"$vol\" -ge 30 ]; then icon=' '; \
      else icon=' '; fi; echo \"$icon $vol%\"" },

{ run_command, "%s | ", "(essid=$(iw dev wlan0 link | grep SSID | awk '{print $2}'); \
   perc=$(iw dev wlan0 link | grep signal | awk '{print $2}'); \
   if [ -z \"$essid\" ]; then \
      echo 'No WiFi'; \
   elif [ \"$perc\" -ge -50 ]; then \
      icon='󰤢 '; \
   elif [ \"$perc\" -ge -70 ]; then \
      icon='󰤥 '; \
   elif [ \"$perc\" -ge -90 ]; then \
      icon='󰤨 '; \
   else \
      icon='󰤟 '; \
   fi; \
   echo \"$icon $essid\"; )" },


    { datetime, "%s | ", " %I:%M %p ➡️  %a. %d %b" },
    { cpu_perc, " %02s%% - ", NULL },
    { run_command, "CPU: %s", "sensors | awk '/^CPU/ {print $2}'"},
};
