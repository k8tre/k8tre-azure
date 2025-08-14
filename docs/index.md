# K8TRE Azure Infrastructure
K8TRE-Azure infrastructure is a IaC reference implementation that provides base resources required to deploy K8TRE MVP on Azure (i.e. AKS). Developed by LTH as part of the EPSRC-funded TREvolution project, this project is designed to deploy nessasary resources (e.g. AKS, Private DNS Zones, etc) into a pre-existing hub-spoke based [landing zone](landing_zone.md) created at LTH.     

To try K8TRE on Azure, go to [Get Started](landing_zone.md) guide.

!!! warning
    This IaC project is in alpha-stage development and is designed to support the deployment of [K8TRE MVP](https://github.com/k8tre/k8tre) on Azure. Beware, K8TRE-Azure IaC requires a specified hub-spoke landing zone designed for LTH requirements.  