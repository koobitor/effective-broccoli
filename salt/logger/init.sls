/usr/local/bin/logger.sh:
  file:
    - managed
    - source: salt://logger/logger.sh
    - mode: 0755
  cron.present:
    - user: root
    - minute: '*/30'
