#!/bin/bash

# Install Sensor package
apt-get install lm-sensors


# Add Sensors information to the pm package
if ! grep -q "thermalstate" /usr/share/perl5/PVE/API2/Nodes.pm; then
  sed -i "s/\tmy \$dinfo = df('\/', 1);     # output is bytes/\t\$res->{thermalstate} = JSON->new->utf8->decode(\`sensors-format\`);\n\n&/g" /usr/share/perl5/PVE/API2/Nodes.pm 
fi

# Add the CPU Temperature to the external metrics
if ! grep -q "sensors-format" /usr/share/perl5/PVE/Service/pvestatd.pm; then
  additionalEntry="my \$cpuTemps = JSON->new->utf8->decode(\`sensors-format\`);\n    my \$thermalinfo = { cpu_temperature => \$cpuTemps->{cpu}, fan => \$cpuTemps->{fan} };\n\n &"

  sed -i "s/my \$dinfo = df('\/', 1);     # output is bytes/${additionalEntry}/g" /usr/share/perl5/PVE/Service/pvestatd.pm
  sed -i 's/nics => \$netdev,/nics => \$netdev,\n\tthermalinfo => \$thermalinfo,/g' /usr/share/perl5/PVE/Service/pvestatd.pm
fi

systemctl restart pvestatd