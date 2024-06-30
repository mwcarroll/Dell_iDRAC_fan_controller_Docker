<div id="top"></div>



# Dell iDRAC fan controller Docker image
Download Docker image from :
- [Docker Hub](https://hub.docker.com/r/mattcarroll/dell_idrac_fan_controller)
- [GitHub Containers Repository](https://github.com/mwcarroll/Dell_iDRAC_fan_controller_Docker/pkgs/container/dell_idrac_fan_controller)

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#container-console-log-example">Container console log example</a></li>
    <li><a href="#supported-architectures">Supported architectures</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#parameters">Parameters</a></li>
    <li><a href="#troubleshooting">Troubleshooting</a></li>
    <li><a href="#contributing">Contributing</a></li>
  </ol>
</details>

## Container console log example

![image](https://user-images.githubusercontent.com/37409593/216442212-d2ad7ff7-0d6f-443f-b8ac-c67b5f613b83.png)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- PREREQUISITES -->
## Prerequisites
### iDRAC version

This Docker container only works on Dell PowerEdge servers that support IPMI commands, i.e. < iDRAC 9 firmware 3.30.30.30.

### To access iDRAC over LAN (not needed in "local" mode) :

1. Log into your iDRAC web console

![001](https://user-images.githubusercontent.com/37409593/210168273-7d760e47-143e-4a6e-aca7-45b483024139.png)

2. In the left side menu, expand "iDRAC settings", click "Network" then click "IPMI Settings" link at the top of the web page.

![002](https://user-images.githubusercontent.com/37409593/210168249-994f29cc-ac9e-4667-84f7-07f6d9a87522.png)

3. Check the "Enable IPMI over LAN" checkbox then click "Apply" button.

![003](https://user-images.githubusercontent.com/37409593/210168248-a68982c4-9fe7-40e7-8b2c-b3f06fbfee62.png)

4. Test access to IPMI over LAN running the following commands :
```bash
apt -y install ipmitool
ipmitool -I lanplus \
  -H <iDRAC IP address> \
  -U <iDRAC username> \
  -P <iDRAC password> \
  sdr elist all
```

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- SUPPORTED ARCHITECTURES -->
## Supported architectures

This Docker container is currently built and available for the following CPU architectures :
- AMD64
- ARM64

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- USAGE -->
## Usage

1. with local iDRAC:

```bash
docker run -d \
  --name Dell_iDRAC_fan_controller \
  --restart=unless-stopped \
  -e IDRAC_HOST=local \
  -e CHECK_INTERVAL=<seconds between each check> \
  -e DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE=<true or false> \
  -e EXHAUST_OVERHEAT_9_TEMPERATURE=60 \
  -e EXHAUST_OVERHEAT_8_TEMPERATURE=55 \ 
  -e EXHAUST_OVERHEAT_7_TEMPERATURE=50 \
  -e EXHAUST_OVERHEAT_6_TEMPERATURE=45 \
  -e EXHAUST_OVERHEAT_5_TEMPERATURE=40 \
  -e EXHAUST_OVERHEAT_4_TEMPERATURE=35 \
  -e EXHAUST_OVERHEAT_3_TEMPERATURE=30 \
  -e EXHAUST_OVERHEAT_2_TEMPERATURE=25 \
  -e EXHAUST_OVERHEAT_1_TEMPERATURE=20 \
  -e EXHAUST_OVERHEAT_8_FANSPEED=45 \
  -e EXHAUST_OVERHEAT_7_FANSPEED=40 \
  -e EXHAUST_OVERHEAT_6_FANSPEED=35 \
  -e EXHAUST_OVERHEAT_5_FANSPEED=30 \
  -e EXHAUST_OVERHEAT_4_FANSPEED=27 \
  -e EXHAUST_OVERHEAT_3_FANSPEED=25 \
  -e EXHAUST_OVERHEAT_2_FANSPEED=22 \ 
  -e EXHAUST_OVERHEAT_1_FANSPEED=20 \
  --device=/dev/ipmi0:/dev/ipmi0:rw \
  mattcarroll/dell_idrac_fan_controller:latest
```

2. with LAN iDRAC:

```bash
docker run -d \
  --name Dell_iDRAC_fan_controller \
  --restart=unless-stopped \
  -e IDRAC_HOST=<iDRAC IP address> \
  -e IDRAC_USERNAME=<iDRAC username> \
  -e IDRAC_PASSWORD=<iDRAC password> \
  -e CHECK_INTERVAL=<seconds between each check> \
  -e DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE=<true or false> \
  -e EXHAUST_OVERHEAT_9_TEMPERATURE=60 \
  -e EXHAUST_OVERHEAT_8_TEMPERATURE=55 \ 
  -e EXHAUST_OVERHEAT_7_TEMPERATURE=50 \
  -e EXHAUST_OVERHEAT_6_TEMPERATURE=45 \
  -e EXHAUST_OVERHEAT_5_TEMPERATURE=40 \
  -e EXHAUST_OVERHEAT_4_TEMPERATURE=35 \
  -e EXHAUST_OVERHEAT_3_TEMPERATURE=30 \
  -e EXHAUST_OVERHEAT_2_TEMPERATURE=25 \
  -e EXHAUST_OVERHEAT_1_TEMPERATURE=20 \
  -e EXHAUST_OVERHEAT_8_FANSPEED=45 \
  -e EXHAUST_OVERHEAT_7_FANSPEED=40 \
  -e EXHAUST_OVERHEAT_6_FANSPEED=35 \
  -e EXHAUST_OVERHEAT_5_FANSPEED=30 \
  -e EXHAUST_OVERHEAT_4_FANSPEED=27 \
  -e EXHAUST_OVERHEAT_3_FANSPEED=25 \
  -e EXHAUST_OVERHEAT_2_FANSPEED=22 \ 
  -e EXHAUST_OVERHEAT_1_FANSPEED=20 \
  mattcarroll/dell_idrac_fan_controller:latest
```

`docker-compose.yml` examples:

1. to use with local iDRAC:

```yml
version: '3.8'

services:
  Dell_iDRAC_fan_controller:
    image: mattcarroll/dell_idrac_fan_controller:latest
    container_name: Dell_iDRAC_fan_controller
    restart: unless-stopped
    environment:
      - IDRAC_HOST=local
      - CHECK_INTERVAL=<seconds between each check>
      - DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE=<true or false>
      # temperatures must be in decreasing order
      - EXHAUST_OVERHEAT_9_TEMPERATURE=60 # anything over this value will enable the default Dell profile
      - EXHAUST_OVERHEAT_8_TEMPERATURE=55
      - EXHAUST_OVERHEAT_7_TEMPERATURE=50
      - EXHAUST_OVERHEAT_6_TEMPERATURE=45
      - EXHAUST_OVERHEAT_5_TEMPERATURE=40
      - EXHAUST_OVERHEAT_4_TEMPERATURE=35
      - EXHAUST_OVERHEAT_3_TEMPERATURE=30
      - EXHAUST_OVERHEAT_2_TEMPERATURE=25
      - EXHAUST_OVERHEAT_1_TEMPERATURE=20
      # fan speeds should be in decreasing order
      - EXHAUST_OVERHEAT_8_FANSPEED=45
      - EXHAUST_OVERHEAT_7_FANSPEED=40
      - EXHAUST_OVERHEAT_6_FANSPEED=35
      - EXHAUST_OVERHEAT_5_FANSPEED=30
      - EXHAUST_OVERHEAT_4_FANSPEED=27
      - EXHAUST_OVERHEAT_3_FANSPEED=25
      - EXHAUST_OVERHEAT_2_FANSPEED=22
      - EXHAUST_OVERHEAT_1_FANSPEED=20
    devices:
      - /dev/ipmi0:/dev/ipmi0:rw
```

2. to use with LAN iDRAC:

```yml
version: '3.8'

services:
  Dell_iDRAC_fan_controller:
    image: mattcarroll/dell_idrac_fan_controller:latest
    container_name: Dell_iDRAC_fan_controller
    restart: unless-stopped
    environment:
      - IDRAC_HOST=<iDRAC IP address>
      - IDRAC_USERNAME=<iDRAC username>
      - IDRAC_PASSWORD=<iDRAC password>
      - CHECK_INTERVAL=<seconds between each check>
      - DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE=<true or false>
      # temperatures must be in decreasing order
      - EXHAUST_OVERHEAT_9_TEMPERATURE=60 # anything over this value will enable the default Dell profile
      - EXHAUST_OVERHEAT_8_TEMPERATURE=55
      - EXHAUST_OVERHEAT_7_TEMPERATURE=50
      - EXHAUST_OVERHEAT_6_TEMPERATURE=45
      - EXHAUST_OVERHEAT_5_TEMPERATURE=40
      - EXHAUST_OVERHEAT_4_TEMPERATURE=35
      - EXHAUST_OVERHEAT_3_TEMPERATURE=30
      - EXHAUST_OVERHEAT_2_TEMPERATURE=25
      - EXHAUST_OVERHEAT_1_TEMPERATURE=20
      # fan speeds should be in decreasing order
      - EXHAUST_OVERHEAT_8_FANSPEED=45
      - EXHAUST_OVERHEAT_7_FANSPEED=40
      - EXHAUST_OVERHEAT_6_FANSPEED=35
      - EXHAUST_OVERHEAT_5_FANSPEED=30
      - EXHAUST_OVERHEAT_4_FANSPEED=27
      - EXHAUST_OVERHEAT_3_FANSPEED=25
      - EXHAUST_OVERHEAT_2_FANSPEED=22
      - EXHAUST_OVERHEAT_1_FANSPEED=20
```

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- PARAMETERS -->
## Parameters

All parameters are optional as they have default values (including default iDRAC username and password).

- `IDRAC_HOST` parameter can be set to "local" or to your distant iDRAC's IP address. **Default** value is "local".
- `IDRAC_USERNAME` parameter is only necessary if you're adressing a distant iDRAC. **Default** value is "root".
- `IDRAC_PASSWORD` parameter is only necessary if you're adressing a distant iDRAC. **Default** value is "calvin".
- `CHECK_INTERVAL` parameter is the time (in seconds) between each temperature check and potential profile change. **Default** value is 60(s).
- `DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE` parameter is a boolean that allows to disable third-party PCIe card Dell default cooling response. **Default** value is false.
- `EXHAUST_OVERHEAT_9_TEMPERATURE` parameter is an integer of maximum exhaust temp
- `EXHAUST_OVERHEAT_8_TEMPERATURE` parameter is an integer of step 8 exhaust temp
- `EXHAUST_OVERHEAT_7_TEMPERATURE` parameter is an integer of step 7 exhaust temp
- `EXHAUST_OVERHEAT_6_TEMPERATURE` parameter is an integer of step 6 exhaust temp
- `EXHAUST_OVERHEAT_5_TEMPERATURE` parameter is an integer of step 5 exhaust temp
- `EXHAUST_OVERHEAT_4_TEMPERATURE` parameter is an integer of step 4 exhaust temp
- `EXHAUST_OVERHEAT_3_TEMPERATURE` parameter is an integer of step 3 exhaust temp
- `EXHAUST_OVERHEAT_2_TEMPERATURE` parameter is an integer of step 2 exhaust temp
- `EXHAUST_OVERHEAT_1_TEMPERATURE` parameter is an integer of step 1 exhaust temp
- `EXHAUST_OVERHEAT_8_FANSPEED` parameter is an integer of step 8 fan speed
- `EXHAUST_OVERHEAT_7_FANSPEED` parameter is an integer of step 7 fan speed
- `EXHAUST_OVERHEAT_6_FANSPEED` parameter is an integer of step 6 fan speed
- `EXHAUST_OVERHEAT_5_FANSPEED` parameter is an integer of step 5 fan speed
- `EXHAUST_OVERHEAT_4_FANSPEED` parameter is an integer of step 4 fan speed
- `EXHAUST_OVERHEAT_3_FANSPEED` parameter is an integer of step 3 fan speed
- `EXHAUST_OVERHEAT_2_FANSPEED` parameter is an integer of step 2 fan speed
- `EXHAUST_OVERHEAT_1_FANSPEED` parameter is an integer of step 1 fan speed

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- TROUBLESHOOTING -->
## Troubleshooting

If your server frequently switches back to the default Dell fan mode:
1. Check `Tcase` (case temperature) of your CPU on Intel Ark website and then set `CPU_TEMPERATURE_THRESHOLD` to a slightly lower value. Example with my CPUs ([Intel Xeon E5-2630L v2](https://www.intel.com/content/www/us/en/products/sku/75791/intel-xeon-processor-e52630l-v2-15m-cache-2-40-ghz/specifications.html)) : Tcase = 63°C, I set `CPU_TEMPERATURE_THRESHOLD` to 60(°C).
2. If it's already good, adapt your `FAN_SPEED` value to increase the airflow and thus further decrease the temperature of your CPU(s)
3. If neither increasing the fan speed nor increasing the threshold solves your problem, then it may be time to replace your thermal paste

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>
