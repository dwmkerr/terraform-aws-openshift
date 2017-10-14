# Create the forwarder service account.
# Add priviledges to mount volumes and run as root.
oc create sa splunk-forwarder
oadm policy add-scc-to-user anyuid system:serviceaccount:default:splunk-forwarder
oadm policy add-scc-to-user privileged system:serviceaccount:default:splunk-forwarder
