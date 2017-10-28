# Note

# Bonus

- [ ] Avoid first time login password reset warning
- [ ] Auto strip details from the logs

## Extracting the Pod Name, Container Name, Container ID etc

Use the following filter:

```
 | rex field=source "\/var\/log\/containers\/(?<pod>[a-zA-Z0-9-]*)_(?<namespace>[a-zA-Z0-9]*)_(?<container>[a-zA-Z0-9]*)-(?<conatinerid>[a-zA-Z0-9_]*)"
```

This example query shows all of the events from the counter logs:

```
source="/var/log/containers/counter-1-*"  | rex field=source "\/var\/log\/containers\/(?<pod>[a-zA-Z0-9-]*)_(?<namespace>[a-zA-Z0-9]*)_(?<container>[a-zA-Z0-9]*)-(?<conatinerid>[a-zA-Z0-9_]*)" | table time, host, namespace, pod, container, log
```

# Important Documentation

- [Kubernetes - Cluster Administration - Logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- [Splunk Universal Forwarder Image](https://hub.docker.com/r/splunk/universalforwarder/)

# Useful Reading

- Splunk, k8s, fluentd, syslog, loggerd and more: https://github.com/kubernetes/kubernetes/issues/24677

# Prior Art

- https://kubernetes.io/docs/concepts/cluster-administration/logging/
- http://jasonpoon.ca/2017/04/03/kubernetes-logging-with-splunk/
