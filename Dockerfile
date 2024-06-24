FROM ubuntu:latest

LABEL org.opencontainers.image.authors="tigerblue77"

RUN apt-get update

RUN apt-get install ipmitool -y

ADD functions.sh /app/functions.sh
ADD healthcheck.sh /app/healthcheck.sh
ADD Dell_iDRAC_fan_controller.sh /app/Dell_iDRAC_fan_controller.sh

RUN chmod 0777 /app/functions.sh /app/healthcheck.sh /app/Dell_iDRAC_fan_controller.sh

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "/app/healthcheck.sh" ]

# you should override these default values when running. See README.md
# ENV IDRAC_HOST 192.168.1.100
ENV IDRAC_HOST local
# ENV IDRAC_USERNAME root
# ENV IDRAC_PASSWORD calvin
ENV CHECK_INTERVAL 60
ENV DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE true
ENV EXHAUST_OVERHEAT_9_TEMPERATURE 60
ENV EXHAUST_OVERHEAT_8_TEMPERATURE 55
ENV EXHAUST_OVERHEAT_7_TEMPERATURE 50
ENV EXHAUST_OVERHEAT_6_TEMPERATURE 45
ENV EXHAUST_OVERHEAT_5_TEMPERATURE 40
ENV EXHAUST_OVERHEAT_4_TEMPERATURE 35
ENV EXHAUST_OVERHEAT_3_TEMPERATURE 30
ENV EXHAUST_OVERHEAT_2_TEMPERATURE 25
ENV EXHAUST_OVERHEAT_1_TEMPERATURE 20
ENV EXHAUST_OVERHEAT_8_FANSPEED 45
ENV EXHAUST_OVERHEAT_7_FANSPEED 40
ENV EXHAUST_OVERHEAT_6_FANSPEED 35
ENV EXHAUST_OVERHEAT_5_FANSPEED 30
ENV EXHAUST_OVERHEAT_4_FANSPEED 27
ENV EXHAUST_OVERHEAT_3_FANSPEED 25
ENV EXHAUST_OVERHEAT_2_FANSPEED 22
ENV EXHAUST_OVERHEAT_1_FANSPEED 20

CMD ["./Dell_iDRAC_fan_controller.sh"]
