#!/usr/bin/env python3

from mmap import PROT_READ
from diagrams import Diagram
from diagrams import Cluster, Diagram, Edge
from diagrams.custom import Custom
from diagrams.aws.compute import EC2
from diagrams.onprem.compute import Nomad
from diagrams.onprem.network import Consul
from diagrams.onprem.security import Vault

with Diagram("Simple Nomad cluster", show=False):

    with Cluster("VPC"):
        with Cluster("SubNet"):
            with Cluster("Consul"):
                c_server = Consul("Consul cluster")

            with Cluster("Vault"):
                v_server = Vault("Vault cluster")

            with Cluster("Nomad"):
                n_server = Nomad("Nomad cluster")
                n_client = Nomad("Client")

            [ n_server] - n_client

            c_server << [ v_server, n_server, n_client ]
            v_server << [ c_server, n_server, n_client ]
