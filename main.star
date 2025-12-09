def run(plan, args):
    """
    Main function to set up a Kubernetes testnet environment.
    
    Args:
        plan: The Kurtosis plan object
        args: Configuration arguments for the testnet
    
    Returns:
        A dictionary with information about the deployed services
    """
    
    # Default configuration
    config = {
        "num_nodes": 3,
        "network_name": "kubernetes-testnet",
        "enable_monitoring": False,
    }
    
    # Override with user-provided arguments
    if args:
        config.update(args)
    
    plan.print("Starting Kubernetes testnet setup...")
    plan.print("Configuration: " + str(config))
    
    # Deploy a simple nginx service as an example node
    deployed_services = []
    
    for i in range(config["num_nodes"]):
        node_name = "node-{}".format(i)
        
        service_config = ServiceConfig(
            image="nginx:alpine",
            ports={
                "http": PortSpec(number=80, transport_protocol="TCP"),
            },
            env_vars={
                "NODE_NAME": node_name,
                "NODE_ID": str(i),
            },
        )
        
        service = plan.add_service(
            name=node_name,
            config=service_config,
        )
        
        deployed_services.append({
            "name": node_name,
            "hostname": service.hostname,
            "http_port": service.ports["http"].number,
        })
        
        plan.print("Deployed node: {}".format(node_name))
    
    # Deploy monitoring if enabled
    if config["enable_monitoring"]:
        plan.print("Setting up monitoring...")
        
        prometheus_config = ServiceConfig(
            image="prom/prometheus:latest",
            ports={
                "http": PortSpec(number=9090, transport_protocol="TCP"),
            },
        )
        
        prometheus = plan.add_service(
            name="prometheus",
            config=prometheus_config,
        )
        
        deployed_services.append({
            "name": "prometheus",
            "hostname": prometheus.hostname,
            "http_port": prometheus.ports["http"].number,
        })
        
        plan.print("Monitoring deployed at: http://{}:{}".format(
            prometheus.hostname,
            prometheus.ports["http"].number
        ))
    
    plan.print("Kubernetes testnet setup complete!")
    plan.print("Total nodes deployed: {}".format(len([s for s in deployed_services if s["name"].startswith("node-")])))
    
    return {
        "network_name": config["network_name"],
        "nodes": deployed_services,
        "status": "running",
    }
