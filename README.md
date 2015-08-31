This is a utility for connecting on ec2to autoscale groups and run multiple commands either parallel sequential or in groups

(based on sshkit https://github.com/capistrano/sshkit)

use it where you need to upload / download / capture output/ exec commands

````txt
seperate commands with a semicolon

default region: us-east-1
default user: ec2-user
default connnection :parallel
````

Groups were designed in this case to relieve problems (mass Git checkouts) where you rely on a contested resource that you don't want to DDOS by hitting it too hard.

Sequential runs were intended to be used for rolling restarts, amongst other similar use-cases.

if the instance is on a private subnet (given you have a VPN connection) it will fallback to connecting using the internal IP address

##examples:

--terminal (-t) will open multiple terminals windows of all servers found (currently only supported on OSX iTerm2)
````bash
$ ec2-ssh -t --tag-value ElasticSearch
````
-------------------
upload / download separate source,destination with a comma
````bash
$ ec2-ssh --download /home/ec2-user/file.txt,~/Downloads --tag-value ElasticSearch
````
-------------------
coonect to instances filter by custom tag
````bash
$ ec2-ssh --tag-key staging --tag-value true --cmd 'touch /tmp/test'
````
-------------------
pass profile of aws/credentials to use different accounts on AWS
(http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
````bash
$ ec2-ssh --tag-value ElasticSearch --profile otherAccountName --cmd 'touch /tmp/test'
````
-------------------

connect by selecting autoscale group name

````bash
$ ec2-ssh --as --cmd 'touch /tmp/test'

0: ElasticSearch-ElasticSearchServerGroup1
1: KibanaServerGroup
3: LogstashServerGroup
4: ...
````
simply selct the number corresponding to the autoscale group (limit of AWS SDk is to fetch maximum 100 AutoScale Groups)

-------------------


##Possible command line options
````bash
Usage:
  ec2-ssh connect

Options:
      [--cmd=CMD]                       # commmand to run on remote servers
      [--profile=PROFILE]               # Aws cli profile name as listed in ~/aws/credentials
                                        # Default: default
      [--region=REGION]                 # region
                                        # Default: us-east-1
  u, [--user=USER]                      # run as user
                                        # Default: ec2-user
  p, [--parallel=PARALLEL]              # run in parallel
  s, [--sequence=SEQUENCE]              # run in sequence
  g, [--groups=GROUPS]                  # run in groups
  l, [--groups-limit=N]                 # limit
  w, [--wait=N]                         # wait
      [--as=AS]                         # filter by autoscale groups
      [--tag-key=TAG_KEY]               # tag key to filter instances by
                                        # Default: Name
      [--tag-value=TAG_VALUE]           # tag value to filter instances by
  t, [--terminal=TERMINAL]              # open terminal tabs for all servers
  c, [--capture-output=CAPTURE_OUTPUT]  # capture output
      [--upload=source,destination]     # upload a file - source,destination (make sure seperate these by comma)
      [--download=source,destination]   # download a file - source,destination (make sure seperate these by comma)

Connect to autoscale instance (random instance), Pass --cmd='whatever' to run a cmd on the server (use ; to seperate commands)
````