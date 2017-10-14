# Recipes - Splunk

1. Get the free Splunk installer from: https://www.splunk.com/goto/Download_4_V1
2. Upload to a bucket
3. Create an EC2 instance
4. Download the image
5. Elevate, install

# Unpack splunk.
tar xvzf splunk_package_name.tgz -C /opt

# Start splunk.
/opt/splunk/bin/splunk start --accept-license

Installation instructions: https://docs.splunk.com/Documentation/Splunk/6.5.3/Installation/InstallonLinux

```
# Create the forwarder service account.
oc create sa splunk-forwarder

# Add the permissions required to mount volumes from the host.
# Could attempt to use least-privileges by only using mounthost, but privileged works for now..
oc adm policy add-scc-to-user privileged system:serviceaccount:default:splunk-forwarder
# Allow the image to run as root, as it wants to access the filesystem and splunk folders.
oadm policy add-scc-to-user anyuid system:serviceaccount:default:splunk-forwarder
```
# TODO

- [x] update openshift origin version
- [x] makefile to setup software
- [ ] fix logging to json files in /var/log/containers
- [ ] Rebuild, ensure json logging is set up, ensure we can create security groups
- [ ] image for splunk server
- [ ] Create a service account for the forwarder which allows host volume mounts
- [ ] Attach the SA to the DS
- [ ] Restart always for the DS
- [ ] Automate the DS setup on the master node
- [ ] Ensure the pod and container name are stripped from the logs.

## Symlink Logs

To get logs with the container name and ID, it helps to have the symlinked logs. This only seems to work with Kubernetes 1.6 onwards, see this bug:

- https://github.com/minishift/minishift/issues/510

This means you should be running OpenShift 3.6 or onwards. To have symlinked logs, you must also run with the [`json-file` log driver](https://docs.docker.com/engine/admin/logging/json-file/).

# Important Documentation

- [Kubernetes - Cluster Administration - Logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- [Splunk Universal Forwarder Image](https://hub.docker.com/r/splunk/universalforwarder/)

# Useful Reading

- Splunk, k8s, fluentd, syslog, loggerd and more: https://github.com/kubernetes/kubernetes/issues/24677
