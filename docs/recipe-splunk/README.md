First, grab the repo:

```
git clone git@github.com:dwmkerr/terraform-aws-openshift
```

This repo can be used to create a vanilla OpenShift cluster, which is fine for many users. I'm adding 'recipes' to the project, which will allow you to mix in more feature. For now, let's merge in the 'splunk':

```
cd terraform-aws-openshift
git pull origin recipes/splunk
```

Pulling this recipe in adds the extra config and scripts required to set up Splunk. As a reference, you can also see the recipe pull request to see what changes from a 'vanilla' installation to add Splunk:

[Splunk Recipe](https://github.com/dwmkerr/terraform-aws-openshift/pull/16)

Now we've got the code, we can get started!

## Create the Infrastructure

TODO note you need AWS
TODO note you need money for the instances

Just run:

```bash
make infrastructure
```

To create the infrastructure, using [Hashicorp Terraform](https://www.terraform.io). You'll be asked to specify a region:

![Specify Region](/content/images/2017/10/region.png)

Any [AWS region](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) will work fine, use `us-east-1` if you are not sure.

It'll take about 5 minutes for Terraform to build the required infrastructure, which looks like this:

You can see more detail here: TODO recipe page

Once it's done you'll see a message like this:

![Apply Complete](/content/images/2017/10/apply-complete.png)

The infrastructure is ready! A few of the most useful parameters are shown as output variables. If you log into AWS you'll see our new instances, as well as the VPC, network settings etc etc:

![AWS](/content/images/2017/10/aws.png)

## Installing OpenShift

Installing OpenShift is easy:

```bash
make openshift
```

This command will take quite some time to run (sometimes up to 30 minutes). Once it is complete you'll see a message like this:

![TODO]

You can now open the OpenShift console. Use the public address of the master node (which you can get with `$(terraform output master-url)`). There's a convenience function for this too:

```bash
make browse-openshift
```

The default username and password is `admin` and `123`. You'll see we have a clean installation and are ready to create our first project. Close the console for now.

## Installing Splunk

You've probably figured out the pattern by now...

```bash
make splunk
```

Once this command is complete, you can open the Splunk console with:

```bash
make browse-splunk
```

Again the username and password is `admin` and `123`. You can change the password on login, or leave it. Splunk will start a welcome tour. You can now close this console too.

## Demoing Splunk and OpenShift

To see Splunk and OpenShift in action, it helps to have some kind of processing going on in the cluster. You can create a very basic sample project which will spin up two nodes which just write a counter every second as a way to get something running:

```bash
make sample
```

Almost immediately you'll be able to see the data in Splunk:

![]()

And because of the way the log files are named, we can even rip out the namespace, pod, container and id:

![]()

That's it! You have OpenShift running, Splunk set up and automatically forwarding of all container logs. Enjoy!

## Appendix: How It Works

I've tried to keep the setup as simple as possible. Here's how it works.

### How Log Files Are Written

The Docker Engine has a [log driver](https://docs.docker.com/engine/admin/logging/overview/) which determines how container logs are handled. It defaults to the `json-file` driver, which means that logs are written as a json file to:

```
/var/log/containers/{container-id}.log
```

In theory, all we need to do is use a [Splunk Forwarder](http://docs.splunk.com/Documentation/Forwarder/7.0.0/Forwarder/Abouttheuniversalforwarder) to send this file to our indexer... But...

### How Log Files Are Written - on k8s

When running on Kubernetes, things are little difference. On machines with `systemd`, the log driver for the docker engine is set to `journald` (see [Kubernetes - Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/). It is possible to forward `journald` to Splunk, but only by streaming it to a file and then forwarding the file. Given that we need to use a file as an intermediate, it seems easier just to change the driver back to `json-file` and forward that.

So first, we configure the docker engine to use `json-file` (see [this file](https://github.com/dwmkerr/terraform-aws-openshift/blob/recipes/splunk/scripts/postinstall-master.sh)):

```bash
sed -i '/OPTIONS=.*/c\OPTIONS="--selinux-enabled --insecure-registry 172.30.0.0/16 --log-driver=json-file --log-opt max-size=1M --log-opt max-file=3"' /etc/sysconfig/docker
```

Here we just change the options to default to the `json-file` driver, with a max file size of 1MB (and maximum of three files, so we don't chew all the space on the host).

Now the cool thing about Kubernetes is that it creates symlinks to the log files, which have much more descriptive names:

![TODO symlink diagram]()

This means as long as our forwarder has access to these files, we can tail the container log and parse the namespace/pod/container details from the file name.

## How Log Files Are Read

TODO
