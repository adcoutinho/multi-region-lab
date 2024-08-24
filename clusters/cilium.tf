resource "helm_release" "cilium" {
  name        = "cilium"
  namespace   = "kube-system"
  repository  = "https://helm.cilium.io/"
  chart       = "cilium"
  version     = local.cilium_config.cilium_version
  max_history = 5

  values = [
    <<-EOT
    cluster:
      id: ${local.cilium_config.cluster_id}

      name: ${local.name}
    
    eni:
      enabled: true
      eniTags: ${local.tags}
      awsReleaseExcessIPs: true
      ec2APIEndpoint: ec2.${local.region}.api.aws
      subnetTagsFilter: karpenter.sh/discovery = ${local.name}
      updateEC2AdapterLimitViaAPI: true
      awsEnablePrefixDelegation: true
      iamRole: ${local.cilium_config.role}
    
    ipam:
      mode: eni
    
    # Agent Config #
    image:
      repository: "697525377503.dkr.ecr.us-east-1.amazonaws.com/cilium-agent"
      tag: ${local.cilium_config.cilium_version}
      useDigest: false
    
    k8sServiceHost: ${trimprefix(aws_eks_cluster.cluster.endpoint, "https://")}
    k8sServicePort: 443
    policyEnforcementMode: ${local.cilium_config.enforcement}
    egressMasqueradeInterfaces: eth0
    routingMode: native
    tunnel: disabled
    rollOutCiliumPods: true
    priorityClassName: system-cluster-critical
    kubeProxyReplacement: true
    
    bpf:
      hostLegacyRouting: true
      masquerade: true
      tproxy: true
    endpointRoutes:
      enabled: true
    endpointStatus:
      enabled: true
      status: "policy health"
    
    externalIPs:
      enabled: true
    logOptions:
      format: json
    debug:
      enabled: false
    
    prometheus:
      enabled: ${local.cilium_config.prometheus}
      serviceMonitor:
        enabled: ${local.cilium_config.prometheus}
    
    operator:
      image:
        repository: "697525377503.dkr.ecr.us-east-1.amazonaws.com/cilium-operator"
        suffix: ""
        tag: ${local.cilium_config.cilium_version}
        useDigest: false
      rollOutPods: true
      replicas: 2
      unmanagedPodWatcher:
        restart: false
      prometheus:
        enabled: ${local.cilium_config.prometheus}
        serviceMonitor:
          enabled: ${local.cilium_config.prometheus}
      extraArgs:
        - --enable-metrics
      podDisruptionBudget:
        enabled: true
      tolerations:
      - key: "initial_nodes"
        operator: "Exists"
        effect: "NoSchedule"
      nodeSelector:
        kubernetes.io/os: linux
        purpose: initial_nodes

    hubble:
      enabled: true
      metrics:
        enableOpenMetrics: true
        serviceMonitor:
          enabled: ${local.cilium_config.prometheus}
        enabled:
        - dns
        - drop
        - tcp
        - flow
        - flows-to-world
        - port-distribution
        - icmp
        - http
        dashboards:
          enabled: true
      relay:
        enabled: true
        image:
          repository: "697525377503.dkr.ecr.us-east-1.amazonaws.com/hubble-relay"
          tag: ${local.cilium_config.cilium_version}
          useDigest: false
        prometheus:
          enabled: ${local.cilium_config.prometheus}
        tolerations:
        - key: "initial_nodes"
          operator: "Exists"
          effect: "NoSchedule"
        nodeSelector:
          kubernetes.io/os: linux
          purpose: initial_nodes
    
      ui:
        enabled: true
        rollOutPods: true
        backend:
          image:
            repository: "697525377503.dkr.ecr.us-east-1.amazonaws.com/hubble-ui-backend"
            tag: "${local.cilium_config.hubble_version}"
            useDigest: false
        frontend:
          image:
            repository: "697525377503.dkr.ecr.us-east-1.amazonaws.com/hubble-ui-front"
            tag: "${local.cilium_config.hubble_version}"
            useDigest: false
        tolerations:
        - key: "initial_nodes"
          operator: "Exists"
          effect: "NoSchedule"
        nodeSelector:
          kubernetes.io/os: linux
          purpose: initial_nodes
    
        # -- hubble-ui ingress configuration.
        ingress:
          enabled: true
          annotations: 
            external-dns: enabled
          hosts:
            - ${local.cilium_config.hubble_url}
    
    nodePort:
      # -- Enable the Cilium NodePort service implementation.
      enabled: true
  EOT
  ]
  depends_on = [
    helm_release.karpenter
  ]
}
