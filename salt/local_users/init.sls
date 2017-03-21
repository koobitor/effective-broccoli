alice:
  user.present:
    - shell: /bin/bash
bob:
  user.present:
    - shell: /bin/bash
bofh:
  user.present:
    - shell: /bin/bash

alice_ssh_key:
  ssh_auth.present:
    - user: alice
    - source: salt://local_users/salt.pub
    - config: '.ssh/authorized_keys'

bob_ssh_key:
  ssh_auth.present:
    - user: bob
    - source: salt://local_users/salt.pub
    - config: '.ssh/authorized_keys'

bofh_ssh_key:
  ssh_auth.present:
    - user: bofh
    - source: salt://local_users/salt.pub
    - config: '.ssh/authorized_keys'
